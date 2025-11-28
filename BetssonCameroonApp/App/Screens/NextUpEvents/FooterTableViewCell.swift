import UIKit
import GomaUI
import SafariServices
import MessageUI

final class FooterTableViewCell: UITableViewCell {

    // MARK: - Cell Identifier
    static let identifier = "FooterTableViewCell"

    // MARK: - Properties

    weak var parentViewController: UIViewController?

    // MARK: - UI Components

    private lazy var footerView: ExtendedListFooterView = {
        let resolver = AppExtendedListFooterImageResolver()
        let viewModel = MockExtendedListFooterViewModel(imageResolver: resolver)
        viewModel.onLinkTap = { [weak self] linkType in
            self?.handleLinkTap(linkType)
        }
        return ExtendedListFooterView(viewModel: viewModel)
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupCell() {
        selectionStyle = .none
        contentView.backgroundColor = .clear
        backgroundColor = .clear

        contentView.addSubview(footerView)

        NSLayoutConstraint.activate([
            footerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Link Handling

    private func handleLinkTap(_ linkType: FooterLinkType) {
        switch linkType {
        case .termsAndConditions:
            openURL("https://www.betsson.com/en/terms-and-conditions")

        case .affiliates:
            openURL("https://www.betssongroupaffiliates.com/")

        case .privacyPolicy:
            openURL("https://www.betsson.com/en/privacy-policy")

        case .cookiePolicy:
            openURL("https://www.betsson.com/en/cookie-policy")

        case .responsibleGambling:
            openURL("https://www.betsson.com/en/responsible-gaming/information")

        case .gameRules:
            openURL("https://www.betsson.com/en/game-rules")

        case .helpCenter:
            openURL("https://support.betsson.com/")

        case .contactUs:
            openMailCompose(to: "support-en@betsson.com")

        case .socialMedia(let platform):
            let urls: [SocialPlatform: String] = [
                .x: "https://twitter.com/betsson",
                .facebook: "https://facebook.com/betsson",
                .instagram: "https://instagram.com/betsson",
                .youtube: "https://youtube.com/betsson"
            ]
            if let urlString = urls[platform] {
                openURL(urlString)
            }
        
        case .casinoRules:
            break
            
        case .custom(let url, _):
            openURL(url)
        }
   
    }

    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        if let parentVC = parentViewController {
            let safariVC = SFSafariViewController(url: url)
            parentVC.present(safariVC, animated: true)
        } else {
            UIApplication.shared.open(url)
        }
    }

    private func openMailCompose(to email: String) {
        guard MFMailComposeViewController.canSendMail() else {
            // Fallback to mailto: URL if mail compose is not available
            if let url = URL(string: "mailto:\(email)") {
                UIApplication.shared.open(url)
            }
            return
        }

        let mailVC = MFMailComposeViewController()
        mailVC.setToRecipients([email])
        mailVC.mailComposeDelegate = self

        parentViewController?.present(mailVC, animated: true)
    }

    // MARK: - Cell Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        parentViewController = nil
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension FooterTableViewCell: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
