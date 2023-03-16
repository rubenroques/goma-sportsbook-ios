//
//  File.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import UIKit
import Theming

public class SearchCompletionView: UIView {

    public var didSelectSearchCompletion: (AddressSearchResult) -> Void = { _ in }
    lazy var contentView: UIView = Self.createContentView()
    lazy var stackView: UIStackView = Self.createStackView()

    private var clickableViewsIndexes: [Int: UIView] = [:]
    private var searchCompletions: [Int: AddressSearchResult] = [:]

    public init() {
        super.init(frame: .zero)

        self.commonInit()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required public override init(frame: CGRect) {
        fatalError()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func commonInit() {
        self.setupSubviews()

        let placeholderView = UIView()
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        placeholderView.backgroundColor = .clear

        NSLayoutConstraint.activate([
            placeholderView.heightAnchor.constraint(equalToConstant: 1)
        ])
        self.stackView.addArrangedSubview(placeholderView)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.stackView.backgroundColor = .clear

        for view in clickableViewsIndexes.values {
            view.backgroundColor = AppColor.backgroundSecondary
            for subview in view.subviews {
                if let label = subview as? UILabel {
                    label.textColor = AppColor.textPrimary
                }
            }
        }
    }

    public override var intrinsicContentSize: CGSize {
        return self.stackView.intrinsicContentSize
    }

    func presentResults(_ results: [AddressSearchResult]) {
        self.clearResults()

        for (index, searchCompletion) in results.enumerated() {
            let clicableView = Self.createClicableView(withText: searchCompletion.title, withTag: index)
            self.stackView.addArrangedSubview(clicableView)

            self.clickableViewsIndexes[index] = clicableView
            self.searchCompletions[index] = searchCompletion

            clicableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClicableView(_:))))
        }

        self.setupWithTheme()

        self.invalidateIntrinsicContentSize()
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    func clearResults() {
        for clickableView in clickableViewsIndexes.values {
            clickableView.removeFromSuperview()
        }
        self.clickableViewsIndexes = [:]
        self.searchCompletions = [:]
    }

    @IBAction func didTapClicableView(_ sender: UITapGestureRecognizer? = nil) {
        guard let tag = sender?.view?.tag else { return }

        if let searchCompletion = self.searchCompletions[tag] {
            self.didSelectSearchCompletion(searchCompletion)
        }
    }

}

extension SearchCompletionView {

    private static func createContentView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .vertical)
        return stackView
    }

    private static func createClicableView(withText text: String, withTag tag: Int) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.tag = tag
        view.backgroundColor = AppColor.backgroundSecondary
        view.layer.cornerRadius = 8

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.font = AppFont.with(type: .semibold, size: 14)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 38),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        return view
    }

    func setupSubviews() {

        self.initConstraints()
    }

    func initConstraints() {

        self.addSubview(self.contentView)

        self.contentView.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor),
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            self.stackView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 2),
            self.stackView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -2),
        ])

    }

}

