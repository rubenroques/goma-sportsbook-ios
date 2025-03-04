//
//  DebugViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/08/2021.
//

import UIKit

class DebugViewController: UIViewController {

    var isBeingDismissedAction: ((Bool) -> Void)?
    let debugTableViewController = StaticTableViewController<DebugTableViewDescription>(style: .grouped)

    init() {
        super.init(nibName: "DebugViewController", bundle: nil)
        self.title = "Debug"
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        debugTableViewController.selectionCallback = { [weak self] action, viewController in
            if let indexPath = viewController.tableView.indexPathForSelectedRow {
                viewController.tableView.deselectRow(at: indexPath, animated: true)
            }

            switch action {
            case .networking:
                self?.openNetworkingLogs()
            case .globalLogs:
                self?.openAppLogs()
            default:
                ()
            }

        }

        self.addChildViewController(debugTableViewController, toView: self.view)

        let close = UIBarButtonItem(title: localized("close"), style: .plain, target: self, action: #selector(closeDebugViewController))
        navigationItem.rightBarButtonItems = [close]
    }

    @objc func closeDebugViewController() {
        self.dismiss(animated: true, completion: nil)
        self.isBeingDismissedAction?(true)
    }

    func openNetworkingLogs() {

    }

    func openAppLogs() {
        self.navigationController?.pushViewController(LogViewerViewController(), animated: true)
    }

}
