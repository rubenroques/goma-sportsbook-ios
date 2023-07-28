//
//  StoriesFullScreenViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/06/2023.
//

import Foundation
import UIKit

struct StoriesFullScreenViewModel {

    var storiesViewModels: [StoriesItemCellViewModel]
    var initialStoryId: String

    var initialIndex: Int {
        let index = self.storiesViewModels.firstIndex(where: {
            $0.id == self.initialStoryId
        })
        return Int(index ?? 0)
    }

    init(storiesViewModels: [StoriesItemCellViewModel], initialStoryId: String) {
        self.storiesViewModels = storiesViewModels
        self.initialStoryId = initialStoryId
    }
}

class StoriesFullScreenViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var cubicScrollView: CubicScrollView = Self.createCubicScrollView()

    private var pagesDictionary: [Int: StoriesFullScreenItemView] = [:]
    private var currentPage: Int = 0

    private var viewDidAlreadyAppear: Bool = false
    private var viewModel: StoriesFullScreenViewModel

    var markReadAction: ((String) -> Void)?

    // MARK: - Lifetime and Cycle
    init(viewModel: StoriesFullScreenViewModel) {
        self.viewModel = viewModel
        self.currentPage = viewModel.initialIndex

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()


        self.setupSubviews()
        self.setupWithTheme()

        self.cubicScrollView.cubeDelegate = self

        var items: [StoriesFullScreenItemView] = []

        for (index, storyViewModel) in self.viewModel.storiesViewModels.enumerated() {

            let storiesFullScreenItemViewModel = StoriesFullScreenItemViewModel(storyCellViewModel: storyViewModel)

            let storiesFullScreenItemView = StoriesFullScreenItemView(index: index, viewModel: storiesFullScreenItemViewModel)
            
            storiesFullScreenItemView.tag = index
            storiesFullScreenItemView.previousPageRequestedAction = { [weak self] in
                self?.goToPreviousPageItem()
            }
            storiesFullScreenItemView.nextPageRequestedAction = { [weak self] storyId in

                if let storyId = storyId {
                    if let lastViewModel = self?.viewModel.storiesViewModels.last,
                       lastViewModel.id == storyId {
                        self?.closeFullscreen()
                    }
                    else {
                        self?.goToNextPageItem()
                    }
                }
                else {
                    self?.goToNextPageItem()
                }
            }
            storiesFullScreenItemView.closeRequestedAction = { [weak self] in
                self?.closeFullscreen()
            }

            storiesFullScreenItemView.linkRequestAction = { [weak self] url in
                self?.openInternalWebview(onURL: url)
            }

            storiesFullScreenItemView.markedReadAction = { [weak self] storyId in
                self?.markReadAction?(storyId)
            }

            items.append(storiesFullScreenItemView)

            self.pagesDictionary[index] = storiesFullScreenItemView
        }

        self.cubicScrollView.addChildViews(items)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.cubicScrollView.alpha = 0.0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !viewDidAlreadyAppear {

            self.cubicScrollView.setContentOffsetToIndex(self.viewModel.initialIndex)

            if let page = self.pagesDictionary[self.viewModel.initialIndex ?? 0] {
                page.startProgress()
            }

            UIView.animate(withDuration: 0.1) {
                self.cubicScrollView.alpha = 1.0
            }

            self.viewDidAlreadyAppear = true
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = .black

        self.cubicScrollView.backgroundColor = .black
    }

    func goToNextPageItem() {
        self.cubicScrollView.scrollToNextPage(animated: true)
    }

    func goToPreviousPageItem() {
        self.cubicScrollView.scrollToPreviousPage(animated: true)
    }

    func closeFullscreen() {
        self.dismiss(animated: true, completion: nil)
    }

    func openInternalWebview(onURL url: URL) {
        let internalBrowserViewController = InternalBrowserViewController(url: url, fullscreen: false)
        let navigationViewController = Router.navigationController(with: internalBrowserViewController)
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @objc func handleSwipeDown(_ recognizer: UISwipeGestureRecognizer) {
        if recognizer.state == .ended {
            self.closeFullscreen()
        }
    }

}

extension StoriesFullScreenViewController: CubicScrollViewDelegate {

    func cubeViewDidScroll(_ cubeView: CubicScrollView) {

    }

    func cubeViewDidEndScrolling(_ cubeView: CubicScrollView, toPageIndex pageIndex: Int) {
        for key in self.pagesDictionary.keys.filter({ $0 != pageIndex }) {
            if let oldPage = self.pagesDictionary[key] {
                oldPage.resetProgress()
            }
        }

        if self.currentPage == pageIndex {
            return
        }
        
        self.currentPage = pageIndex

        if let page = self.pagesDictionary[pageIndex] {
            page.startProgress()
        }
    }

    @objc func cubeViewStartDragging(_ cubeView: CubicScrollView) {
        if let page = self.pagesDictionary[self.currentPage] {
            page.pauseProgress()
        }
    }

    @objc func cubeViewEndDragging(_ cubeView: CubicScrollView) {
        if let page = self.pagesDictionary[self.currentPage] {
            page.resumeProgress()
        }
    }

}

extension StoriesFullScreenViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCubicScrollView() -> CubicScrollView {
        let scrollView = CubicScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.bottomSafeAreaView)
        self.view.addSubview(self.cubicScrollView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.cubicScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.cubicScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.cubicScrollView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.cubicScrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])

    }

}
