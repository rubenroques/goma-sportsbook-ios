//
//  ManualUploadsDocumentsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2023.
//

import Foundation
import Combine

class ManualUploadsDocumentsViewModel {

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

    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isFileUploaded: CurrentValueSubject<Bool, Never> = .init(false)

    var documentTypeCode: DocumentTypeCode

    var shouldShowAlert: ((AlertType, String) -> Void)?
    var shouldShowSuccessScreen: (() -> Void)?

    init(documentTypeCode: DocumentTypeCode) {
        self.documentTypeCode = documentTypeCode
    }

    func addPaymentInformation(rib: String) {

        self.isLoadingPublisher.send(true)

        let fieldsInfo = """
                        {
                        "IBAN":"\(rib)"
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

                self?.shouldShowAlert?(.success, localized("upload_complete_message"))
                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)
    }

    func uploadFile(documentType: String, file: Data, fileName: String) {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.uploadUserDocument(documentType: documentType, file: file, fileName: fileName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("UPLOAD FILE ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.shouldShowAlert?(.error, message)
                        self?.isFileUploaded.send(false)
                        self?.isLoadingPublisher.send(false)
                    default:
                        ()
                    }
                }
            }, receiveValue: { [weak self] uploadFileResponse in
                print("UPLOAD FILE RESPONSE: \(uploadFileResponse)")

                if self?.documentTypeCode == .ibanProof {
                    self?.isFileUploaded.send(true)
                }
                else {
                    self?.isFileUploaded.send(true)
                    self?.isLoadingPublisher.send(false)
                }
            })
            .store(in: &cancellables)
    }

    func uploadFiles(documentType: String, files: [String: Data]) {

        self.isLoadingPublisher.send(true)

        Env.servicesProvider.uploadMultipleUserDocuments(documentType: documentType, files: files)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("UPLOAD MULTIPLE FILES ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.shouldShowAlert?(.error, message)
                        self?.isFileUploaded.send(false)
                        self?.isLoadingPublisher.send(false)
                    default:
                        ()
                    }
                }
            }, receiveValue: { [weak self] uploadFileResponse in
                print("UPLOAD MULTIPLE FILES RESPONSE: \(uploadFileResponse)")

                self?.isFileUploaded.send(true)
                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)
    }
}
