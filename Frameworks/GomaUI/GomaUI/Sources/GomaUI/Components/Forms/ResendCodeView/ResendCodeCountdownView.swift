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

#Preview("All States") {
    PreviewUIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .backgroundTestColor

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 60-second countdown
        let longCountdownViewModel = MockResendCodeCountdownViewModel(startSeconds: 60)
        let longCountdownView = ResendCodeCountdownView(viewModel: longCountdownViewModel)
        longCountdownView.translatesAutoresizingMaskIntoConstraints = false
        longCountdownViewModel.startCountdown()

        // 5-second countdown
        let shortCountdownViewModel = MockResendCodeCountdownViewModel(startSeconds: 5)
        let shortCountdownView = ResendCodeCountdownView(viewModel: shortCountdownViewModel)
        shortCountdownView.translatesAutoresizingMaskIntoConstraints = false
        shortCountdownViewModel.startCountdown()

        stackView.addArrangedSubview(longCountdownView)
        stackView.addArrangedSubview(shortCountdownView)

        vc.view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        ])

        return vc
    }
}
#endif
