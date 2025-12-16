//
//  IBANProofViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation
import Combine
import ServicesProvider

class IBANProofViewModel {

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

    var cachedCellViewModels: [String: UploadDocumentCellViewModel] = [:]

    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []

    var selectedUploadDocumentCellId: String?

    var shouldReloadData: (() -> Void)?

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var shouldShowAlert: ((AlertType, String) -> Void)?
    var shouldShowSuccessScreen: (() -> Void)?

    let dateFormatter = DateFormatter()

    init() {

        self.getDocumentTypes()

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
                    print("DOCUMENT TYPES ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] documentTypesResponse in

                let requiredDocumentTypes = documentTypesResponse.documentTypes.filter({
                    $0.documentType == "RIB"
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: [])
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

                self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)
                
                return DocumentFileInfo(id: userDocument.documentType,
                                        name: userDocument.fileName ?? "",
                                        status: userDocumentStatus ?? .pendingApproved,
                                        uploadDate: uploadDate ?? Date(),
                                        documentTypeGroup: .rib)
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

    func addPaymentInformation(iban: String) {

        self.isLoadingPublisher.send(true)

        let fieldsInfo = """
                        {
                        "IBAN":"\(iban)"
                        }
                        """

        Env.servicesProvider.addPaymentInformation(type: "BANK", fields: fieldsInfo)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("ADD PAYMENT ERROR: \(error)")
                    self?.shouldShowAlert?(.error, localized("upload_iban_error_message"))
                    self?.isLoadingPublisher.send(false)
                }
            }, receiveValue: { [weak self] addPaymentResponse in

                // self?.shouldShowAlert?(.success, localized("upload_iban_success_message"))
                self?.shouldShowSuccessScreen?()
                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)
    }

}
