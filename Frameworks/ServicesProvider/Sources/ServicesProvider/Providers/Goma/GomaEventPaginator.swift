//
//  File.swift
//  
//
//  Created by Ruben Roques on 23/02/2024.
//

import Foundation
import Combine

class GomaEventPaginator<T: Equatable> {
    
    var eventsGroupPublisher: AnyPublisher<[T], ServiceProviderError> {
        self.eventsGroupSubject.eraseToAnyPublisher()
    }
    
    var hasNextPagePublisher: AnyPublisher<Bool, ServiceProviderError> {
        self.hasNextPageSubject.eraseToAnyPublisher()
    }
    
    private var eventsGroupSubject = CurrentValueSubject<[T], ServiceProviderError>([])
    private var hasNextPageSubject = CurrentValueSubject<Bool, ServiceProviderError>(true)
    
    private let paginatorRequest: (Int) -> AnyPublisher<[T], ServiceProviderError>

    private var initialPage: Int
    private var currentPage: Int
    private var eventsPerPage: Int

    private var needsRefresh: Bool
    private var refreshTimer: Timer?

    private var cancellables = Set<AnyCancellable>()

    init(initialPage: Int = 1, 
         eventsPerPage: Int = 10,
         needsRefresh: Bool,
         request: @escaping (Int) -> AnyPublisher<[T], ServiceProviderError>) {
        
        self.paginatorRequest = request
        self.initialPage = initialPage
        self.currentPage = initialPage

        self.eventsPerPage = eventsPerPage
        self.needsRefresh = needsRefresh
        
        if self.needsRefresh {
            self.startRefreshTimer()
        }
        
        print("[GomaEventPaginator] init")
    }
    
    deinit {
        self.refreshTimer?.invalidate()
    }
    
    func requestInitialPage() {
        self.currentPage = 1
        self.eventsGroupSubject.send([])
        self.hasNextPageSubject.send(true)
        self.triggerRequest()
    }
    
    func requestNextPage() {
        self.currentPage = self.currentPage + 1
        self.triggerRequest()
    }
    
    private func triggerRequest() {
        self.paginatorRequest(self.currentPage)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    // We should keep eventsGroupSubject alive for the next pages
                    break
                case .failure(let error):
                    self?.eventsGroupSubject.send(completion: .failure(error))
                    self?.hasNextPageSubject.send(completion: .failure(error))
                }
            } receiveValue: { [weak self] events in
                let hasNextPage = events.count >= (self?.eventsPerPage ?? 0)
                self?.hasNextPageSubject.send(hasNextPage)
                self?.eventsGroupSubject.value.append(contentsOf: events)
            }
            .store(in: &self.cancellables)
    }
    
    private func startRefreshTimer() {
        self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            print("[GomaEventPaginator] Refresh timer triggered")

            self.refreshContents()
        }
    }
    
    func refreshContents() {
        let refreshPublishers = [self.initialPage ... self.currentPage].map({ index in
            self.paginatorRequest(self.currentPage)
                .replaceError(with: [])
        })
        
        Publishers.MergeMany(refreshPublishers)
            .sink { completion in
                print("[GomaEventPaginator] MergeMany completion: \(completion)")
            } receiveValue: { [weak self] events in
                let expectedEvents = (self?.currentPage ?? 0) * (self?.eventsPerPage ?? 0)
                let hasNextPage = events.count >= expectedEvents
                
                print("[GomaEventPaginator] Received \(events.count) events, expected \(expectedEvents) events")

                self?.hasNextPageSubject.send(hasNextPage)
                self?.eventsGroupSubject.send(events)
            }
            .store(in: &self.cancellables)

    }
    
}
