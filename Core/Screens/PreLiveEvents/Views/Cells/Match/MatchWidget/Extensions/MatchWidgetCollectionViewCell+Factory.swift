//
//  MatchWidgetCollectionViewCell+Factory.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Factory Methods
extension MatchWidgetCollectionViewCell {

    // MARK: - Base Views
    func createBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 9
        return view
    }

    func createBaseStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        return stackView
    }

    func createMatchHeaderView() -> MatchHeaderView {
        let headerView = MatchHeaderView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        return headerView
    }

    // MARK: - Border Views
    func createGradientBorderView() -> GradientBorderView {
        let gradientBorderView = GradientBorderView()
        gradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        gradientBorderView.gradientBorderWidth = 1.2
        gradientBorderView.gradientCornerRadius = 9

        gradientBorderView.gradientColors = [UIColor.App.cardBorderLineGradient1,
                                             UIColor.App.cardBorderLineGradient2,
                                             UIColor.App.cardBorderLineGradient3]

        return gradientBorderView
    }

    func createLiveGradientBorderView() -> GradientBorderView {
        let liveGradientBorderView = GradientBorderView()
        liveGradientBorderView.translatesAutoresizingMaskIntoConstraints = false
        liveGradientBorderView.gradientBorderWidth = 2.1
        liveGradientBorderView.gradientCornerRadius = 9

        liveGradientBorderView.gradientColors = [UIColor.App.liveBorder3,
                                                 UIColor.App.liveBorder2,
                                                 UIColor.App.liveBorder1]

        return liveGradientBorderView
    }
    
    func createBoostedOddBottomLineAnimatedGradientView() -> GradientView {
        let boostedOddBottomLineAnimatedGradientView = GradientView()
        boostedOddBottomLineAnimatedGradientView.translatesAutoresizingMaskIntoConstraints = false
        return boostedOddBottomLineAnimatedGradientView
    }

    // MARK: - Odd Button Views
    func createHomeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }

    func createDrawBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }

    func createAwayBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }

    func createOddsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        return stackView
    }

    func createHomeOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        return label
    }

    func createDrawOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        return label
    }

    func createAwayOddTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .center
        return label
    }

    func createHomeOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }

    func createDrawOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }

    func createAwayOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        return label
    }

    // MARK: - Odd Change Indicators
    func createHomeUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    func createHomeDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    func createDrawUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    func createDrawDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    func createAwayUpChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    func createAwayDownChangeOddValueImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.0
        return imageView
    }

    // MARK: - Suspended and See All Views
    func createSuspendedBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.layer.borderWidth = 1
        return view
    }

    func createSuspendedLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.text = localized("suspended")
        return label
    }

    func createSeeAllBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.backgroundColor = UIColor.App.backgroundSecondary
        return view
    }

    func createSeeAllLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 13)
        label.textAlignment = .center
        label.textColor = UIColor.App.textSecondary
        return label
    }

    // MARK: - Outright Views
    func createOutrightBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4.5
        view.backgroundColor = UIColor.App.backgroundSecondary
        return view
    }

    func createOutrightNameBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    func createOutrightNameLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    func createOutrightSeeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .center
        label.text = localized("view_competition_markets")
        return label
    }

    // MARK: - Image Views
    func createTopImageBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }

    func createTopImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "soccer_banner_dummy")
        return imageView
    }

    func createBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .black
        imageView.image = UIImage(named: "soccer_banner_dummy")
        return imageView
    }

    // MARK: - Main Content View
    func createMainContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    // MARK: - Boosted Odd Views
    func createHomeBoostedOddValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.isHidden = true
        return view
    }

    func createDrawBoostedOddValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.isHidden = true
        return view
    }

    func createAwayBoostedOddValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.isHidden = true
        return view
    }

    func createHomeBoostedOddArrowView() -> BoostedArrowView {
        let arrowView = BoostedArrowView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        return arrowView
    }

    func createDrawBoostedOddArrowView() -> BoostedArrowView {
        let arrowView = BoostedArrowView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        return arrowView
    }

    func createAwayBoostedOddArrowView() -> BoostedArrowView {
        let arrowView = BoostedArrowView()
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        return arrowView
    }

    func createBoostedOddBottomLineView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }

    // MARK: - Separator Views
    func createTopSeparatorAlphaLineView() -> FadingView {
        let fadingView = FadingView()
        fadingView.translatesAutoresizingMaskIntoConstraints = false
        fadingView.colors = [.clear, .black, .black, .clear]
        fadingView.startPoint = CGPoint(x: 0.0, y: 0.5)
        fadingView.endPoint = CGPoint(x: 1.0, y: 0.5)
        fadingView.fadeLocations = [0.0, 0.42, 0.58, 1.0]
        return fadingView
    }

    // MARK: - Boosted Corner Views
    func createBoostedTopRightCornerBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }

    func createBoostedTopRightCornerLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        return label
    }

    func createBoostedTopRightCornerImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "boosted_odd_promotional")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func createTopRightInfoIconsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.clipsToBounds = false
        return stackView
    }
    
    // MARK: - Live Indicator Views
    func createLiveTipView() -> UIView {
        let liveTipView = UIView()
        liveTipView.translatesAutoresizingMaskIntoConstraints = false

        // Shadow properties
        liveTipView.layer.masksToBounds = false
        liveTipView.layer.shadowColor = UIColor.App.highlightPrimary.cgColor
        liveTipView.layer.shadowOpacity = 0.7
        liveTipView.layer.shadowOffset = CGSize(width: -4, height: 2)
        liveTipView.layer.shadowRadius = 5

        liveTipView.layer.cornerRadius = 9
        
        return liveTipView
    }

    func createLiveTipLabel() -> UILabel {
        let liveTipLabel = UILabel()
        liveTipLabel.font = AppFont.with(type: .bold, size: 10)
        liveTipLabel.textAlignment = .left
        liveTipLabel.translatesAutoresizingMaskIntoConstraints = false
        liveTipLabel.setContentHuggingPriority(.required, for: .horizontal)
        liveTipLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        liveTipLabel.text = localized("live").uppercased() + " ⦿"

        return liveTipLabel
    }

    // MARK: - Icon Views
    func createCashbackIconContainerView() -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }
    
    func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "cashback_small_blue_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    // MARK: - Match Info View
    func createMatchInfoView() -> MatchInfoView {
        let view = MatchInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    // MARK: - Bottom Action Views
    func createBottomSeeAllMarketsContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    func createBottomSeeAllMarketsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.backgroundColor = UIColor.App.backgroundSecondary
        view.clipsToBounds = true
        return view
    }

    func createBottomSeeAllMarketsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("see_game_details")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textColor = UIColor.App.textSecondary
        label.textAlignment = .center
        return label
    }

    func createBottomSeeAllMarketsArrowIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "nav_arrow_right_icon")
        imageView.setTintColor(color: UIColor.App.iconSecondary)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    // MARK: - Mix Match Views
    func createMixMatchContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    func createMixMatchBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = CornerRadius.view
        view.clipsToBounds = true
        return view
    }

    func createMixMatchBackgroundImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_highlight")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    func createMixMatchIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "mix_match_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    func createMixMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\("mix_match_match_string")"
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center

        let text = "\(localized("mix_match_or_bet_with_string")) \(localized("mix_match_mix_string"))\(localized("mix_match_match_string"))"

        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = (text as NSString).range(of: text)
        var range = (text as NSString).range(of: localized("mix_match_mix_string"))

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.buttonTextPrimary, range: fullRange)
        attributedString.addAttribute(.font, value: AppFont.with(type: .bold, size: 14), range: fullRange)

        attributedString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range)

        label.attributedText = attributedString

        return label
    }

    func createMixMatchNavigationIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "arrow_right_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    // MARK: - Boosted Odds Views
    func createBoostedOddBarView() -> UIView {
        let boostedOddBarView = UIView()
        boostedOddBarView.backgroundColor = .clear
        boostedOddBarView.translatesAutoresizingMaskIntoConstraints = false
        return boostedOddBarView
    }

    func createBoostedOddBarStackView() -> UIStackView {
        let boostedOddBarStackView = UIStackView()
        boostedOddBarStackView.axis = .horizontal
        boostedOddBarStackView.spacing = 8
        boostedOddBarStackView.translatesAutoresizingMaskIntoConstraints = false
        return boostedOddBarStackView
    }

    func createOldValueBoostedButtonContainerView() -> UIView {
        let oldValueBoostedButtonContainerView = UIView()
        oldValueBoostedButtonContainerView.backgroundColor = .clear
        oldValueBoostedButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        return oldValueBoostedButtonContainerView
    }

    func createOldValueBoostedButtonView() -> UIView {
        let oldValueBoostedButtonView = UIView()
        oldValueBoostedButtonView.backgroundColor = UIColor.App.inputBorderDisabled
        oldValueBoostedButtonView.layer.borderColor = UIColor.App.inputBackgroundSecondary.cgColor
        oldValueBoostedButtonView.layer.borderWidth = 1.2
        oldValueBoostedButtonView.layer.cornerRadius = 4.5
        oldValueBoostedButtonView.translatesAutoresizingMaskIntoConstraints = false
        return oldValueBoostedButtonView
    }

    func createOldTitleBoostedOddLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.text = "Label"
        return label
    }

    func createOldValueBoostedOddLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textSecondary
        label.text = "Label"
        return label
    }

    func createArrowSpacerView() -> UIView {
        let arrowSpacerView = UIView()
        arrowSpacerView.backgroundColor = .clear
        arrowSpacerView.translatesAutoresizingMaskIntoConstraints = false

        let imageView = UIImageView(image: UIImage(named: "boosted_arrow_right"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false

        arrowSpacerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: arrowSpacerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: arrowSpacerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: arrowSpacerView.heightAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 19),
        ])
        return arrowSpacerView
    }

    func createNewValueBoostedButtonContainerView() -> UIView {
        let newValueBoostedButtonContainerView = UIView()
        newValueBoostedButtonContainerView.backgroundColor = .clear
        newValueBoostedButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        return newValueBoostedButtonContainerView
    }

    func createNewValueBoostedButtonView() -> UIView {
        let newValueBoostedButtonView = UIView()
        newValueBoostedButtonView.backgroundColor = UIColor.App.inputBackground
        newValueBoostedButtonView.layer.borderColor = UIColor.App.highlightPrimary.cgColor
        newValueBoostedButtonView.layer.borderWidth = 1.3
        newValueBoostedButtonView.layer.cornerRadius = 4.5
        newValueBoostedButtonView.translatesAutoresizingMaskIntoConstraints = false
        return newValueBoostedButtonView
    }

    func createNewTitleBoostedOddLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 8)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.text = "Label"
        return label
    }

    func createNewValueBoostedOddLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.App.textPrimary
        label.text = "Label"
        return label
    }


    // MARK: - Team Stack Views
    func createHomeElementsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }

    func createAwayElementsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }
}
