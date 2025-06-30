//
//  ResendCodeCountdownView.swift
//  GomaUI
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import UIKit
import Combine

public class ResendCodeCountdownView: UIView {
    
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .left
        return label
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let viewModel: ResendCodeCountdownViewModelProtocol

    public init(viewModel: ResendCodeCountdownViewModelProtocol) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
        viewModel.startCountdown()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func bindViewModel() {
        
        viewModel.countdownTextPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.label.text = text
            }
            .store(in: &cancellables)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 17.0, *)
struct ResendCodeCountdownView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PreviewUIView {
                let viewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
                let view = ResendCodeCountdownView(viewModel: viewModel)
                viewModel.startCountdown()
                return view
            }
            .frame(height: 30)
            .previewDisplayName("Default Countdown")
            
            PreviewUIView {
                let viewModel = MockResendCodeCountdownViewModel(startSeconds: 5)
                let view = ResendCodeCountdownView(viewModel: viewModel)
                viewModel.startCountdown()
                return view
            }
            .frame(height: 30)
            .previewDisplayName("Short Countdown")
        }
        .padding()
        .frame(maxHeight: 100)
    }
}
#endif
