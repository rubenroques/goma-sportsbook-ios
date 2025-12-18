import Foundation
import UIKit
import GomaUI

class ButtonViewController: UIViewController {
    private let buttonViewModels: [(title: String, viewModel: ButtonViewModelProtocol)] = [
        // Basic Styles
        ("Solid Background", MockButtonViewModel.solidBackgroundMock),
        ("Solid Background Disabled", MockButtonViewModel.solidBackgroundDisabledMock),
        ("Bordered", MockButtonViewModel.borderedMock),
        ("Bordered Disabled", MockButtonViewModel.borderedDisabledMock),
        ("Transparent", MockButtonViewModel.transparentMock),
        ("Transparent Disabled", MockButtonViewModel.transparentDisabledMock),
        
        // Color Customization
        ("Custom Solid Color", MockButtonViewModel.solidBackgroundCustomColorMock),
        ("Custom Border Color", MockButtonViewModel.borderedCustomColorMock),
        ("Custom Transparent Color", MockButtonViewModel.transparentCustomColorMock),
        ("Red Theme", MockButtonViewModel.redThemeMock),
        ("Blue Theme", MockButtonViewModel.blueThemeMock),
        ("Green Theme", MockButtonViewModel.greenThemeMock),
        ("Orange Theme", MockButtonViewModel.orangeThemeMock),
        
        // Font Customization
        ("Large Font (24pt Bold)", MockButtonViewModel.largeFontMock),
        ("Small Font (12pt Medium)", MockButtonViewModel.smallFontMock),
        ("Light Font (18pt Light)", MockButtonViewModel.lightFontMock),
        ("Heavy Font (20pt Heavy)", MockButtonViewModel.heavyFontMock),
        ("Custom Font Style (16pt Semibold)", MockButtonViewModel.customFontStyleMock)
    ]
    private var buttonViews: [ButtonView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        setupButtonViews()
    }

    private func setupButtonViews() {
        // Create scroll view
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        
        // Create content stack view
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        for (title, viewModel) in buttonViewModels {
            let label = UILabel()
            label.text = title
            label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
            label.textColor = .secondaryLabel
            label.textAlignment = .left
            label.numberOfLines = 1

            let buttonView = ButtonView(viewModel: viewModel)
            buttonView.translatesAutoresizingMaskIntoConstraints = false
            buttonView.heightAnchor.constraint(equalToConstant: 56).isActive = true
            buttonViews.append(buttonView)

            let container = UIStackView(arrangedSubviews: [label, buttonView])
            container.axis = .vertical
            container.spacing = 8
            container.alignment = .fill
            container.distribution = .fill

            stackView.addArrangedSubview(container)
        }

        // Add scroll view to main view
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Stack view constraints within scroll view
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 40),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -32),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40),
            
            // Stack view width constraint to scroll view for proper horizontal sizing
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -64)
        ])
    }
}
