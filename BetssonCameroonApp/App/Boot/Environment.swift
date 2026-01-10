//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation
import ServicesProvider

let Env = Environment() // swiftlint:disable:this identifier_name

class Environment {

    lazy var servicesProvider: ServicesProvider.Client = {
        var serviceProviderEnvironment: ServicesProvider.Configuration.Environment
        switch TargetVariables.serviceProviderEnvironment {
        case .prod:
            serviceProviderEnvironment = .production
        case .staging:
            serviceProviderEnvironment = .staging
        case .dev:
            serviceProviderEnvironment = .development
        }
        
        var cmsBusinessUnit: ServicesProvider.Configuration.ClientBusinessUnit
        switch TargetVariables.cmsClientBusinessUnit {
        case .betssonFrance:
            cmsBusinessUnit = .betssonFrance
        case .betssonCameroon:
            cmsBusinessUnit = .betssonCameroon
        case .gomaDemo:
            cmsBusinessUnit = .gomaDemo
        }

        // Use builder pattern to configure client business unit for CMS
        let configBuilder = ServicesProvider.Configuration.Builder()
        do {
            let servicesProviderConfiguration = try configBuilder
                .withEnvironment(serviceProviderEnvironment)
                .withDeviceUUID(Env.deviceId)
                .withClientBusinessUnit(cmsBusinessUnit)
                .withLanguage(LanguageManager.shared.currentLanguageCode)
                .build()

            let provider = TargetVariables.serviceProviderType
            let client: ServicesProvider.Client
            switch provider {
            case .everymatrix:
                client = ServicesProvider.Client(providerType: .everymatrix, configuration: servicesProviderConfiguration)
            case .sportradar:
                client = ServicesProvider.Client(providerType: .sportradar, configuration: servicesProviderConfiguration)
            case .goma:
                client = ServicesProvider.Client(providerType: .goma, configuration: servicesProviderConfiguration)
            }

            return client
        } catch {
            // Fallback to legacy configuration if builder fails
            let servicesProviderConfiguration = ServicesProvider.Configuration(environment: serviceProviderEnvironment, deviceUUID: Env.deviceId)
            let provider = TargetVariables.serviceProviderType
            let client: ServicesProvider.Client
            switch provider {
            case .everymatrix:
                client = ServicesProvider.Client(providerType: .everymatrix, configuration: servicesProviderConfiguration)
            case .sportradar:
                client = ServicesProvider.Client(providerType: .sportradar, configuration: servicesProviderConfiguration)
            case .goma:
                client = ServicesProvider.Client(providerType: .goma, configuration: servicesProviderConfiguration)
            }

            return client
        }
    }()

    /// URL provider for accessing dynamic URLs
    lazy var linksProvider: LinksProviderProtocol = {
        return LinksProviderFactory.createURLProvider(
            initialLinks: TargetVariables.links,
            servicesProvider: self.servicesProvider
        )
    }()

    let betslipManager: BetslipManager = BetslipManager()

    let userSessionStore: UserSessionStore = UserSessionStore()
    let businessSettingsSocket: RealtimeSocketClient = RealtimeSocketClient()

    let sportsStore: SportTypeStore = SportTypeStore()

    var calendar: Calendar = Calendar.autoupdatingCurrent
    var locale: Locale = Locale.autoupdatingCurrent
    var timezone: TimeZone = TimeZone.autoupdatingCurrent
    var date: () -> Date = { Date.init() }

    var favoritesManager: FavoritesManager = FavoritesManager()
    var deviceFirebaseCloudMessagingToken: String = ""

    var deviceId: String {
        UserDefaults.standard.string(forKey: "device_id") ?? ""
    }

    let urlSchemaManager: URLSchemaManager = URLSchemaManager()

    /// Casino cache provider wrapper for improved UX with caching
    lazy var casinoCacheProvider: CasinoCacheProvider = {
        // ServicesProvider.Client implements CasinoProvider methods,
        // so we can use it directly as the underlying provider
        let cacheStore = CasinoCacheStore(configuration: .default)
        return CasinoCacheProvider(
            servicesProvider: servicesProvider,
            cacheStore: cacheStore,
            configuration: .default
        )
    }()

    init() {

    }

}

extension Environment {
    var timezoneOffset: TimeInterval {
        return TimeInterval(Env.timezone.secondsFromGMT())
    }

    var timezoneOffsetInMinutes: Int {
        let timeInterval = Env.timezoneOffset
        return Int(timeInterval)/60
    }
}

extension Environment {

    var bundleId: String {
        return Bundle.main.bundleIdentifier ?? "com.goma.sportsbook"
    }
}

/**
    NEW SERVICESPROVIDER INIT LOGIC. CONFIG BUILD

    /// Create and configure a ServicesProvider client with feature flags
    public static func createClient() throws -> ServicesProviderClient {
        // Create a configuration builder
        let configBuilder = Configuration.Builder()

        // Configure environment
        configBuilder.withEnvironment(.staging)

        // Set device UUID
        configBuilder.withDeviceUUID(UUID().uuidString)

        // Configure provider mappings
        configBuilder.useProvider(.goma, forDomain: .managedContent)
        configBuilder.useProvider(.sportsradar, forDomain: .liveEvents)
        configBuilder.useProvider(.sportsradar, forDomain: .preLiveEvents)
        configBuilder.useProvider(.goma, forDomain: .playerAccountManagement)

        // Set provider credentials
        configBuilder.withCredentials(.goma, credential:
            Configuration.ProviderCredentials(name: "goma-api-key", secret: "goma-secret"))
        configBuilder.withCredentials(.sportsradar, credential:
            Configuration.ProviderCredentials(name: "sportsradar-api-key", secret: "sportsradar-secret"))

        // Enable features
        configBuilder.enableFeature(.mixMatch)

        // Build the configuration
        let configuration = try configBuilder.build()

        // Create the client with the configuration
        return ServicesProviderClient(configuration: configuration)
    }

    /// Example of how to use the client
    public static func exampleUsage() {
        do {
            // Create the client
            let client = try createClient()

            // Use the client to fetch data
            let cancellable = client.getHomeTemplate()
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Successfully fetched home template")
                    case .failure(let error):
                        print("Error fetching home template: \(error)")
                    }
                }, receiveValue: { template in
                    print("Received home template with \(template.widgets.count) widgets")
                })

            // Keep the cancellable reference
            _ = cancellable

        } catch let error as ConfigurationError {
            print("Configuration error: \(error.localizedDescription)")
        } catch {
            print("Unknown error: \(error)")
        }
    }

*/
