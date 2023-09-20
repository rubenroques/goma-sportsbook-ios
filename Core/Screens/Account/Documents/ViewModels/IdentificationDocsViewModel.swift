//
//  IdentificationDocsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2023.
//

import Foundation
import Combine
import ServicesProvider
import IdensicMobileSDK
import CryptoKit

class IdentificationDocsViewModel {

    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var documents: [DocumentInfo] = []
    var requiredDocumentTypes: [DocumentType] = []

    var identificationDocuments: [DocumentInfo] = []
    var proofAddressDocuments: [DocumentInfo] = []

    var hasLoadedDocumentTypes: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLoadedUserDocuments: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasDocumentsProcessed: CurrentValueSubject<Bool, Never> = .init(false)

    var sumsubAccessTokenPublisher: CurrentValueSubject<String, Never> = .init("")

    var currentDocumentLevelStatus: CurrentDocumentLevelStatus?

    var shouldReloadData: (() -> Void)?

    let dateFormatter = DateFormatter()

    init() {
        self.setupPublishers()

        self.getDocumentTypes()

    }

    func generateDocumentTypeToken(docType: String) {

        Env.servicesProvider.generateDocumentTypeToken(docType: docType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("OMEGA SUMSUB ACCESS TOKEN ERROR: \(error)")

                    self?.isLoadingPublisher.send(false)

                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] accessTokenResponse in
                print("OMEGA SUMSUB ACCESS TOKEN RESPONSE: \(accessTokenResponse)")

                if let accessToken = accessTokenResponse.token {
                    self?.sumsubAccessTokenPublisher.send(accessToken)
                }

                self?.isLoadingPublisher.send(false)

            })
            .store(in: &cancellables)
    }

//    func getSumsubAccessToken(levelName: String) {
//
//        self.isLoadingPublisher.send(true)
//
//        let userId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
//
//        Env.servicesProvider.sumsubDataProvider?.getSumsubAccessToken(userId: userId, levelName: levelName)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    print("SUMSUB ACCESS TOKEN ERROR: \(error)")
//
//                    self?.isLoadingPublisher.send(false)
//
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] accessTokenResponse in
//                print("SUMSUB ACCESS TOKEN RESPONSE: \(accessTokenResponse)")
//
//                if let accessToken = accessTokenResponse.token {
//                    self?.sumsubAccessTokenPublisher.send(accessToken)
//                }
//
//                self?.isLoadingPublisher.send(false)
//
//            })
//            .store(in: &cancellables)
//
//    }

//    func getSumSubDocuments() {
//
//        self.isLoadingPublisher.send(true)
//        self.hasLoadedUserDocuments.send(false)
//        self.hasDocumentsProcessed.send(false)
//
//        let userId = Env.userSessionStore.userProfilePublisher.value?.userIdentifier ?? ""
//
//        Env.servicesProvider.sumsubDataProvider?.getApplicantData(userId: userId)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { [weak self] completion in
//                switch completion {
//                case .failure(let error):
//                    print("SUMSUB DATA ERROR: \(error)")
//
//                    self?.getUserDocuments()
//
//                case .finished:
//                    ()
//                }
//            }, receiveValue: { [weak self] applicantDataResponse in
//                print("SUMSUB DATA RESPONSE: \(applicantDataResponse)")
//
//                if let requiredDocumentTypes = self?.requiredDocumentTypes {
//                    self?.processSumsubDocuments(documentTypes: requiredDocumentTypes, applicantDataResponse: applicantDataResponse)
//                }
//
//                self?.getUserDocuments()
//
//            })
//            .store(in: &cancellables)
//    }

    func checkDocumentationData() {

        self.isLoadingPublisher.send(true)
        self.hasLoadedUserDocuments.send(false)
        self.hasDocumentsProcessed.send(false)

        Env.servicesProvider.checkDocumentationData()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("SUMSUB DATA ERROR: \(error)")

                    self?.reloadData()

                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] applicantDataResponse in
                print("SUMSUB DATA RESPONSE: \(applicantDataResponse)")

                if let applicantDocs = applicantDataResponse.info?.applicantDocs,
                   applicantDocs.isNotEmpty {

                    if let requiredDocumentTypes = self?.requiredDocumentTypes {
                        self?.processSumsubDocuments(documentTypes: requiredDocumentTypes, applicantDataResponse: applicantDataResponse)
                    }

                    if let reviewData = applicantDataResponse.reviewData {

                        let documentLevelName = DocumentLevelName(levelName: reviewData.levelName)

                        let documentStatus = DocumentStatus(status: reviewData.reviewStatus)

                        self?.currentDocumentLevelStatus = CurrentDocumentLevelStatus(status: documentStatus, levelName: documentLevelName)

                    }

                    self?.getUserDocuments()

                }
                else {
                    self?.reloadData()
                }

            })
            .store(in: &cancellables)
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

    func refreshDocuments() {
        self.documents = []
        self.identificationDocuments = []
        self.proofAddressDocuments = []
        self.checkDocumentationData()
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
                    $0.documentTypeGroup == .identityCard  ||
                    $0.documentTypeGroup == .residenceId ||
                    $0.documentTypeGroup == .drivingLicense ||
                    $0.documentTypeGroup == .passport ||
                    $0.documentTypeGroup == .proofOfAddress
                })

                self?.requiredDocumentTypes.append(contentsOf: requiredDocumentTypes)

                self?.hasLoadedDocumentTypes.send(true)

                self?.checkDocumentationData()
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
                    //self?.isLoadingPublisher.send(false)
                    self?.reloadData()
                }

            }, receiveValue: { [weak self] userDocumentsResponse in

                let userDocuments = userDocumentsResponse.userDocuments

                // Check sumsub status to get omega documents after validation
                if let currentDocumentLevelStatus = self?.currentDocumentLevelStatus {

                    if currentDocumentLevelStatus.levelName == .identificationLevel && currentDocumentLevelStatus.status == .completed {

                        if let requiredDocumentTypes = self?.requiredDocumentTypes {
                            self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
                        }

                    }
                    else if currentDocumentLevelStatus.levelName == .poaLevel {

                        if let requiredDocumentTypes = self?.requiredDocumentTypes {
                            self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
                        }

                    }
                    else {
                        self?.reloadData()
                    }
                }

//                if let requiredDocumentTypes = self?.requiredDocumentTypes {
//                    self?.processDocuments(documentTypes: requiredDocumentTypes, userDocuments: userDocuments)
//                }

            })
            .store(in: &cancellables)
    }

    private func clearDocumentsData() {
        self.documents = []
        self.identificationDocuments = []
        self.proofAddressDocuments = []

    }

    private func processSumsubDocuments(documentTypes: [DocumentType], applicantDataResponse: ApplicantDataResponse) {

        self.clearDocumentsData()

        var documentFilesInfo = [DocumentFileInfo]()

        if let docTypes = applicantDataResponse.info?.applicantDocs {

            for docType in docTypes {

                let docId = docType.docType

                let docTypeGroup = DocumentTypeGroup(externalCode: docId)

                let docName = docTypeGroup?.codeName ?? ""

                var docStatus = FileState.pendingApproved

                var retry: Bool = true

                self.dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
                var uploadDate: Date? = nil

                // Check documents state
                if let levelName = applicantDataResponse.reviewData?.levelName,
                   let reviewStatus = applicantDataResponse.reviewData?.reviewStatus,
                   let docTypeGroup = docTypeGroup {

                    // Doc in same level group
                    if levelName == docTypeGroup.levelName {

                        uploadDate = self.dateFormatter.date(from: applicantDataResponse.reviewData?.createDate ?? "")

                        if reviewStatus == "completed" {
                            if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                               reviewResult == "RED" {
                                docStatus = .rejected

                                if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                    retry = reviewRejectType == "RETRY" ? true : false
                                }
                            }
                            else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                    reviewResult == "GREEN" {
                                docStatus = .approved

                                retry = false
                            }
                        }
                        else if reviewStatus == "init" {
                            if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                               reviewResult == "RED" {
                                docStatus = .rejected

                                if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                    retry = reviewRejectType == "RETRY" ? true : false
                                }
                            }
                            else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                    reviewResult == "GREEN" {
                                docStatus = .incomplete

                                retry = true
                            }
                            else {
                                continue
                            }
                        }
                        else {
                            docStatus = .pendingApproved
                            retry = false
                        }
                    }
                    else {
                        if applicantDataResponse.reviewData?.levelName == DocumentTypeGroup.proofAddress.levelName {
                            docStatus = .approved
                            retry = false
                        }
                        else {
                            if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                               reviewResult == "RED" {
                                docStatus = .rejected

                                if let reviewRejectType = applicantDataResponse.reviewData?.reviewResult?.reviewRejectType {
                                    retry = reviewRejectType == "RETRY" ? true : false
                                }
                            }
                            else if let reviewResult = applicantDataResponse.reviewData?.reviewResult?.reviewAnswer,
                                    reviewResult == "GREEN" {
                                docStatus = .approved

                                retry = false
                            }
                        }
                    }

                }

                var totalRetries: Int?

                if let attempCount = applicantDataResponse.reviewData?.attemptCount {
                    totalRetries = attempCount
                }

                let docFileInfo = DocumentFileInfo(id: docId,
                                                   name: docName,
                                                   status: docStatus,
                                                   uploadDate: uploadDate,
                                                   retry: retry,
                                                   documentTypeGroup: docTypeGroup ?? .none,
                                                   totalRetries: totalRetries)

                documentFilesInfo.append(docFileInfo)
            }
        }

        // Associate docFileInfos to documentTypes
        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            if let documentTypeGroup = documentType.documentTypeGroup {

                let mappedDocumentTypeGroup = ServiceProviderModelMapper.documentTypeGroup(fromServiceProviderDocumentTypeGroup: documentTypeGroup)

                let uploadedFiles = documentFilesInfo.filter( {
                    $0.documentTypeGroup == mappedDocumentTypeGroup
                })

                let documentInfo = DocumentInfo(id: documentType.documentType,
                                                typeName: documentTypeCode?.codeName ?? "",
                                                status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                uploadedFiles: uploadedFiles,
                                                typeGroup: mappedDocumentTypeGroup)

                self.documents.append(documentInfo)

            }
            else {

                let uploadedFiles = documentFilesInfo

                let documentInfo = DocumentInfo(id: documentType.documentType,
                                                typeName: documentTypeCode?.codeName ?? "",
                                                status: uploadedFiles.isEmpty ? .notReceived : .received,
                                                uploadedFiles: uploadedFiles)

                self.documents.append(documentInfo)
            }
        }

        let identificationDocuments = self.documents.filter({
            $0.typeGroup == .identityCard ||
            $0.typeGroup == .residenceId ||
            $0.typeGroup == .drivingLicense ||
            $0.typeGroup == .passport
        })
        self.identificationDocuments = identificationDocuments

        let proofAddress = self.documents.filter({
            $0.typeGroup == .proofAddress
        })
        self.proofAddressDocuments = proofAddress

    }

    private func processDocuments(documentTypes: [DocumentType], userDocuments: [UserDocument]) {

        // Check for identification user documents on Omega
        if userDocuments.isNotEmpty && userDocuments.contains(where: {
            $0.documentType == "IDENTITY_CARD"
        }) {
            self.identificationDocuments = []
            let filteredDocuments = self.documents.filter({
                $0.typeGroup == .proofAddress
            })

            self.documents = filteredDocuments
        }

        // Check for poa user documents on Omega
        if userDocuments.isNotEmpty && userDocuments.contains(where: {
            $0.documentType == "POA"
        }) {
            self.proofAddressDocuments = []
            let filteredDocuments = self.documents.filter({
                $0.typeGroup == .identityCard ||
                $0.typeGroup == .drivingLicense ||
                $0.typeGroup == .passport ||
                $0.typeGroup == .residenceId
            })

            self.documents = filteredDocuments
        }

        for documentType in documentTypes {

            let documentTypeCode = DocumentTypeCode(code: documentType.documentType)

            if let documentTypeGroup = documentType.documentTypeGroup {

                let mappedDocumentTypeGroup = ServiceProviderModelMapper.documentTypeGroup(fromServiceProviderDocumentTypeGroup: documentTypeGroup)

                var uploadedFiles = [DocumentFileInfo]()

                let filteredUserDocuments = userDocuments.filter({
                    $0.documentType == documentType.documentType
                })

                for userDocument in filteredUserDocuments {

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)

                    if let userDocumentFiles = userDocument.userDocumentFiles {

                        for userDocumentFile in userDocumentFiles {

                            var retry = true

                            if userDocumentStatus == .approved || userDocumentStatus == .pendingApproved {
                                retry = false
                            }

                            var fileName = userDocument.documentType

                            if userDocumentFiles.count > 1 {
                                if userDocumentFile.fileName == userDocumentFiles.first?.fileName {
                                    fileName = "\(fileName) \(localized("upload_front"))"
                                }
                                else {
                                    fileName = "\(fileName) \(localized("upload_back"))"
                                }
                            }

                            let documentFileInfo = DocumentFileInfo(id: userDocument.documentType,
                                                                    name: fileName,
                                                    status: userDocumentStatus ?? .pendingApproved,
                                                    uploadDate: uploadDate ?? Date(),
                                                                    retry: retry,
                                                    documentTypeGroup: mappedDocumentTypeGroup)

                            uploadedFiles.append(documentFileInfo)
                        }

                    }
                    else {
                        var retry = true

                        if userDocumentStatus == .approved || userDocumentStatus == .pendingApproved {
                            retry = false
                        }

                        let documentFileInfo = DocumentFileInfo(id: userDocument.documentType,
                                                name: userDocument.fileName ?? "",
                                                status: userDocumentStatus ?? .pendingApproved,
                                                uploadDate: uploadDate ?? Date(),
                                                                retry: retry,
                                                documentTypeGroup: mappedDocumentTypeGroup)

                        uploadedFiles.append(documentFileInfo)
                    }

                }

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

                var uploadedFiles = [DocumentFileInfo]()

                let filteredUserDocuments = userDocuments.filter({
                    $0.documentType == documentType.documentType
                })

                for userDocument in filteredUserDocuments {

                    let userDocumentStatus = FileState(code: userDocument.status)

                    self.dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                    let uploadDate = self.dateFormatter.date(from: userDocument.uploadDate)

                    if let userDocumentFiles = userDocument.userDocumentFiles {

                        for userDocumentFile in userDocumentFiles {

                            var retry = true

                            if userDocumentStatus == .approved || userDocumentStatus == .pendingApproved {
                                retry = false
                            }

                            let documentFileInfo = DocumentFileInfo(id: userDocument.documentType,
                                                                    name: userDocumentFile.fileName,
                                                    status: userDocumentStatus ?? .pendingApproved,
                                                    uploadDate: uploadDate ?? Date(),
                                                                    retry: retry,
                                                                    documentTypeGroup: .none)

                            uploadedFiles.append(documentFileInfo)
                        }

                    }
                    else {
                        var retry = true

                        if userDocumentStatus == .approved || userDocumentStatus == .pendingApproved {
                            retry = false
                        }

                        let documentFileInfo = DocumentFileInfo(id: userDocument.documentType,
                                                name: userDocument.fileName ?? "",
                                                status: userDocumentStatus ?? .pendingApproved,
                                                uploadDate: uploadDate ?? Date(),
                                                                retry: retry,
                                                                documentTypeGroup: .none)

                        uploadedFiles.append(documentFileInfo)
                    }

                }

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

        let identificationDocuments = self.documents.filter({
            $0.typeGroup == .identityCard ||
            $0.typeGroup == .residenceId ||
            $0.typeGroup == .drivingLicense ||
            $0.typeGroup == .passport
        })
        self.identificationDocuments = identificationDocuments

        let proofAddress = self.documents.filter({
            $0.typeGroup == .proofAddress

        })
        self.proofAddressDocuments = proofAddress

        self.isLoadingPublisher.send(false)
        self.hasLoadedUserDocuments.send(true)
        self.hasDocumentsProcessed.send(true)
        self.shouldReloadData?()
    }

    private func reloadData() {

        self.isLoadingPublisher.send(false)
        self.hasLoadedUserDocuments.send(true)
        self.hasDocumentsProcessed.send(true)
        self.shouldReloadData?()

    }
}
