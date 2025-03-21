//
//  SpinWheelViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/03/2025
//

import UIKit
import WebKit
import Combine

class SpinWheelViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {

    // MARK: - Private Properties
    private var webView: WKWebView!
    private let viewModel: SpinWheelViewModel
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initialization
    init(viewModel: SpinWheelViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWebView()
        self.setupBindings()
        self.loadWebContent()
    }

    // MARK: - Private Methods
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()

        userContentController.add(self, name: "hostApp")
        configuration.userContentController = userContentController

        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false


        // Set background color to match web content
        self.webView.backgroundColor = .black
        self.webView.isOpaque = false

        // Ensure WebView ignores safe areas
        self.webView.insetsLayoutMarginsFromSafeArea = false


        self.view.addSubview(self.webView)

        NSLayoutConstraint.activate([
            self.webView.topAnchor.constraint(equalTo: view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupBindings() {
        self.viewModel.messageToWebViewPublisher
            .sink { [weak self] message in
                self?.sendMessageToWebView(message)
            }
            .store(in: &self.cancellables)

        self.viewModel.exitPublisher
            .sink { [weak self] _ in
                self?.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
    }

    private func loadWebContent() {
        let request = URLRequest(url: self.viewModel.url)
        self.webView.load(request)
    }

    private func sendMessageToWebView(_ message: SpinWheelMessage) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.jsonData, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let jsCode = "window.postMessage(\(jsonString), '*');"

                self.webView.evaluateJavaScript(jsCode) { (result, error) in
                    if let error = error {
                        print("Error sending message to webView: \(error)")
                    }
                }
            }
        } catch {
            print("Error serializing message: \(error)")
        }
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "hostApp", let body = message.body as? [String: Any] {
            if let spinWheelMessage = SpinWheelMessage.from(dictionary: body) {
                self.viewModel.handleMessageFromWebView(spinWheelMessage)
            }
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Setup JavaScript to forward messages to native code
        let script = """
        window.addEventListener('message', function(event) {
            window.webkit.messageHandlers.hostApp.postMessage(event.data);
        });
        """

        webView.evaluateJavaScript(script) { _, error in
            if let error = error {
                print("Error setting up message listener: \(error)")
            }
        }
    }
}
