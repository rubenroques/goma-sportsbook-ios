import Foundation
import UIKit

public class PinDigitField: UIView {
    
    enum State {
        case empty
        case focused
        case filled
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        return view
    }()
    
    private lazy var digitLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 24)
        label.textAlignment = .center
        label.textColor = StyleProvider.Color.textPrimary
        return label
    }()
    
    private lazy var focusIndicatorBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = StyleProvider.Color.highlightPrimary
        view.isHidden = true
        return view
    }()
    
    var onTapped: (() -> Void) = { }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(containerView)
        containerView.addSubview(digitLabel)
        containerView.addSubview(focusIndicatorBar)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            digitLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            digitLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Focus indicator bar at the bottom
            focusIndicatorBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            focusIndicatorBar.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            focusIndicatorBar.widthAnchor.constraint(equalToConstant: 28),
            focusIndicatorBar.heightAnchor.constraint(equalToConstant: 2)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(fieldTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func fieldTapped() {
        onTapped()
    }
    
    func setDigit(_ digit: String) {
        digitLabel.text = digit
    }
    
    func setState(_ state: State) {
        switch state {
        case .empty:
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = StyleProvider.Color.textSecondary.cgColor
            focusIndicatorBar.isHidden = true
        case .focused:
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = StyleProvider.Color.highlightPrimary.cgColor
            focusIndicatorBar.isHidden = false
        case .filled:
            containerView.backgroundColor = .clear
            containerView.layer.borderColor = StyleProvider.Color.alertSuccess.cgColor
            focusIndicatorBar.isHidden = true
        }
    }
}
