//
//  CasinoViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 13/06/2022.
//

import Foundation
import Combine

class CasinoViewModel: NSObject {

    var isUserLoggedPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    private var cancellables = Set<AnyCancellable>()
    
    var refreshPublisher = PassthroughSubject<Void, Never>.init()
    private var homeViewTemplateDataSource: HomeViewTemplateDataSource
    var store: HomeStore = HomeStore()
    
    override init() {
        
        if let homeFeedTemplate = Env.appSession.homeFeedTemplate {
            self.homeViewTemplateDataSource = DynamicHomeViewTemplateDataSource(store: self.store, homeFeedTemplate: homeFeedTemplate)
        }
        else {
            self.homeViewTemplateDataSource = StaticHomeViewTemplateDataSource(store: self.store)
        ()
        }
            super.init()
        self.setupPublishers()
    }

    func setupPublishers() {


        Env.userSessionStore.userSessionPublisher
            .receive(on: DispatchQueue.main)
            .map({ $0 != nil })
            .sink(receiveValue: { [weak self] isUserLoggedIn in
                self?.isUserLoggedPublisher.send(isUserLoggedIn)
            })
            .store(in: &cancellables)
        
       
    }
    
    func refresh() {
        self.setupPublishers()
       
    }

}
