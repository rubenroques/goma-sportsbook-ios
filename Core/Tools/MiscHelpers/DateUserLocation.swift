//
//  DateUserLocation.swift
//  Sportsbook
//
//  Created by André Lascas on 20/08/2021.
//

import Foundation
import MapKit

// FIXME: Esta classe não pode fazer formatação manual, tem que uilizar o NSDateFormatter do sistema.
// Não vamos conseguir formatar todos os paises manualmente e o sistema já faz isso por nós
// Esta classe deve ser apenas uma serie de formatter helpers, para formatar a data nos diferentes tamanhos e componentes

struct DateUserLocation {

    var countryDateFormats = [
        "dd-MM-yyyy HH:mm:ss": ["Others"],
        "yyyy-MM-dd HH:mm:ss": ["China", "Japan", "South Korea", "North Korea", "Taiwan", "Hungary", "Mongolia", "Lithuania", "Bhutan"],
        "MM-dd-yyyy HH:mm:ss": ["United States of America", "Canada"]
    ]

    func dateLocationFormat(_ country: String, _ date: Date) -> String {
        let dateFormatter = DateFormatter()

        if countryDateFormats["yyyy-MM-dd HH:mm:ss"]!.contains(country) {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        else if countryDateFormats["MM-dd-yyyy HH:mm:ss"]!.contains(country) {
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        }
        else {
            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        }

        return dateFormatter.string(from: date)

    }
}

// FIXME: A extension tem que ficar num ficheiro dedicado, como as outras extensions usadas no projecto
extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country: String?, _ error: Error?) -> Void ) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
