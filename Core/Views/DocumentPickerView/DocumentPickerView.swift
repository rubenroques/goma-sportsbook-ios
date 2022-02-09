//
//  DocumentPickerView.swift
//  Sportsbook
//
//  Created by André Lascas on 27/09/2021.
//

import Foundation
import UIKit

class DocumentPickerView: NibView {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var addFileButton: UIButton!
    // Variables
    var didTapAddFile: (() -> Void)?
    var fileSelected: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setup()
    }

    func setup() {
        self.backgroundColor = UIColor.App.backgroundPrimary
        self.layer.cornerRadius = CornerRadius.headerInput
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.App.inputBorderActive.withAlphaComponent(1).cgColor

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        addFileButton.setTitle(localized("add_file"), for: .normal)
        addFileButton.titleLabel?.font = AppFont.with(type: .bold, size: 16.0)
        addFileButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        addFileButton.backgroundColor = UIColor.App.backgroundPrimary
        addFileButton.setInsets(forContentPadding: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10), imageTitlePadding: CGFloat(0))
        addFileButton.imageView?.contentMode = .scaleAspectFit
    }

    @IBAction private func addFileAction() {
        didTapAddFile?()
    }
}
