//
//  SportsViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine

class SportsViewController: UIViewController {

    @IBOutlet private weak var filtersBarBaseView: UIView!
    @IBOutlet private weak var filtersSeparatorLineView: UIView!
    @IBOutlet private weak var tableView: UITableView!

    var cancellables = Set<AnyCancellable>()
    
    private enum ScreenState {
        case loading
        case error
        case data
    }

    init() {
        super.init(nibName: "SportsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        self.filtersBarBaseView.backgroundColor = UIColor.App.contentBackgroundColor
        self.filtersSeparatorLineView.backgroundColor = UIColor.App.separatorLineColor
        self.filtersSeparatorLineView.alpha = 0.25
        
        self.tableView.backgroundColor = UIColor.App.contentBackgroundColor
        self.tableView.backgroundView?.backgroundColor = UIColor.App.contentBackgroundColor
    }

    private func commonInit() {

        let sportType = SportType.football

        print("Clock-Go!: \(Date())")

        Env.eventsStore.getMatches(sportType: sportType)
            .receive(on: DispatchQueue.main)
            .sink { matches in

                print("Clock-Done!: \(Date())")
                //print(matches)

            }
            .store(in: &cancellables)

    }

}
