//
//  UploadDocumentsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 25/01/2023.
//

import Foundation
import Combine
import ServicesProvider

class UploadDocumentsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    let supportedTypes = ["com.apple.iwork.pages.pages",
                          "com.apple.iwork.numbers.numbers",
                          "com.apple.iwork.keynote.key",
                          "public.image",
                          "com.apple.application",
                          "public.item",
                          "public.data",
                          "public.content",
                          "public.audiovisual-content",
                          "public.movie",
                          "public.audiovisual-content",
                          "public.video", "public.audio",
                          "public.text", "public.data",
                          "public.zip-archive",
                          "com.pkware.zip-archive",
                          "public.composite-content",
                          "public.text"]

    var selectedUploadDocumentCellId: String?

    var cachedCellViewModels: [String: UploadDocumentCellViewModel] = [:]

    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []

    var shouldReloadData: (() -> Void)?

    var hasLoadedDocumentTypes: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedUserDocuments: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    var kycStatusPublisher: AnyPublisher<KnowYourCustomerStatus?, Never> {
        return Env.userSessionStore.userKnowYourCustomerStatusPublisher.eraseToAnyPublisher()
    }

    init() {

        self.setupPublishers()

        self.getDocumentTypes()

        self.getKYCStatus()

    }

    private func setupPublishers() {

        Publishers.CombineLatest(self.hasLoadedDocumentTypes, self.hasLoadedUserDocuments)
            .sink(receiveValue: { [weak self] hasLoadedDocumentTypes, hasLoadedUserDocuments in
                if hasLoadedDocumentTypes && hasLoadedUserDocuments {
                    self?.isLoadingPublisher.send(false)
                    self?.shouldReloadData?()
                }
            })
            .store(in: &cancellables)
    }

    private func getDocumentTypes() {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.getDocumentTypes()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] documentTypesResponse in

                let requiredDocumentTypes = documentTypesResponse.documentTypes.filter({
                    $0.documentType == "IDENTITY_CARD" || $0.documentType == "OTHERS"
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.hasLoadedDocumentTypes.send(true)

                self?.getUserDocuments()
            })
            .store(in: &cancellables)
    }

    private func getUserDocuments() {

        Env.servicesProvider.getUserDocuments()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] userDocumentsResponse in

                print("USER DOCUMENTS RESPONSE: \(userDocumentsResponse)")

                let userDocuments = userDocumentsResponse.userDocuments

                if let requiredDocumentTypes = self?.requiredDocumentTypes {
                    self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
                }

            })
            .store(in: &cancellables)
    }

    private func processDocuments(documentTypes: [DocumentType], userDocuments: [UserDocument]) {

        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            let uploadedFiles = userDocuments.filter({
                $0.documentType == documentType.documentType
            }).map({ userDocument -> DocumentFileInfo in

                let userDocumentStatus = FileState(code: userDocument.status)

                return DocumentFileInfo(id: userDocument.documentType, name: userDocument.fileName, status: userDocumentStatus ?? .pendingApproved)
            })

            let documentInfo = DocumentInfo(id: documentType.documentType,
                                            typeName: documentTypeCode?.codeName ?? "",
                                            status: uploadedFiles.isEmpty ? .notReceived : .received,
                                            uploadedFiles: uploadedFiles)

            self.documents.append(documentInfo)
        }

        self.isLoadingPublisher.send(false)
        self.shouldReloadData?()
    }

    private func getKYCStatus() {
        // Request a forced refresh of the logged user profile
        Env.userSessionStore.refreshProfile()
    }
}
