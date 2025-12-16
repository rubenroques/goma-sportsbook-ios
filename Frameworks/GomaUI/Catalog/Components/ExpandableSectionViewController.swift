import UIKit
import GomaUI
import Combine

class ExpandableSectionViewController: UIViewController {
    
    // MARK: - Properties
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupExpandableSections()
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
        title = "Expandable Section"
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        view.addSubview(scrollView)
        
        // Content view setup
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Stack view setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        contentView.addSubview(stackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Stack view
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
        
        // Add description
        let descriptionLabel = UILabel()
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "ExpandableSectionView provides a header with title and toggle button, with a content area that can hold any views. Perfect for FAQ sections, information panels, and collapsible content."
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = StyleProvider.fontWith(type: .regular, size: 16)
        descriptionLabel.textColor = StyleProvider.Color.textPrimary
        stackView.addArrangedSubview(descriptionLabel)
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = StyleProvider.Color.highlightSecondary
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }
    
    private func setupExpandableSections() {
        // Section 1: Information Section with Rich Content
        let section1ViewModel = MockExpandableSectionViewModel.customMock(title: "Information", isExpanded: false)
        let section1 = ExpandableSectionView(viewModel: section1ViewModel)
        
        // Add subtitle
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Sub title"
        subtitleLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        subtitleLabel.textColor = StyleProvider.Color.textPrimary
        section1.contentContainer.addArrangedSubview(subtitleLabel)
        
        // Add heading 1
        let heading1 = UILabel()
        heading1.text = "One bet too many?"
        heading1.font = StyleProvider.fontWith(type: .semibold, size: 14)
        heading1.textColor = StyleProvider.Color.textPrimary
        section1.contentContainer.addArrangedSubview(heading1)
        
        // Add paragraph 1
        let paragraph1 = UILabel()
        paragraph1.text = "Responsible gaming at Betsson means never borrowing money or spending more than you can afford. We're committed to player safety and providing a safe gaming environment."
        paragraph1.numberOfLines = 0
        paragraph1.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph1.textColor = StyleProvider.Color.textSecondary
        section1.contentContainer.addArrangedSubview(paragraph1)
        
        // Add heading 2
        let heading2 = UILabel()
        heading2.text = "We help you set the limits!"
        heading2.font = StyleProvider.fontWith(type: .semibold, size: 14)
        heading2.textColor = StyleProvider.Color.textPrimary
        section1.contentContainer.addArrangedSubview(heading2)
        
        // Add paragraph 2
        let paragraph2 = UILabel()
        paragraph2.text = "You have the opportunity to set your own gaming limits, budget, and boundaries. We partner with Global Gambling Guidance Group (G4) to help prevent unhealthy gaming behavior."
        paragraph2.numberOfLines = 0
        paragraph2.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph2.textColor = StyleProvider.Color.textSecondary
        section1.contentContainer.addArrangedSubview(paragraph2)
        
        // Add paragraph 3
        let paragraph3 = UILabel()
        paragraph3.text = "You can set limits via 'Responsible Gambling' area, 'My Account', or contact Customer Service at support-en@betsson.com or +356 2260 3000. Available 24 hours a day, 7 days a week."
        paragraph3.numberOfLines = 0
        paragraph3.font = StyleProvider.fontWith(type: .regular, size: 13)
        paragraph3.textColor = StyleProvider.Color.textSecondary
        section1.contentContainer.addArrangedSubview(paragraph3)
        
        stackView.addArrangedSubview(section1)
        
        // Section 2: Terms & Conditions
        let section2ViewModel = MockExpandableSectionViewModel.customMock(title: "Terms & Conditions", isExpanded: false)
        let section2 = ExpandableSectionView(viewModel: section2ViewModel)
        
        let termsLabel = UILabel()
        termsLabel.text = "By using our services, you agree to be bound by these Terms and Conditions. Please read them carefully before proceeding. These terms govern your use of our platform and all associated services."
        termsLabel.numberOfLines = 0
        termsLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        termsLabel.textColor = StyleProvider.Color.textSecondary
        section2.contentContainer.addArrangedSubview(termsLabel)
        
        let termsButton = UIButton(type: .system)
        termsButton.setTitle("Read Full Terms", for: .normal)
        termsButton.titleLabel?.font = StyleProvider.fontWith(type: .medium, size: 14)
        termsButton.backgroundColor = StyleProvider.Color.highlightPrimary
        termsButton.setTitleColor(.white, for: .normal)
        termsButton.layer.cornerRadius = 8
        termsButton.translatesAutoresizingMaskIntoConstraints = false
        termsButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        section2.contentContainer.addArrangedSubview(termsButton)
        
        stackView.addArrangedSubview(section2)
        
        // Section 3: Help & Support
        let section3ViewModel = MockExpandableSectionViewModel.customMock(title: "Help & Support", isExpanded: false)
        let section3 = ExpandableSectionView(viewModel: section3ViewModel)
        
        let supportLabel = UILabel()
        supportLabel.text = "Our support team is available 24/7 to assist you with any questions or concerns you may have."
        supportLabel.numberOfLines = 0
        supportLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        supportLabel.textColor = StyleProvider.Color.textSecondary
        section3.contentContainer.addArrangedSubview(supportLabel)
        
        let contactStackView = UIStackView()
        contactStackView.axis = .vertical
        contactStackView.spacing = 8
        
        let emailLabel = createContactRow(icon: "envelope.fill", text: "support@example.com")
        let phoneLabel = createContactRow(icon: "phone.fill", text: "+1 (555) 123-4567")
        let chatLabel = createContactRow(icon: "message.fill", text: "Live Chat Available")
        
        contactStackView.addArrangedSubview(emailLabel)
        contactStackView.addArrangedSubview(phoneLabel)
        contactStackView.addArrangedSubview(chatLabel)
        
        section3.contentContainer.addArrangedSubview(contactStackView)
        
        stackView.addArrangedSubview(section3)
        
        // Section 4: Payment Methods
        let section4ViewModel = MockExpandableSectionViewModel.customMock(title: "Payment Methods", isExpanded: false)
        let section4 = ExpandableSectionView(viewModel: section4ViewModel)
        
        let paymentLabel = UILabel()
        paymentLabel.text = "We accept various payment methods for your convenience:"
        paymentLabel.numberOfLines = 0
        paymentLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        paymentLabel.textColor = StyleProvider.Color.textPrimary
        section4.contentContainer.addArrangedSubview(paymentLabel)
        
        let paymentOptions = ["Credit/Debit Cards", "PayPal", "Bank Transfer", "E-Wallets", "Cryptocurrency"]
        for option in paymentOptions {
            let optionLabel = createBulletPoint(text: option)
            section4.contentContainer.addArrangedSubview(optionLabel)
        }
        
        stackView.addArrangedSubview(section4)
        
        // Section 5: FAQ
        let section5ViewModel = MockExpandableSectionViewModel.customMock(title: "Frequently Asked Questions", isExpanded: false)
        let section5 = ExpandableSectionView(viewModel: section5ViewModel)
        
        let faqIntroLabel = UILabel()
        faqIntroLabel.text = "Find answers to common questions below:"
        faqIntroLabel.numberOfLines = 0
        faqIntroLabel.font = StyleProvider.fontWith(type: .regular, size: 14)
        faqIntroLabel.textColor = StyleProvider.Color.textSecondary
        section5.contentContainer.addArrangedSubview(faqIntroLabel)
        
        let faqStackView = UIStackView()
        faqStackView.axis = .vertical
        faqStackView.spacing = 12
        
        let faq1 = createFAQItem(
            question: "How do I create an account?",
            answer: "Click the 'Sign Up' button and follow the registration process."
        )
        let faq2 = createFAQItem(
            question: "Is my personal information secure?",
            answer: "Yes, we use industry-standard encryption to protect your data."
        )
        let faq3 = createFAQItem(
            question: "How long does withdrawal take?",
            answer: "Withdrawals are typically processed within 24-48 hours."
        )
        
        faqStackView.addArrangedSubview(faq1)
        faqStackView.addArrangedSubview(faq2)
        faqStackView.addArrangedSubview(faq3)
        
        section5.contentContainer.addArrangedSubview(faqStackView)
        
        stackView.addArrangedSubview(section5)
    }
    
    // MARK: - Helper Methods
    private func createContactRow(icon: String, text: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        let iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = StyleProvider.Color.highlightPrimary
        iconImageView.contentMode = .scaleAspectFit
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        
        containerView.addSubview(iconImageView)
        containerView.addSubview(label)
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            label.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            label.topAnchor.constraint(equalTo: containerView.topAnchor),
            label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        return containerView
    }
    
    private func createBulletPoint(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "• \(text)"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textColor = StyleProvider.Color.textSecondary
        label.numberOfLines = 0
        return label
    }
    
    private func createFAQItem(question: String, answer: String) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = StyleProvider.Color.backgroundSecondary
        containerView.layer.cornerRadius = 8
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
        
        let questionLabel = UILabel()
        questionLabel.text = question
        questionLabel.font = StyleProvider.fontWith(type: .semibold, size: 14)
        questionLabel.textColor = StyleProvider.Color.textPrimary
        questionLabel.numberOfLines = 0
        
        let answerLabel = UILabel()
        answerLabel.text = answer
        answerLabel.font = StyleProvider.fontWith(type: .regular, size: 13)
        answerLabel.textColor = StyleProvider.Color.textSecondary
        answerLabel.numberOfLines = 0
        
        stackView.addArrangedSubview(questionLabel)
        stackView.addArrangedSubview(answerLabel)
        
        containerView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        return containerView
    }
}

