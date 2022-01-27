//
//  UploadView.swift
//  Sportsbook
//
//  Created by André Lascas on 27/09/2021.
//

import Foundation
import UIKit

class UploadView: NibView {

    @IBOutlet private var fileLabel: UILabel!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressView: UIProgressView!
    // Variables
    var didTapClose: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {
        //
        self.backgroundColor = UIColor.App2.backgroundPrimary

        closeButton.layer.cornerRadius = closeButton.frame.size.width/2
        closeButton.backgroundColor = UIColor.App2.backgroundPrimary
        closeButton.tintColor = UIColor.App2.textPrimary

        fileLabel.text = "Lorem Ipsum"
        fileLabel.font = AppFont.with(type: .bold, size: 16)
        fileLabel.textColor = UIColor.App2.textPrimary

        progressLabel.text = "Lorem Ipsum dolor amet"
        progressLabel.font = AppFont.with(type: .bold, size: 11)
        progressLabel.textColor = UIColor.App2.textPrimary

        progressView.progressTintColor = UIColor.App2.textHeadlinePrimary
        progressView.trackTintColor = UIColor.App2.backgroundPrimary
    }

    func setTitle(_ title: String) {
        fileLabel.text = title
    }

    func setProgressText(_ text: String) {
        progressLabel.text = text
    }

    func setProgressBar(_ progress: Float) {
        progressView.progress = progress
        if progressView.progress == 1 {
            progressView.progressTintColor = UIColor.App2.alertSuccess
            progressLabel.text = localized("upload_complete")
        }
    }

    @IBAction private func closeAction() {
        didTapClose?()
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: self.frame.width, height: 60)
    }

}
