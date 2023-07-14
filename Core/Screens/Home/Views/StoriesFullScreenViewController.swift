//
//  StoriesFullScreenViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/06/2023.
//

import Foundation
import UIKit

struct StoriesFullScreenViewModel {

}

class StoriesFullScreenViewController: UIViewController {

    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var cubicScrollView: CubicScrollView = Self.createCubicScrollView()

    private var pagesDictionary: [Int: StoriesFullScreenItemView] = [:]
    private var currentPage: Int = 0

    private var viewModel: StoriesFullScreenViewModel

    // MARK: - Lifetime and Cycle
    init(viewModel: StoriesFullScreenViewModel) {
        self.viewModel = viewModel

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
        for index in 0...5 {

            let viewModel: StoriesFullScreenItemViewModel

            if index == 2 || index == 5 {
                viewModel = StoriesFullScreenItemViewModel(videoSourceURL: URL(string: "https://getsamplefiles.com/download/mp4/sample-2.mp4")!)
            }
            else {
                viewModel = StoriesFullScreenItemViewModel(imageSourceURL: URL(string: "https://media.idownloadblog.com/wp-content/uploads/2019/08/sports-wallpaper-basketball-green-city-sports-art-nba-iphone-X.jpg")!)
            }

            let storiesFullScreenItemView = StoriesFullScreenItemView(viewModel: viewModel)
            storiesFullScreenItemView.tag = index
            storiesFullScreenItemView.previousPageRequestedAction = { [weak self] in
                self?.goToPreviousPageItem()
            }
            storiesFullScreenItemView.nextPageRequestedAction = { [weak self] in
                self?.goToNextPageItem()
            }
            storiesFullScreenItemView.closeRequestedAction = { [weak self] in
                self?.closeFullscreen()
            }

            items.append(storiesFullScreenItemView)

            self.pagesDictionary[index] = storiesFullScreenItemView
        }

        self.cubicScrollView.addChildViews(items)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown(_:)))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let page = self.pagesDictionary[0] {
            page.startProgress()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = .black

        self.cubicScrollView.backgroundColor = .clear
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
        //        scrollView.isPagingEnabled = true
        //        scrollView.showsVerticalScrollIndicator = false
        //        scrollView.showsHorizontalScrollIndicator = false
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
