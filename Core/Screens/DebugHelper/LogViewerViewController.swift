//
//  LogViewerViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 09/08/2021.
//

import UIKit

class LogViewerViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Logs"

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapTextview))
        tapRecognizer.numberOfTapsRequired = 2
        textView.addGestureRecognizer(tapRecognizer)

        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShareButton))
        navigationItem.rightBarButtonItems = [shareButton]

        self.textView.text = loadLogs()
    }

    func loadLogs() -> String {
        let filePath = logsPath()
        if let contents = try? String(contentsOfFile: filePath.path) {
            return contents
        }
        else if let contents = try? String(contentsOfFile: filePath.absoluteString) {
            return contents
        }
        else {
            print("Error! - This file doesn't contain any text.")
        }

        return ""
    }

    @objc func didTapTextview() {
        UIPasteboard.general.string = self.textView.text
    }

    @objc func didTapShareButton() {
        UIPasteboard.general.string = self.textView.text
    }

}
