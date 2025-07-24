//
//  RibDocsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2023.
//

import Foundation
import Combine
import ServicesProvider

class RibDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedDocumentTypes: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedUserDocuments: CurrentValueSubject<Bool, Never> = .init(false)
    var hasDocumentsProcessed: CurrentValueSubject<Bool, Never> = .init(false)

    var isLocked: CurrentValueSubject<Bool, Never> = .init(false)

    var kycStatusPublisher: AnyPublisher<KnowYourCustomerStatus?, Never> {
        return Env.userSessionStore.userKnowYourCustomerStatusPublisher.eraseToAnyPublisher()
    }
    
    var ibanPaymentsDetails: [BankPaymentDetail] = []
    
    var shouldReloadData: (() -> Void)?

    let dateFormatter = DateFormatter()

    init() {

        self.getKYCStatus()

        // self.getDocumentTypes()
        
        self.getPaymentInfo()
    }
    
    private func getPaymentInfo() {

        Env.servicesProvider.getPaymentInformation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENT INFO ERROR: \(error)")

                }
                
                self?.getDocumentTypes()

            }, receiveValue: { [weak self] paymentInfo in
                print("PAYMENT INFO: \(paymentInfo)")

                let paymentDetails = paymentInfo.data.filter({
                    $0.details.isNotEmpty
                })

                if paymentDetails.isNotEmpty {

                    let bankPaymentDetails = paymentDetails.filter({
                        $0.type == "BANK"
                    })
                    
                    // Using all the IBAN's associated
                    for bankPaymentDetail in bankPaymentDetails {
                        
                        let ibanPaymentDetails = bankPaymentDetail.details.filter({
                            $0.key == "IBAN"
                        })
                        
                        self?.ibanPaymentsDetails.append(contentsOf: ibanPaymentDetails)
                    }
                    
                    self?.ibanPaymentsDetails.sort { $0.id > $1.id }
                    
                    // If using only the priorityIBAN
//                    if let priorityIbanDetail = bankPaymentDetails.min(by: { $0.priority ?? 0 < $1.priority ?? 1 }),
//                        let ibanPaymentDetail = priorityIbanDetail.details.filter({
//                            $0.key == "IBAN"
//                        }).first {
//                            
//                        self?.ibanPaymentDetails = ibanPaymentDetail
//                    }

                }

            })
            .store(in: &cancellables)
    }

    private func getKYCStatus() {
        Env.userSessionStore.refreshProfile()
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

                let documentTypes = documentTypesResponse

                let requiredDocumentTypes = documentTypesResponse.documentTypes.filter({
                    $0.documentTypeGroup == .rib
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.hasLoadedDocumentTypes.send(true)

                self?.getUserDocuments()
            })
            .store(in: &cancellables)
    }

    private func getUserDocuments() {

        self.isLoadingPublisher.send(true)

        self.hasDocumentsProcessed.send(false)

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

            if let documentTypeGroup = documentType.documentTypeGroup {

                let mappedDocumentTypeGroup = ServiceProviderModelMapper.documentTypeGroup(fromServiceProviderDocumentTypeGroup: documentTypeGroup)

                let uploadedFiles = userDocuments.filter({
                    $0.documentType == documentType.documentType
                }).enumerated().map({ index, userDocument -> DocumentFileInfo in

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)
                    
                    var documentName = localized("iban")
                    
                    if let ibanPaymentDetails = self.ibanPaymentsDetails[safe: index] {
                        
                        if ibanPaymentDetails.value.count >= 5 {
                            let cutIban = String(ibanPaymentDetails.value.suffix(5))
                            
                            let ibanSecured = "\(localized("iban")) **\(cutIban)"
                            
                            documentName = ibanSecured

                        }
                    }

                    return DocumentFileInfo(id: userDocument.documentType,
                                            name: documentName,
                                            status: userDocumentStatus ?? .pendingApproved,
                                            uploadDate: uploadDate ?? Date(),
                                            documentTypeGroup: mappedDocumentTypeGroup)
                })

                var existingDocumentInfo: DocumentInfo?

                for document in self.documents {
                    if let typeGroup = document.typeGroup,
                       typeGroup == mappedDocumentTypeGroup {
                        existingDocumentInfo = document
                    }
                }

                if let existingDocumentInfo {
                    var documentInfoIndex = self.documents.firstIndex(where: {
                        $0.id == existingDocumentInfo.id
                    })

                    if let index = documentInfoIndex {
                        var documentFileInfo = self.documents[index]

                        documentFileInfo.uploadedFiles.append(contentsOf: uploadedFiles)

                        self.documents[index] = documentFileInfo

                    }
                }
                else {
                    let documentInfo = DocumentInfo(id: documentType.documentType,
                                                    typeName: documentTypeCode?.codeName ?? "",
                                                    status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                    uploadedFiles: uploadedFiles,
                                                    typeGroup: mappedDocumentTypeGroup)

                    self.documents.append(documentInfo)
                }

            }
            else {

                let uploadedFiles = userDocuments.filter({
                    $0.documentType == documentType.documentType
                }).map({ userDocument -> DocumentFileInfo in

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)

                    return DocumentFileInfo(id: userDocument.documentType,
                                            name: userDocument.fileName ?? "",
                                            status: userDocumentStatus ?? .pendingApproved,
                                            uploadDate: uploadDate ?? Date(),
                                            documentTypeGroup: .none)
                })

                var existingDocumentInfo: DocumentInfo?

                for document in self.documents {
                    if document.id == documentType.documentType  {
                        existingDocumentInfo = document
                    }
                }

                if let existingDocumentInfo {
                    var documentInfoIndex = self.documents.firstIndex(where: {
                        $0.id == existingDocumentInfo.id
                    })

                    if let index = documentInfoIndex {
                        var documentFileInfo = self.documents[index]

                        documentFileInfo.uploadedFiles.append(contentsOf: uploadedFiles)

                        self.documents[index] = documentFileInfo

                    }
                }
                else {
                    let documentInfo = DocumentInfo(id: documentType.documentType,
                                                    typeName: documentTypeCode?.codeName ?? "",
                                                    status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                    uploadedFiles: uploadedFiles)

                    self.documents.append(documentInfo)
                }

            }
        }

        self.isLoadingPublisher.send(false)

        self.hasLoadedUserDocuments.send(false)

        self.hasDocumentsProcessed.send(true)

        self.shouldReloadData?()
    }

    func refreshDocuments() {
        self.documents = []
        self.ibanPaymentsDetails = []
        self.requiredDocumentTypes = []
        self.getPaymentInfo()
    }

}
