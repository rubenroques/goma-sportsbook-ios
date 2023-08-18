//
//  File.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/06/2023.
//

import Foundation
import UIKit
import Combine
import ServicesProvider

class TopCompetitionsLineCellViewModel {

    var topCompetitions: [TopCompetitionItemCellViewModel] {
        return self.topCompetitionsSubject.value
    }

    var topCompetitionsPublisher: AnyPublisher<[TopCompetitionItemCellViewModel], Never> {
        return self.topCompetitionsSubject.eraseToAnyPublisher()
    }

    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return self.isLoadingSubject.eraseToAnyPublisher()
    }

    private var isLoadingSubject: CurrentValueSubject<Bool, Never> = .init(false)
    private var topCompetitionsSubject: CurrentValueSubject<[TopCompetitionItemCellViewModel], Never> = .init([])
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.requestTopCompetitions()
    }

    private func requestTopCompetitions() {

        self.isLoadingSubject.send(true)

        Env.servicesProvider.getTopCompetitions()
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("TopCompetitionsLineCellViewModel getTopCompetitionsIdentifier error: \(error)")
                }
                self?.isLoadingSubject.send(false)
            }, receiveValue: { [weak self] topCompetitions in
                let convertedCompetitions = self?.convertTopCompetitions(topCompetitions) ?? []
                self?.topCompetitionsSubject.send(convertedCompetitions)
            })
            .store(in: &cancellables)

    }

    private func processTopCompetitions(topCompetitions: [TopCompetitionPointer]) -> [String: [String]] {
        var competitionsIdentifiers: [String: [String]] = [:]
        for topCompetition in topCompetitions {
            let competitionComponents = topCompetition.competitionId.components(separatedBy: "/")
            let competitionName = competitionComponents[competitionComponents.count - 2].lowercased()
            if let competitionId = competitionComponents.last {
                if let topCompetition = competitionsIdentifiers[competitionName] {
                    if !topCompetition.contains(where: {
                        $0 == competitionId
                    }) {
                        competitionsIdentifiers[competitionName]?.append(competitionId)
                    }

                }
                else {
                    competitionsIdentifiers[competitionName] = [competitionId]
                }
            }
        }
        return competitionsIdentifiers
    }

    private func convertTopCompetitions(_ topCompetitions: [TopCompetition]) -> [TopCompetitionItemCellViewModel] {
        return topCompetitions.map { pointer -> TopCompetitionItemCellViewModel? in
            let mappedSport = ServiceProviderModelMapper.sport(fromServiceProviderSportType: pointer.sportType)
            if let pointerCountry = pointer.country {
                let mappedCountry = ServiceProviderModelMapper.country(fromServiceProviderCountry: pointerCountry)
                return TopCompetitionItemCellViewModel(id: pointer.id,
                                                       name: pointer.name,
                                                       sport: mappedSport,
                                                       country: mappedCountry)
            }
            return nil
        }
        .compactMap({ $0 })

    }

}

class TopCompetitionsLineTableViewCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedItemAction: (String) -> Void = { _ in }

    var viewModel: TopCompetitionsLineCellViewModel?
    var cachedCellViewModels: [String: TopCompetitionItemCellViewModel] = [:]

    private let cellHeight: CGFloat = 124
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 14

        var collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView(style: .medium)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        return loadingView
    }()

    private var cancellables = Set<AnyCancellable>()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupSubviews()
        self.setupWithTheme()
    }

    @available(iOS, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.backgroundColor = .clear
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear

        self.collectionView.backgroundView?.backgroundColor = .clear
        self.collectionView.backgroundColor = .clear

        self.loadingView.color = .gray
    }

    private func setupSubviews() {

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(TopCompetitionItemCollectionViewCell.self,
                                     forCellWithReuseIdentifier: TopCompetitionItemCollectionViewCell.identifier)

        self.contentView.addSubview(self.collectionView)
        self.contentView.addSubview(self.loadingView)

        NSLayoutConstraint.activate([
            self.collectionView.heightAnchor.constraint(equalToConstant: self.cellHeight),
            self.collectionView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.collectionView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: 0),

            self.loadingView.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor),
        ])
    }

    func reloadData() {
        self.collectionView.reloadData()
    }

    func configure(withViewModel viewModel: TopCompetitionsLineCellViewModel) {

        self.viewModel = viewModel

        self.viewModel?.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &self.cancellables)

        self.viewModel?.topCompetitionsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &self.cancellables)

    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // Return the number of items in your collection view
        return self.viewModel?.topCompetitions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueCellType(TopCompetitionItemCollectionViewCell.self, indexPath: indexPath),
            let cellViewModel = self.viewModel?.topCompetitions[safe: indexPath.row]
        else {
            fatalError()
        }
        cell.configureWithViewModel(cellViewModel)
        cell.selectedItemAction = { [weak self] viewModel in
            self?.selectedItemAction(viewModel.id)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        return CGSize(width: 125, height: 80)
    }

}
