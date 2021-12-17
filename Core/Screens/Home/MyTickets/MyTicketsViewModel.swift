//
//  MyTicketsViewModel.swift
//  Sportsbook
//
//  Created by Ruben Roques on 17/12/2021.
//

import Foundation
import Combine

class MyTicketsViewModel: NSObject {

    private var selectedMyTicketsTypeIndex: Int = 0
    var myTicketsTypePublisher: CurrentValueSubject<MyTicketsType, Never> = .init(.resolved)
    enum MyTicketsType {
        case resolved
        case opened
        case won
    }

    private var cancellables = Set<AnyCancellable>()

    override init() {

        super.init()

        myTicketsTypePublisher.sink { [weak self] myTicketsType in
            switch myTicketsType {
            case .resolved: self?.selectedMyTicketsTypeIndex = 0
            case .opened: self?.selectedMyTicketsTypeIndex = 1
            case .won: self?.selectedMyTicketsTypeIndex = 2
            }
        }
        .store(in: &cancellables)
    }

    func setMyTicketsType(_ type: MyTicketsType) {
        self.myTicketsTypePublisher.value = type
    }

    func isTicketsTypeSelected(forIndex index: Int) -> Bool {
        return index == selectedMyTicketsTypeIndex
    }

}
