import UIKit
import PlaygroundSupport

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
