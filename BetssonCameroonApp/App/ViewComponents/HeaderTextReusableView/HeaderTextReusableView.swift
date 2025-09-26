//
//  HeaderTextReusableView.swift
//  BetssonCameroonApp
//
//  Created by André Lascas on 25/09/2025.
//

import Foundation
import UIKit
import GomaUI

// MARK: - Recommended Header Supplementary View
final class HeaderTextReusableView: UICollectionReusableView {
    static let identifier = "HeaderTextReusableView"

    private var headerViewModel: MockHeaderTextViewModel?
    private var headerView: HeaderTextView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        headerViewModel = nil
        headerView?.removeFromSuperview()
        headerView = nil
    }

    func configure(title: String) {
        if headerView == nil {
            let viewModel = MockHeaderTextViewModel(title: title)
            let headerView = HeaderTextView(viewModel: viewModel)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.configure()
            addSubview(headerView)
            NSLayoutConstraint.activate([
                headerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
                headerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
                headerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                headerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4)
            ])
            self.headerViewModel = viewModel
            self.headerView = headerView
        } else {
            headerViewModel?.updateTitle(title)
            headerView?.configure()
        }
    }
}
