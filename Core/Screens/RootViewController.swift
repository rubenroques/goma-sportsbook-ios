//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine
import SwiftUI


class RootViewController: UIViewController {

    @IBOutlet private weak var openProfileButton: UIButton!

    var cancellables = Set<AnyCancellable>()

    var savedRegistration: Registration?

    init() {
        super.init(nibName: "RootViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
    }


    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainTintColor
    }

    @IBAction private func didTapAPITest() {

        Env.gomaNetworkClient.requestTest(deviceId: Env.deviceId)
            .sink(receiveCompletion: {
                print("Received completion: \($0).")
            },
            receiveValue: { user in
                print("Received Content - user: \(String(describing: user)).")
            })
            .store(in: &cancellables)
    }

    @IBAction private func didTapUserSettings() {

        Env.gomaNetworkClient.requestSettings(deviceId: Env.deviceId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    print("Error retrieving user settings!")

                case .finished:
                    print("User settings retrieved!")
                }

                print("Received completion: \(completion).")

            },
            receiveValue: { data in
                print("Received Content - data: \(data!).")
                var settingsArray = [GomaClientSettings]()
                for value in data! {
                    let setting = GomaClientSettings(id: value.id, category: value.category, name: value.name, type: value.type)
                    settingsArray.append(setting)
                }
                let settingsData = try? JSONEncoder().encode(settingsArray)

                UserDefaults.standard.set(settingsData, forKey: "user_settings")

                let settingsStored = Env.getUserSettings()
                print("User settings: \(String(describing: settingsStored))")
            })
            .store(in: &cancellables)
    }

    @IBAction private func testEveryMatrixAPI() {
        // let payload = ["lang":"en", "maxResults":"10"]
        // let payloadToday = ["lang":"en", "userTimezoneOffsetInMinutes":"0", "maxResults":"10"]
        // let payloadNext = ["lang":"en", "hoursTillLive":"2", "maxResults":"10", "disciplineId":"1"]
        let payloadOdd: [String: Any] = ["lang": "en",
                          "matchId": "148056830725115904",
                          "tournamentId": "",
                          "bettingOfferId": "",
                          "bettingOfferIds": [],
                          "eventIds": []] // as [String : Any?]

        Env.everyMatrixAPIClient.getOdds(payload: payloadOdd)
    }

    @IBAction private func testSubscription() {
//
//        Env.everyMatrixAPIClient.subscribeOdds(language: "EN", matchId: "150328598296842240")
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print("")
//            } receiveValue: { everyMatrixSocketResponseOdd in
//                print("")
//            }
//            .store(in: &cancellables)



//        Env.everyMatrixAPIClient.subscribeSportsStatus(language: "en", sportType: .football)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print("")
//            } receiveValue: { disciplines in
//                print("")
//            }
//            .store(in: &cancellables)


//        let operatorId = "\(Env.operatorId)"
//        TSManager.shared.subscribeProcedure(procedure: .sportsStatus(operatorId: operatorId,
//                                                                     language: "en",
//                                                                     sportId: "1"))
//            .sink { completion in
//                print("")
//            } receiveValue: { value in
//                print("")
//            }
//            .store(in: &cancellables)





//
//        TSManager.shared.swampSession?.subscribe("/sports/2474/en/sport/1", options: [:], onSuccess: { subscription in
//
//            print("subscribe")
//            print(subscription)
//
//            TSManager.shared.swampSession?.call("/sports#initialDump",
//                                                options: [:],
//                                                args: [],
//                                                kwargs: ["topic": "/sports/2474/en/sport/1"],
//            onSuccess: { details, results, kwResults, arrResults in
//                print("call onSuccess")
//                print(details, results, kwResults, arrResults)
//
//            }, onError: { details, error, args, kwargs in
//                print("call onError")
//                print(details, error, args, kwargs)
//            })
//
//        }, onError: { details, error in
//
//            print(details, error)
//        }, onEvent: { details, results, kwResults in
//            print(details, results, kwResults)
//        })





        TSManager.shared.swampSession?.register("/sports/2474/en/sport/1", options: [:], onSuccess: { registration in

            self.savedRegistration = registration

            print("registration")
            print(registration)

            TSManager.shared.swampSession?.call("/sports#initialDump",
                                                options: [:],
                                                args: [],
                                                kwargs: ["topic": "/sports/2474/en/sport/1"],
            onSuccess: { details, results, kwResults, arrResults in
                print("call onSuccess")
                //print(details, results, kwResults, arrResults)

            }, onError: { details, error, args, kwargs in
                print("call onError")
                //print(details, error, args, kwargs)
            })

        }, onError: { details, error in

            print(details, error)
        }, onEvent: { details, results, kwResults in
            print("call Register Event")
            //print(details, results, kwResults)
        })



//        Env.everyMatrixAPIClient.registerOnSportsStatus(language: "en", sportType: .football)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                print("")
//            } receiveValue: { disciplines in
//                print("")
//            }
//            .store(in: &cancellables)

    }

    @IBAction private func testSubscriptionInitialDump() {

        if let savedRegistration = savedRegistration {
            TSManager.shared.swampSession?.unregister(savedRegistration.registration, onSuccess: {
                self.savedRegistration = nil
            }, onError: { details, error in
                self.savedRegistration = nil
            })
        }

//
//        Env.everyMatrixAPIClient.requestInitialDump(topic: "/sports/2474/en/sport/1").sink { completion in
//
//        } receiveValue: { string in
//
//        }
//        .store(in: &cancellables)

    }

    @IBAction private func didTapOpenProfileButton() {

    }

    @IBAction private func didTapLoginProfileButton() {

    }

}
