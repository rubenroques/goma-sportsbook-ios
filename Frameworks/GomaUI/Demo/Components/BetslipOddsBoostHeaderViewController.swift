import UIKit
import GomaUI

final class BetslipOddsBoostHeaderViewController: UIViewController {

    private let mockViewModel = MockBetslipOddsBoostHeaderViewModel.activeMock(
        selectionCount: 1,
        totalEligibleCount: 3
    )

    private lazy var headerView = BetslipOddsBoostHeaderView(viewModel: mockViewModel)

    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["1/3", "2/3", "Max"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
        return control
    }()

    private lazy var enabledToggle: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        toggle.addTarget(self, action: #selector(enabledToggled), for: .valueChanged)
        return toggle
    }()

    private lazy var enabledLabel: UILabel = {
        let label = UILabel()
        label.text = "Enabled"
        label.font = StyleProvider.fontWith(type: .medium, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = StyleProvider.fontWith(type: .regular, size: 12)
        label.textColor = StyleProvider.Color.textSecondary
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateInfoLabel()

        mockViewModel.onHeaderTapped = { [weak self] in
            print("🎯 Header tapped!")
            self?.showAlert(message: "Odds boost header tapped")
        }
    }

    private func setupUI() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary

        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        // Add controls container
        let controlsStack = UIStackView(arrangedSubviews: [enabledLabel, enabledToggle])
        controlsStack.axis = .horizontal
        controlsStack.spacing = 8
        controlsStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentedControl)
        view.addSubview(controlsStack)
        view.addSubview(infoLabel)

        NSLayoutConstraint.activate([
            // Segmented control at top
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Controls stack
            controlsStack.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            controlsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // Info label
            infoLabel.topAnchor.constraint(equalTo: controlsStack.bottomAnchor, constant: 20),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Header view at bottom (simulating betslip header position)
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    @objc private func stateChanged() {
        let newState: BetslipOddsBoostHeaderState

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            newState = BetslipOddsBoostHeaderState(
                selectionCount: 1,
                totalEligibleCount: 3,
                minOdds: "1.10",
                headingText: "Get 3% win boost",
                descriptionText: "by adding 2 more legs to your betslip (1.10 min odds)."
            )
        case 1:
            newState = BetslipOddsBoostHeaderState(
                selectionCount: 2,
                totalEligibleCount: 3,
                minOdds: "1.10",
                headingText: "Get 5% win boost",
                descriptionText: "by adding 1 more legs to your betslip (1.10 min odds)."
            )
        case 2:
            newState = BetslipOddsBoostHeaderState(
                selectionCount: 3,
                totalEligibleCount: 3,
                minOdds: "1.10",
                headingText: "Max win boost activated! (10%)",
                descriptionText: "All qualifying events added"
            )
        default:
            newState = BetslipOddsBoostHeaderState(
                selectionCount: 1,
                totalEligibleCount: 3,
                minOdds: "1.10",
                headingText: "Get 3% win boost",
                descriptionText: "by adding 2 more legs to your betslip (1.10 min odds)."
            )
        }

        mockViewModel.updateState(newState)
        updateInfoLabel()
    }

    @objc private func enabledToggled() {
        mockViewModel.setEnabled(enabledToggle.isOn)
        updateInfoLabel()
    }

    private func updateInfoLabel() {
        let data = mockViewModel.currentData
        let state = data.state

        var stateDescription = "Selections: \(state.selectionCount)/\(state.totalEligibleCount)"
        stateDescription += "\nHeading: \(state.headingText)"

        let enabledStatus = data.isEnabled ? "Enabled" : "Disabled"
        infoLabel.text = "\(stateDescription)\n\nStatus: \(enabledStatus)"
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Event", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
