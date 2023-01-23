//
//  TermsCondFormStepView.swift
//  
//
//  Created by Ruben Roques on 23/01/2023.
//

import UIKit
import Theming
import Extensions

struct TermsCondFormStepViewModel {

    let title: String

}

class TermsCondFormStepView: FormStepView {

    private lazy var readLabelBaseView: UIView = Self.createReadLabelBaseView()
    private lazy var readLabel: UILabel = Self.createReadLabel()

    private lazy var marketingBaseView: UIView = Self.createMarketingBaseView()
    private lazy var marketingLabel: UILabel = Self.createMarketingLabel()
    private lazy var marketingSwitch: UISwitch = Self.createMarketingSwitch()

    private lazy var termsBaseView: UIView = Self.createTermsBaseView()
    private lazy var termsLabel: UILabel = Self.createTermsLabel()
    private lazy var termsSwitch: UISwitch = Self.createTermsSwitch()

    let viewModel: TermsCondFormStepViewModel

    init(viewModel: TermsCondFormStepViewModel) {
        self.viewModel = viewModel

        super.init()

        self.configureSubviews()
    }

    func configureSubviews() {


    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setupWithTheme() {
        super.setupWithTheme()

    }

}

extension TermsCondFormStepView {

    fileprivate static func createPlaceHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createReadLabelBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createReadLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private static func createMarketingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createMarketingLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    private static func createMarketingSwitch() -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return UISwitch()
    }

    private static func createTermsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private static func createTermsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    private static func createTermsSwitch() -> UISwitch {
        let switchView = UISwitch()
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return UISwitch()
    }

}
