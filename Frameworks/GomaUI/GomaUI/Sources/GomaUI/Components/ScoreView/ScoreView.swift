import UIKit
import Combine
import SwiftUI

/// A view that displays a horizontal series of score cells for sports matches
public class ScoreView: UIView {
    
    // MARK: - Private Properties
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var loadingIndicator: UIActivityIndicatorView = Self.createLoadingIndicator()
    private lazy var emptyLabel: UILabel = Self.createEmptyLabel()
    
    // Conditional constraints for empty state
    private var emptyLabelConstraints: [NSLayoutConstraint] = []
    
    // MARK: - ViewModel
    private var viewModel: ScoreViewModelProtocol?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
        setupWithTheme()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
        setupConstraints()
        setupWithTheme()
    }
    
    // MARK: - Intrinsic Content Size
    public override var intrinsicContentSize: CGSize {
        let stackIntrinsicSize = containerStackView.intrinsicContentSize
        return CGSize(
            width: stackIntrinsicSize.width,
            height: 42 // Fixed height for score cells
        )
    }
    
    // MARK: - Configuration
    /// Configure the view with a ViewModel
    public func configure(with viewModel: ScoreViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
    }
    
    /// Clean up for reuse in collection views
    public func cleanupForReuse() {
        viewModel = nil
        cancellables.removeAll()
        clearScoreCells()
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        addSubview(containerStackView)
        addSubview(loadingIndicator)
        addSubview(emptyLabel)
        
        // Initial state
        loadingIndicator.isHidden = true
        emptyLabel.isHidden = true
        
        // Set content hugging and compression resistance
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Container stack view - trailing aligned, intrinsic width
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerStackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            
            // Loading indicator (centered)
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Create but don't activate empty label constraints yet
        emptyLabelConstraints = [
            emptyLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8)
        ]
    }
    
    private func setupWithTheme() {
        backgroundColor = .clear
        emptyLabel.textColor = StyleProvider.Color.secondaryColor
    }
    
    private func setupBindings() {
        guard let viewModel = viewModel else { return }
        
        cancellables.removeAll()
        
        // Bind visual state
        viewModel.visualStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateVisualState(state)
            }
            .store(in: &cancellables)
        
        // Bind score cells
        viewModel.scoreCellsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scoreCells in
                self?.updateScoreCells(scoreCells)
            }
            .store(in: &cancellables)
    }
    
    private func updateVisualState(_ state: ScoreViewVisualState) {
        // Deactivate empty label constraints first
        NSLayoutConstraint.deactivate(emptyLabelConstraints)
        
        switch state {
        case .idle:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            
        case .loading:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
            emptyLabel.isHidden = true
            
        case .display:
            containerStackView.isHidden = false
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = true
            
        case .empty:
            containerStackView.isHidden = true
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
            emptyLabel.isHidden = false
            // Only activate empty label constraints when showing empty state
            NSLayoutConstraint.activate(emptyLabelConstraints)
        }
        
        // Invalidate intrinsic content size when state changes
        invalidateIntrinsicContentSize()
    }
    
    private func updateScoreCells(_ scoreCells: [ScoreDisplayData]) {
        clearScoreCells()
        
        for scoreData in scoreCells {
            let cellView = ScoreCellView(data: scoreData)
            containerStackView.addArrangedSubview(cellView)
        }
        
        // Invalidate intrinsic content size when cells change
        invalidateIntrinsicContentSize()
    }
    
    private func clearScoreCells() {
        containerStackView.arrangedSubviews.forEach { view in
            containerStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}

// MARK: - Factory Methods
extension ScoreView {
    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.backgroundColor = .clear
        
        // Ensure the stack view hugs its content
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return stackView
    }
    
    private static func createLoadingIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = StyleProvider.Color.primaryColor
        indicator.hidesWhenStopped = true
        return indicator
    }
    
    private static func createEmptyLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No scores"
        label.font = StyleProvider.fontWith(type: .regular, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

// MARK: - ScoreCellView (Internal)
private class ScoreCellView: UIView {
    
    // MARK: - Private Properties
    private lazy var backgroundView: UIView = Self.createBackgroundView()
    private lazy var homeScoreLabel: UILabel = Self.createScoreLabel()
    private lazy var awayScoreLabel: UILabel = Self.createScoreLabel()
    
    private var widthConstraint: NSLayoutConstraint!
    private let data: ScoreDisplayData
    
    // MARK: - Initialization
    init(data: ScoreDisplayData) {
        self.data = data
        super.init(frame: .zero)
        setupSubviews()
        setupConstraints()
        configure(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(backgroundView)
        addSubview(homeScoreLabel)
        addSubview(awayScoreLabel)
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private func setupConstraints() {
        widthConstraint = backgroundView.widthAnchor.constraint(greaterThanOrEqualToConstant: 28)
        
        NSLayoutConstraint.activate([
            // Background view
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 42),
            widthConstraint,
            
            // Home score (top)
            homeScoreLabel.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            homeScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            homeScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            homeScoreLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Away score (bottom)
            awayScoreLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            awayScoreLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2),
            awayScoreLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -2),
            awayScoreLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    private func configure(with data: ScoreDisplayData) {
        homeScoreLabel.text = data.homeScore
        awayScoreLabel.text = data.awayScore
        applyStyle(data.style)
        updateScoreHighlighting()
    }
    
    private func applyStyle(_ style: ScoreCellStyle) {
        switch style {
        case .simple:
            widthConstraint.constant = 26
            homeScoreLabel.textColor = StyleProvider.Color.secondaryColor
            awayScoreLabel.textColor = StyleProvider.Color.secondaryColor
            backgroundView.backgroundColor = .clear
            backgroundView.layer.borderWidth = 0
            backgroundView.layer.borderColor = nil
            
        case .border:
            widthConstraint.constant = 26
            homeScoreLabel.textColor = StyleProvider.Color.textColor
            awayScoreLabel.textColor = StyleProvider.Color.textColor
            backgroundView.backgroundColor = .clear
            backgroundView.layer.borderWidth = 1
            backgroundView.layer.borderColor = StyleProvider.Color.primaryColor.cgColor
            
        case .background:
            widthConstraint.constant = 29
            homeScoreLabel.textColor = StyleProvider.Color.primaryColor
            awayScoreLabel.textColor = StyleProvider.Color.primaryColor
            backgroundView.backgroundColor = StyleProvider.Color.backgroundColor
            backgroundView.layer.borderWidth = 0
            backgroundView.layer.borderColor = nil
        }
    }
    
    private func updateScoreHighlighting() {
        // Only apply highlighting for simple style
        guard data.style == .simple else {
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 1.0
            return
        }
        
        // Compare scores as strings (preserving original logic)
        if data.homeScore > data.awayScore {
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 0.5
        } else if data.homeScore < data.awayScore {
            homeScoreLabel.alpha = 0.5
            awayScoreLabel.alpha = 1.0
        } else {
            homeScoreLabel.alpha = 1.0
            awayScoreLabel.alpha = 1.0
        }
    }
    
    // MARK: - Factory Methods
    private static func createBackgroundView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        return view
    }
    
    private static func createScoreLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = StyleProvider.fontWith(type: .bold, size: 15)
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }
}

// MARK: - SwiftUI Previews
@available(iOS 17.0, *)
#Preview("ScoreView - Tennis Scores") {
    PreviewUIView {
        let view = ScoreView()
        let viewModel = MockScoreViewModel.tennisMatch
        view.configure(with: viewModel)
        view.backgroundColor = StyleProvider.Color.backgroundColor
        return view
    }
    .frame(width: 300, height: 50)
}

@available(iOS 17.0, *)
#Preview("ScoreView - All States") {
    VStack(spacing: 20) {
        // Loading state
        PreviewUIView {
            let view = ScoreView()
            let viewModel = MockScoreViewModel.loading
            view.configure(with: viewModel)
            view.backgroundColor = StyleProvider.Color.backgroundColor
            return view
        }
        .frame(width: 300, height: 50)
        
        // Basketball scores
        PreviewUIView {
            let view = ScoreView()
            let viewModel = MockScoreViewModel.basketballMatch
            view.configure(with: viewModel)
            view.backgroundColor = StyleProvider.Color.backgroundColor
            return view
        }
        .frame(width: 300, height: 50)
        
        // Empty state
        PreviewUIView {
            let view = ScoreView()
            let viewModel = MockScoreViewModel.empty
            view.configure(with: viewModel)
            view.backgroundColor = StyleProvider.Color.backgroundColor
            return view
        }
        .frame(width: 300, height: 50)
    }
    .padding()
} 