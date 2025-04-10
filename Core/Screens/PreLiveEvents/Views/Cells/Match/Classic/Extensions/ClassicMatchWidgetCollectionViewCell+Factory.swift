//
//  ClassicMatchWidgetCollectionViewCell+Factory.swift
//  Sportsbook
//
//  Created by Refactoring on 2024.
//

import UIKit

// MARK: - Factory Methods
extension ClassicMatchWidgetCollectionViewCell {

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

    func createMatchInfoView() -> MatchInfoView {
        let view = MatchInfoView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

        liveGradientBorderView.gradientColors = [UIColor.App.liveBorderGradient3,
                                                 UIColor.App.liveBorderGradient2,
                                                 UIColor.App.liveBorderGradient1]

        return liveGradientBorderView
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

    // MARK: - Main Content View
    func createMainContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
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

}
