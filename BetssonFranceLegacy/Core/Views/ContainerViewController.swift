//
//  ContainerViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 15/02/2022.
//

import UIKit

class ContainerViewController<T: UIView>: UIViewController {

    var containedView: T

    var containerType: ContainerType = .center
    enum ContainerType {
        case center
        case edges
    }

    init(containedView: T, containerType: ContainerType = .center) {
        self.containedView = containedView
        self.containerType = containerType

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containedView.translatesAutoresizingMaskIntoConstraints = false

        self.view.addSubview(containedView)

        if case .edges = self.containerType {
            NSLayoutConstraint.activate([
                self.view.leadingAnchor.constraint(equalTo: containedView.leadingAnchor),
                self.view.trailingAnchor.constraint(equalTo: containedView.trailingAnchor),
                self.view.topAnchor.constraint(equalTo: containedView.topAnchor),
                self.view.bottomAnchor.constraint(equalTo: containedView.bottomAnchor),
            ])
        }
        else {
            NSLayoutConstraint.activate([
                self.view.centerXAnchor.constraint(equalTo: containedView.centerXAnchor),
                self.view.centerYAnchor.constraint(equalTo: containedView.centerYAnchor),
            ])
        }
    }

}
