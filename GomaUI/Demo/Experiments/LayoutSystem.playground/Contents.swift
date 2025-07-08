import UIKit
import PlaygroundSupport

/*

 // MARK: - Models
enum LayoutMode: String, Codable {
    case flex
    case split
}

enum WidgetID: String, Codable, CaseIterable {
    case logo
    case flexSpace
    case balanceWithDeposit
    case profile
    case help
    case loginButton
    case signUpButton
}

struct LineConfig: Codable {
    let mode: LayoutMode
    let widgets: [WidgetID]
}

struct TabBarConfig: Codable {
    let height: CGFloat?
    let paddingHorizontal: CGFloat?
    let spacing: CGFloat?
    let lines: [LineConfig]
}

// MARK: - Component Factory
final class ComponentFactory {
    static func view(for widget: WidgetID) -> UIView {
        switch widget {
        case .logo:
            let iv = UIImageView(image: UIImage(systemName: "flame.fill"))
            iv.tintColor = .systemOrange
            iv.contentMode = .scaleAspectFit
            iv.widthAnchor.constraint(equalToConstant: 32).isActive = true
            iv.heightAnchor.constraint(equalToConstant: 32).isActive = true
            return iv

        case .flexSpace:
            let spacer = UIView()
            spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
            spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return spacer

        case .balanceWithDeposit:
            let label = UILabel()
            label.text = "$1,234"
            label.font = UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .semibold)

            let button = UIButton(type: .system)
            button.setTitle("Deposit", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.layer.cornerRadius = 4
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

            let stack = UIStackView(arrangedSubviews: [label, button])
            stack.axis = .horizontal
            stack.spacing = 8
            return stack

        case .profile:
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: "person.circle"), for: .normal)
            btn.tintColor = .label
            btn.widthAnchor.constraint(equalToConstant: 32).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 32).isActive = true
            return btn

        case .help:
            let btn = UIButton(type: .system)
            btn.setImage(UIImage(systemName: "questionmark.circle"), for: .normal)
            btn.tintColor = .label
            btn.widthAnchor.constraint(equalToConstant: 28).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
            return btn

        case .loginButton:
            let btn = UIButton(type: .system)
            btn.setTitle("Login", for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 4
            btn.layer.borderColor = UIColor.label.cgColor
            btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            return btn

        case .signUpButton:
            let btn = UIButton(type: .system)
            btn.setTitle("Join Now", for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            btn.backgroundColor = .systemGreen
            btn.setTitleColor(.white, for: .normal)
            btn.layer.cornerRadius = 4
            btn.contentEdgeInsets = UIEdgeInsets(top: 4, left: 12, bottom: 4, right: 12)
            return btn
        }
    }
}

// MARK: - Toolbar Builder

final class ToolbarBuilder {
    static func build(from config: TabBarConfig) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .fill
        container.spacing = config.spacing ?? 0
        container.translatesAutoresizingMaskIntoConstraints = false

        for line in config.lines {
            let row = UIStackView()
            row.axis = .horizontal
            row.alignment = .center
            row.spacing = config.spacing ?? 0

            switch line.mode {
            case .flex:
                row.distribution = .fill
                for widgetID in line.widgets {
                    let view = ComponentFactory.view(for: widgetID)
                    if widgetID != .flexSpace {
                        view.setContentHuggingPriority(.required, for: .horizontal)
                        view.setContentCompressionResistancePriority(.required, for: .horizontal)
                    }
                    row.addArrangedSubview(view)
                }

            case .split:
                row.distribution = .fillEqually
                for widgetID in line.widgets {
                    let view = ComponentFactory.view(for: widgetID)
                    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
                    row.addArrangedSubview(view)
                }
            }

            container.addArrangedSubview(row)
        }

        if let pad = config.paddingHorizontal {
            container.layoutMargins = UIEdgeInsets(top: 0, left: pad, bottom: 0, right: pad)
            container.isLayoutMarginsRelativeArrangement = true
        }

        if let height = config.height {
            container.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        return container
    }
}

// MARK: - Sample Data & Live Preview

let jsonConfig = """
{
  "height": 56,
  "paddingHorizontal": 16,
  "spacing": 8,
  "lines": [
    {
      "mode": "flex",
      "widgets": ["logo", "flexSpace", "balanceWithDeposit", "profile"]
    },
    {
      "mode": "split",
      "widgets": ["loginButton", "signUpButton"]
    }
  ]
}
"""

let data = Data(jsonConfig.utf8)
let config = try! JSONDecoder().decode(TabBarConfig.self, from: data)

let toolbar = ToolbarBuilder.build(from: config)

let root = UIView(frame: CGRect(x: 0, y: 0, width: 390, height: 120))
root.backgroundColor = .systemBackground
root.addSubview(toolbar)

NSLayoutConstraint.activate([
    toolbar.leadingAnchor.constraint(equalTo: root.leadingAnchor),
    toolbar.trailingAnchor.constraint(equalTo: root.trailingAnchor),
    toolbar.topAnchor.constraint(equalTo: root.topAnchor)
])

PlaygroundSupport.PlaygroundPage.current.liveView = root

 */


import UIKit
import PlaygroundSupport

// MARK: - Capsule View
class CapsuleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        // Set corner radius to half the height for perfect capsule shape
        layer.cornerRadius = bounds.height / 2
        layer.masksToBounds = true
    }
}

// MARK: - Capsule Button
class CapsuleButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    func setupStyle() {
        backgroundColor = .systemBlue
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
    }
}

// MARK: - Playground View Controller
class PlaygroundViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Create a stack view to organize our examples
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ])
        
        // Example 1: Basic Capsule View
        let basicCapsule = CapsuleView()
        basicCapsule.backgroundColor = .systemPurple
        basicCapsule.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createLabeledView("Basic Capsule", view: basicCapsule))
        
        NSLayoutConstraint.activate([
            basicCapsule.widthAnchor.constraint(equalToConstant: 200),
            basicCapsule.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Example 2: Capsule Button
        let capsuleButton = CapsuleButton()
        capsuleButton.setTitle("Tap Me", for: .normal)
        capsuleButton.setupStyle()
        capsuleButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        stackView.addArrangedSubview(createLabeledView("Interactive Button", view: capsuleButton))
        
        // Example 3: Capsule with Border
        let borderedCapsule = CapsuleView()
        borderedCapsule.backgroundColor = .systemBackground
        borderedCapsule.layer.borderWidth = 3
        borderedCapsule.layer.borderColor = UIColor.systemGreen.cgColor
        borderedCapsule.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(createLabeledView("Bordered Capsule", view: borderedCapsule))
        
        NSLayoutConstraint.activate([
            borderedCapsule.widthAnchor.constraint(equalToConstant: 180),
            borderedCapsule.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Example 4: Gradient Capsule
        let gradientCapsule = createGradientCapsule()
        
        stackView.addArrangedSubview(createLabeledView("Gradient Capsule", view: gradientCapsule))
        
        // Example 5: Capsule with Shadow
        let shadowCapsule = createShadowCapsule()
        
        stackView.addArrangedSubview(createLabeledView("Shadow Capsule", view: shadowCapsule))
        
        // Example 6: Mini Pills Row
        let pillsRow = createPillsRow()
        
        stackView.addArrangedSubview(createLabeledView("Mini Pills", view: pillsRow))
    }
    
    // MARK: - Helper Methods
    
    func createLabeledView(_ title: String, view: UIView) -> UIView {
        let container = UIView()
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(label)
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            
            view.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            view.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])
        
        return container
    }
    
    func createGradientCapsule() -> UIView {
        let capsule = CapsuleView()
        capsule.translatesAutoresizingMaskIntoConstraints = false
        
        // Add gradient after layout
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = capsule.bounds
            gradientLayer.colors = [
                UIColor.systemPink.cgColor,
                UIColor.systemOrange.cgColor
            ]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            gradientLayer.cornerRadius = capsule.bounds.height / 2
            
            capsule.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        NSLayoutConstraint.activate([
            capsule.widthAnchor.constraint(equalToConstant: 220),
            capsule.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        return capsule
    }
    
    func createShadowCapsule() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let capsule = UIView()
        capsule.backgroundColor = .systemIndigo
        capsule.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure shadow
        capsule.layer.shadowColor = UIColor.black.cgColor
        capsule.layer.shadowOpacity = 0.3
        capsule.layer.shadowOffset = CGSize(width: 0, height: 4)
        capsule.layer.shadowRadius = 6
        
        containerView.addSubview(capsule)
        
        NSLayoutConstraint.activate([
            capsule.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            capsule.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            capsule.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            capsule.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            capsule.widthAnchor.constraint(equalToConstant: 190),
            capsule.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Apply corner radius after layout
        DispatchQueue.main.async {
            capsule.layer.cornerRadius = capsule.bounds.height / 2
        }
        
        return containerView
    }
    
    func createPillsRow() -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let colors: [UIColor] = [.systemRed, .systemYellow, .systemGreen, .systemBlue]
        let titles = ["iOS", "Swift", "UIKit", "Xcode"]
        
        for (index, color) in colors.enumerated() {
            let pill = CapsuleView()
            pill.backgroundColor = color
            pill.translatesAutoresizingMaskIntoConstraints = false
            
            let label = UILabel()
            label.text = titles[index]
            label.font = .systemFont(ofSize: 12, weight: .semibold)
            label.textColor = .white
            label.translatesAutoresizingMaskIntoConstraints = false
            
            pill.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: pill.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: pill.centerYAnchor),
                
                pill.widthAnchor.constraint(equalToConstant: 60),
                pill.heightAnchor.constraint(equalToConstant: 28)
            ])
            
            stackView.addArrangedSubview(pill)
        }
        
        return stackView
    }
    
    @objc func buttonTapped() {
        print("Capsule button tapped!")
        
        // Simple animation
        UIView.animate(withDuration: 0.1, animations: {
            self.view.subviews.first?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.view.subviews.first?.transform = .identity
            }
        }
    }
}

// MARK: - Playground Setup
let viewController = PlaygroundViewController()
viewController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)

// Present the view controller in the Live View
PlaygroundPage.current.liveView = viewController
