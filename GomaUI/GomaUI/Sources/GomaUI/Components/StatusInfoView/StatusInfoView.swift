//
//  StatusInfoView.swift
//  GomaUI
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation
import UIKit
import SwiftUI

public class StatusInfoView: UIView {
    private let viewModel: StatusInfoViewModelProtocol

    private let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.numberOfLines = 0
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Message"
        label.font = StyleProvider.fontWith(type: .regular, size: 16)
        label.numberOfLines = 0
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()

    public init(viewModel: StatusInfoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = StyleProvider.Color.backgroundPrimary

        iconView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2

        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 100),
            iconView.heightAnchor.constraint(equalToConstant: 100),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 50),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 14),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    private func configure() {
        
        if let iconImage = UIImage(named: viewModel.statusInfo.icon) {
            iconView.image = iconImage
        }
        else {
            iconView.image = UIImage(systemName: viewModel.statusInfo.icon)
        }
        
        titleLabel.text = viewModel.statusInfo.title
        
        messageLabel.text = viewModel.statusInfo.message
    }
}

// MARK: - SwiftUI Preview
#if DEBUG

@available(iOS 17.0, *)
struct StatusInfoView_Previews: PreviewProvider {
    static var previews: some View {
            PreviewUIView {
                let mockViewModel: StatusInfoViewModelProtocol = MockStatusInfoViewModel.successMock
                
                return StatusInfoView(viewModel: mockViewModel)
            }
            .previewDisplayName("Success")
            .frame(height: 250)
            .padding()
        }
}
#endif
