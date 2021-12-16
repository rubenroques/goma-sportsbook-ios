import UIKit

public class TabularViewController: UIViewController {

    public var delegate: TabularViewDelegate?
    public var dataSource: TabularViewDataSource

    public var barColor: UIColor = .black {
        didSet {
            barView.backgroundColor = barColor
        }
    }

    public var sliderBarColor: UIColor = .white {
        didSet {
            barView.barColor = sliderBarColor
        }
    }

    public var textColor: UIColor = .white {
        didSet {
            barView.textColor = textColor
            barView.reloadBarButtons()
        }
    }

    public var textFont: UIFont = UIFont.systemFont(ofSize: 12) {
        didSet {
            barView.textFont = textFont
        }
    }

    // ===========
    private var barView: TabularBarView = {
        let view = TabularBarView()
        view.backgroundColor = .black
        return view
    }()

    private var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public var currentIndex: Int {
        self.currentPage
    }

    private var savedIndex: Int?

    private var currentPage: Int = 0 {
        didSet {
            self.delegate?.didScroll(toIndex: currentPage)
            if let viewControllerAtIndex = self.viewControllers[safe: currentPage] {
                self.delegate?.didScroll(toViewController: viewControllerAtIndex)
            }
        }
    }

    private var baseScrollView: UIScrollView = {
        var scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        // scrollView.bounces = false
        // scrollView.delaysContentTouches = true
        return scrollView
    }()

    private var baseStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.axis = .horizontal
        stackView.spacing = 0
        return stackView
    }()

    private var viewControllers: [UIViewController] = []

    public init(dataSource: TabularViewDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear

        self.addSubviews()

        self.savedIndex = nil

        self.viewControllers = dataSource.contentViewControllers()
        self.reloadContent()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.reloadContent()
    }

    public override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        self.viewControllers.forEach({ $0.willMove(toParent: parent) })
    }

    public override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        self.viewControllers.forEach({ $0.didMove(toParent: parent) })
    }

    private func addSubviews() {

        self.view.removeConstraints(self.view.constraints)
        self.barView.removeFromSuperview()
        self.baseScrollView.removeFromSuperview()

        self.view.addSubview(barView)
        self.view.addSubview(self.baseScrollView)

        self.baseScrollView.addSubview(self.baseStackView)

        NSLayoutConstraint.activate([

            barView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            barView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            barView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            barView.heightAnchor.constraint(equalToConstant: 35),

            baseScrollView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 0),
            baseScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            baseScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
            baseScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),

            baseScrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: baseStackView.heightAnchor),

            baseStackView.leadingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.leadingAnchor),
            baseStackView.topAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.topAnchor),
            baseStackView.trailingAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.trailingAnchor),
            baseStackView.bottomAnchor.constraint(equalTo: baseScrollView.contentLayoutGuide.bottomAnchor)
        ])

        self.baseScrollView.delegate = self
        self.barView.dataSource = self
        self.barView.delegate = self
        self.barView.barColor = .white

    }

    public func reloadContent(forcePositionReload: Bool = false) {

        if !isViewLoaded {
            return
        }

        if forcePositionReload {
            self.savedIndex = nil
        }

        for viewController in self.viewControllers {
            viewController.willMove(toParent: nil)
            viewController.view.willMove(toSuperview: nil)
            viewController.view.removeFromSuperview()
            viewController.didMove(toParent: nil)
        }

        for arrangedSubview in  baseStackView.arrangedSubviews {
            baseStackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }

        self.viewControllers = self.dataSource.contentViewControllers()

        for viewController in self.viewControllers {

            viewController.view.translatesAutoresizingMaskIntoConstraints = false
            viewController.willMove(toParent: self)
            self.addChild(viewController)
            baseStackView.addArrangedSubview(viewController.view)
            viewController.didMove(toParent: self)

            NSLayoutConstraint.activate([
                viewController.view.widthAnchor.constraint(equalTo: self.baseScrollView.frameLayoutGuide.widthAnchor),
                viewController.view.heightAnchor.constraint(equalTo: self.baseScrollView.frameLayoutGuide.heightAnchor)
            ])
        }

        self.currentPage = 0

        self.barView.reloadBarButtons()

        if let savedIndex = self.savedIndex, self.viewControllers.count > savedIndex {
            self.scrollContentToIndex(savedIndex, animated: false)
            self.barView.scrollToIndex(savedIndex, animated: false)
        }
        else if self.viewControllers.count > self.dataSource.defaultPage() {
            self.scrollContentToIndex(self.dataSource.defaultPage(), animated: false)
            self.barView.scrollToIndex(self.dataSource.defaultPage(), animated: false)
        }
        else {
            self.scrollContentToIndex(0, animated: false)
            self.barView.scrollToIndex(0, animated: false)
        }
    }

    public func scrollToIndex(_ index: Int, animated: Bool = true) {
        self.scrollContentToIndex(index, animated: animated)
        self.barView.scrollToIndex(index, animated: animated)
    }

    private func scrollContentToIndex(_ index: Int, animated: Bool = true) {

        let oldPage = self.currentPage

        if let oldVIewController = self.viewControllers[safe:oldPage] {
            oldVIewController.viewWillDisappear(true)
        }

        if let newVIewController = self.viewControllers[safe: self.currentPage] {
            newVIewController.viewWillAppear(true)
        }

        let position = CGPoint(x: self.baseScrollView.frame.size.width*CGFloat(index), y: 0.0)
        self.baseScrollView.setContentOffset(position, animated: animated)

        self.currentPage = index

        if let oldVIewController = self.viewControllers[safe:oldPage] {
            oldVIewController.viewDidDisappear(true)
        }
        if let newVIewController = self.viewControllers[safe: self.currentPage] {
            newVIewController.viewDidAppear(true)
        }

    }

    public func setBarDistribution(_ barDistribution: TabularBarView.BarDistribution) {
        self.barView.barDistribution = barDistribution
    }

    public func disableScroll() {
        self.baseScrollView.isScrollEnabled = false
    }

    public func enableScroll() {
        self.baseScrollView.isScrollEnabled = true
    }

}

extension TabularViewController: TabularBarDataSource {

    public func numberOfButtons() -> Int {
        return dataSource.numberOfButtons()
    }

    public func titleForButton(atIndex index: Int) -> String {
        return dataSource.titleForButton(atIndex: index)
    }
}

extension TabularViewController: TabularBarDelegate {

    public func didTapButton(atIndex index: Int) {
        self.savedIndex = index
        self.scrollContentToIndex(index)
    }

}

extension TabularViewController: UIScrollViewDelegate {

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
        self.currentPage = index
        self.savedIndex = index
        self.barView.scrollToIndex(self.currentPage, animated: true)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {

        let offsetX = scrollView.contentOffset.x
        let contentWidth = scrollView.contentSize.width
        let offsetThreshold: CGFloat = 30

        if offsetX < -offsetThreshold {
            self.delegate?.didScrollOverEdgeLeft()
        }
        else if (offsetX - (contentWidth - scrollView.frame.size.width)) > offsetThreshold {
            self.delegate?.didScrollOverEdgeRight()
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

    }
}
