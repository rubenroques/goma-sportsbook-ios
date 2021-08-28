//
//  Environment.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/08/2021.
//

import Foundation

var Env = Environment() // swiftlint:disable:this identifier_name

struct Environment {

    let networkManager = NetworkManager()
    var deviceId: String { // FIXME: O deviceId deve ser gerado no 1º arranque da app e gravado no userdefaults
        "61F9A5CC2906"
    }
    var isMaintenance = false
    var appUpdateType = "" // FIXME: Esta variavel, se for para manter assim deveria ser um Enum e não uma string para evitar problemas futuros
    var userLat: Double? // FIXME: Vamos eviar usar abreviaturas
    var userLong: Double?

    func getUserSettings() -> [ClientSettings]? {
        let settingsData = UserDefaults.standard.data(forKey: "user_settings")
        let settingsArray = try? JSONDecoder().decode([ClientSettings].self, from: settingsData!)
        return settingsArray
    }
}
