//
//  FooterResponsibleGamingView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/03/2023.
//

import Foundation
import UIKit

class FooterResponsibleGamingView: UIView {

    private lazy var baseView: UIView = Self.createBaseView()
    private lazy var topLabel: UILabel = Self.createTopLabel()
    private lazy var bottomLabel: UILabel = Self.createBottomLabel()

    private lazy var ageBaseView: UIView = Self.createAgeBaseView()
    private lazy var ageLabel: UILabel = Self.createAgeLabel()

    // MARK: - Lifetime and Cycle
    init() {
        super.init(frame: .zero)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    override init(frame: CGRect) {
        super.init(frame: frame)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInit()
        self.setupWithTheme()
    }

    func commonInit() {
        self.setupSubviews()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBaseView))
        self.baseView.addGestureRecognizer(tapGestureRecognizer)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear

    }

    @objc func didTapBaseView() {
        if let url = URL(string: "https://www.joueurs-info-service.fr/") {
            UIApplication.shared.open(url)
        }
    }

}


extension FooterResponsibleGamingView {

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = UIColor(hex: 0x040626)
        return view
    }

    private static func createTopLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "FAMILLE, VIE SOCIALE, SANTÉ FINANCIÈRE. ETES-VOUS PRÊT À TOUT MISER? POUR ÊTRE AIDÉ, APPELEZ LE 09-74-75-13-13 (APPEL NON SURTAXÉ)"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        return label
    }

    private static func createBottomLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "LES JEUX D+ARGENT ET DE HASARD SONT \n INTERDITS AUX MINEURS"
        label.font = AppFont.with(type: .semibold, size: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x5559b4)
        return label
    }

    private static func createAgeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor(hex: 0x5559b4).cgColor
        return view
    }

    private static func createAgeLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = "+18"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(hex: 0x5559b4)
        return label
    }

    private func setupSubviews() {

        // Add subviews to self.view or each other
        self.addSubview(self.baseView)

        self.baseView.addSubview(self.topLabel)
        self.baseView.addSubview(self.bottomLabel)

        self.baseView.addSubview(self.ageBaseView)
        self.ageBaseView.addSubview(self.ageLabel)

        // Initialize constraints
        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.baseView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 18),
            self.baseView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -18),
            self.baseView.topAnchor.constraint(equalTo: self.topAnchor),
            self.baseView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -46),

            self.topLabel.topAnchor.constraint(equalTo: self.baseView.topAnchor, constant: 12),
            self.topLabel.leadingAnchor.constraint(equalTo: self.baseView.leadingAnchor, constant: 16),
            self.topLabel.trailingAnchor.constraint(equalTo: self.baseView.trailingAnchor, constant: -16),

            self.topLabel.bottomAnchor.constraint(equalTo: self.bottomLabel.topAnchor, constant: -10),

            self.bottomLabel.centerXAnchor.constraint(equalTo: self.baseView.centerXAnchor),
            self.bottomLabel.bottomAnchor.constraint(equalTo: self.baseView.bottomAnchor, constant: -12),
            self.bottomLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.baseView.leadingAnchor),

            self.ageLabel.centerYAnchor.constraint(equalTo: self.ageBaseView.centerYAnchor),
            self.ageLabel.centerXAnchor.constraint(equalTo: self.ageBaseView.centerXAnchor),

            self.ageBaseView.leadingAnchor.constraint(greaterThanOrEqualTo: self.baseView.leadingAnchor, constant: 2),
            self.ageBaseView.widthAnchor.constraint(equalToConstant: 30),
            self.ageBaseView.widthAnchor.constraint(equalTo: self.ageBaseView.heightAnchor),
            self.ageBaseView.centerYAnchor.constraint(equalTo: self.bottomLabel.centerYAnchor),
            self.ageBaseView.trailingAnchor.constraint(equalTo: self.bottomLabel.leadingAnchor, constant: -12)
        ])
    }
}
