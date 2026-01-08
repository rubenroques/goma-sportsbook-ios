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
    
    var shouldUpdateLayout: (() -> Void)?

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
        print("SpinWheel: Setting up WebView")
        let configuration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        userContentController.add(self, name: "hostApp")
        configuration.userContentController = userContentController
        
        // Create gradient view first
        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create gradient layer
        let gradientLayer = CAGradientLayer()
        
        // Set gradient colors - using custom colors or system colors
//        gradientLayer.colors = [
//            UIColor.App.backgroundGradient1.cgColor,
//            UIColor.App.backgroundGradient2.cgColor
//        ]
        
        // Set gradient colors using RGB values
        let topColor = UIColor(red: 0/255, green: 27/255, blue: 61/255, alpha: 1.0)
        let bottomColor = UIColor(red: 5/255, green: 0/255, blue: 25/255, alpha: 1.0)
        
        // Set gradient colors
        gradientLayer.colors = [
            topColor.cgColor,
            bottomColor.cgColor
        ]
        
        // Set gradient direction (top to bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // Add gradient layer to the view
        gradientView.layer.addSublayer(gradientLayer)
        
        // Add views to hierarchy - gradient first, then webView
        self.view.addSubview(gradientView)
        
        // Create and configure webView
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        self.webView.navigationDelegate = self
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Make webView transparent
        self.webView.backgroundColor = .clear
        self.webView.isOpaque = false
        self.webView.scrollView.backgroundColor = .clear
        
        // Ensure WebView ignores safe areas
        self.webView.insetsLayoutMarginsFromSafeArea = false
        
        self.view.addSubview(self.webView)
        
        NSLayoutConstraint.activate([
            // Gradient view fills the entire view
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            self.webView.topAnchor.constraint(equalTo: view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        // Update gradient frame when view layout changes
        gradientView.layoutIfNeeded()
        
        // Set gradient layer frame
        gradientLayer.frame = gradientView.bounds
        
        print("SpinWheel: WebView setup completed")
        
    }

    private func setupBindings() {
        print("SpinWheel: Setting up bindings")
        self.viewModel.messageToWebViewPublisher
            .sink { [weak self] message in
                print("SpinWheel: Received message to send to WebView: \(message)")
                self?.sendMessageToWebView(message)
            }
            .store(in: &self.cancellables)

        self.viewModel.exitPublisher
            .sink { [weak self] _ in
                print("SpinWheel: Received exit command")
                self?.shouldUpdateLayout?()
                self?.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
        print("SpinWheel: Bindings setup completed")
    }

    private func loadWebContent() {
        print("SpinWheel: Loading web content from URL: \(self.viewModel.url)")
        let request = URLRequest(url: self.viewModel.url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 25.0)
        self.webView.load(request)
    }

    private func sendMessageToWebView(_ message: SpinWheelMessage) {
        print("SpinWheel: Attempting to send message to WebView: \(message)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message.jsonData, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                let jsCode = "window.postMessage(\(jsonString), '*');"
                print("SpinWheel: Executing JS: \(jsCode)")
                
                self.webView.evaluateJavaScript(jsCode) { result, error in
                    if let error = error {
                        print("SpinWheel: Error sending message to webView: \(error)")
                    } else {
                        print("SpinWheel: Message sent to WebView successfully")
                    }
                }
            }
        }
        catch {
            print("SpinWheel: Error serializing message: \(error)")
        }
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("SpinWheel: Received message from WebView - name: \(message.name), body: \(message.body)")
        if message.name == "hostApp", let body = message.body as? [String: Any] {
            print("SpinWheel: Processing hostApp message with body: \(body)")
            if let spinWheelMessage = SpinWheelMessage.from(dictionary: body) {
                print("SpinWheel: Successfully parsed message: \(spinWheelMessage)")
                self.viewModel.handleMessageFromWebView(spinWheelMessage)
            } else {
                print("SpinWheel: Failed to parse message from body: \(body)")
            }
        }
    }

    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("SpinWheel: WebView did finish navigation")

        // Setup JavaScript to forward messages to native code
        let script = """
        window.addEventListener('message', function(event) {
            console.log('SpinWheel JS: Received message event', event.data);
            window.webkit.messageHandlers.hostApp.postMessage(event.data);
        });
        console.log('SpinWheel JS: Message listener set up');
        """

        webView.evaluateJavaScript(script) { [weak self] result, error in
            if let error = error {
                print("SpinWheel: Error setting up message listener: \(error)")
            } else {
                print("SpinWheel: Message listener setup successfully")
                self?.evaluateReadyState()
            }
        }

    }

    func evaluateReadyState() {
        // Add a check to see if the page is truly interactive
        webView.evaluateJavaScript("document.readyState") { [weak self] result, error in
            if let readyState = result as? String {
                print("SpinWheel: Document readyState: \(readyState)")

                // Add a delay of 1.5 seconds before triggering widgetLoaded
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//                    print("SpinWheel: Sending widgetLoaded after delay")
//                    self?.viewModel.handleMessageFromWebView(.widgetLoaded)
//                }
                // no delay
                self?.viewModel.handleMessageFromWebView(.widgetLoaded)
            }
        }
    }

    // Add more navigation delegate methods for debugging
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("SpinWheel: WebView did start provisional navigation")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("SpinWheel: WebView did commit navigation")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("SpinWheel: WebView did fail navigation with error: \(error)")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("SpinWheel: WebView did fail provisional navigation with error: \(error)")
    }
}
