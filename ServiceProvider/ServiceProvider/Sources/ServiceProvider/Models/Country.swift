//
//  File.swift
//  
//
//  Created by Ruben Roques on 27/10/2022.
//

import Foundation

public enum CountryCode: String, CaseIterable {
    case AF
    case AX
    case AL
    case DZ
    case AS
    case AD
    case AO
    case AI
    case AQ
    case AG
    case AR
    case AM
    case AW
    case AU
    case AT
    case AZ
    case BS
    case BH
    case BD
    case BB
    case BY
    case BE
    case BZ
    case BJ
    case BM
    case BT
    case BO
    case BQ
    case BA
    case BW
    case BV
    case BR
    case IO
    case UM
    case VG
    case VI
    case BN
    case BG
    case BF
    case BI
    case KH
    case CM
    case CA
    case CV
    case KY
    case CF
    case TD
    case CL
    case CN
    case CX
    case CC
    case CO
    case KM
    case CG
    case CD
    case CK
    case CR
    case HR
    case CU
    case CW
    case CY
    case CZ
    case DK
    case DJ
    case DM
    case DO
    case EC
    case EG
    case SV
    case GQ
    case ER
    case EE
    case ET
    case FK
    case FO
    case FJ
    case FI
    case FR
    case GF
    case PF
    case TF
    case GA
    case GM
    case GE
    case DE
    case GH
    case GI
    case GR
    case GL
    case GD
    case GP
    case GU
    case GT
    case GG
    case GN
    case GW
    case GY
    case HT
    case HM
    case VA
    case HN
    case HU
    case HK
    case IS
    case IN
    case ID
    case CI
    case IR
    case IQ
    case IE
    case IM
    case IL
    case IT
    case JM
    case JP
    case JE
    case JO
    case KZ
    case KE
    case KI
    case KW
    case KG
    case LA
    case LV
    case LB
    case LS
    case LR
    case LY
    case LI
    case LT
    case LU
    case MO
    case MK
    case MG
    case MW
    case MY
    case MV
    case ML
    case MT
    case MH
    case MQ
    case MR
    case MU
    case YT
    case MX
    case FM
    case MD
    case MC
    case MN
    case ME
    case MS
    case MA
    case MZ
    case MM
    case NA
    case NR
    case NP
    case NL
    case NC
    case NZ
    case NI
    case NE
    case NG
    case NU
    case NF
    case KP
    case MP
    case NO
    case OM
    case PK
    case PW
    case PS
    case PA
    case PG
    case PY
    case PE
    case PH
    case PN
    case PL
    case PT
    case PR
    case QA
    case XK
    case RE
    case RO
    case RU
    case RW
    case BL
    case SH
    case KN
    case LC
    case MF
    case PM
    case VC
    case WS
    case SM
    case ST
    case SA
    case SN
    case RS
    case SC
    case SL
    case SG
    case SX
    case SK
    case SI
    case SB
    case SO
    case ZA
    case GS
    case KR
    case ES
    case LK
    case SD
    case SS
    case SR
    case SJ
    case SZ
    case SE
    case CH
    case SY
    case TW
    case TJ
    case TZ
    case TH
    case TL
    case TG
    case TK
    case TO
    case TT
    case TN
    case TR
    case TM
    case TC
    case TV
    case UG
    case UA
    case AE
    case GB
    case US
    case UY
    case UZ
    case VU
    case VE
    case VN
    case WF
    case EH
    case YE
    case ZM
    case ZW
}

public struct Country {
    public var name: String
    public var capital: String?
    public var region: String
    public var iso2Code: String
    public var iso3Code: String
    public var numericCode: String
    public var phonePrefix: String
}

public extension Country {
    
    init?(countryCode: CountryCode) {
        if let country = Self.country(withCountryCode: countryCode) {
            self = country
        }
        else {
            return nil
        }
    }
    
    init?(isoCode: String) {
        if let country = Self.country(withISOCode: isoCode) {
            self = country
        }
        else {
            return nil
        }
    }
    
    static var allCountries: [Country] {
        return CountryCode.allCases.map({ Self.country(withCountryCode:$0)}).compactMap({ $0 })
    }
    
    static func country(withCountryCode countryCode: CountryCode) -> Country? {
        self.country(withISOCode: countryCode.rawValue)
    }
    
    static func country(withISOCode isoCode: String) -> Country? {
        switch isoCode {
        case "AF": return Country(name: "Afghanistan", capital: "Kabul", region: "Asia", iso2Code: "AF", iso3Code: "AFG", numericCode: "004", phonePrefix: "+93")
        case "AX": return Country(name: "Åland Islands", capital: "Mariehamn", region: "Europe", iso2Code: "AX", iso3Code: "ALA", numericCode: "248", phonePrefix: "+358")
        case "AL": return Country(name: "Albania", capital: "Tirana", region: "Europe", iso2Code: "AL", iso3Code: "ALB", numericCode: "008", phonePrefix: "+355")
        case "DZ": return Country(name: "Algeria", capital: "Algiers", region: "Africa", iso2Code: "DZ", iso3Code: "DZA", numericCode: "012", phonePrefix: "+213")
        case "AS": return Country(name: "American Samoa", capital: "Pago Pago", region: "Oceania", iso2Code: "AS", iso3Code: "ASM", numericCode: "016", phonePrefix: "+1")
        case "AD": return Country(name: "Andorra", capital: "Andorra la Vella", region: "Europe", iso2Code: "AD", iso3Code: "AND", numericCode: "020", phonePrefix: "+376")
        case "AO": return Country(name: "Angola", capital: "Luanda", region: "Africa", iso2Code: "AO", iso3Code: "AGO", numericCode: "024", phonePrefix: "+244")
        case "AI": return Country(name: "Anguilla", capital: "The Valley", region: "Americas", iso2Code: "AI", iso3Code: "AIA", numericCode: "660", phonePrefix: "+1")
        case "AQ": return Country(name: "Antarctica", capital: nil, region: "Polar", iso2Code: "AQ", iso3Code: "ATA", numericCode: "010", phonePrefix: "+672")
        case "AG": return Country(name: "Antigua and Barbuda", capital: "Saint John's", region: "Americas", iso2Code: "AG", iso3Code: "ATG", numericCode: "028", phonePrefix: "+1")
        case "AR": return Country(name: "Argentina", capital: "Buenos Aires", region: "Americas", iso2Code: "AR", iso3Code: "ARG", numericCode: "032", phonePrefix: "+54")
        case "AM": return Country(name: "Armenia", capital: "Yerevan", region: "Asia", iso2Code: "AM", iso3Code: "ARM", numericCode: "051", phonePrefix: "+374")
        case "AW": return Country(name: "Aruba", capital: "Oranjestad", region: "Americas", iso2Code: "AW", iso3Code: "ABW", numericCode: "533", phonePrefix: "+297")
        case "AU": return Country(name: "Australia", capital: "Canberra", region: "Oceania", iso2Code: "AU", iso3Code: "AUS", numericCode: "036", phonePrefix: "+61")
        case "AT": return Country(name: "Austria", capital: "Vienna", region: "Europe", iso2Code: "AT", iso3Code: "AUT", numericCode: "040", phonePrefix: "+43")
        case "AZ": return Country(name: "Azerbaijan", capital: "Baku", region: "Asia", iso2Code: "AZ", iso3Code: "AZE", numericCode: "031", phonePrefix: "+994")
        case "BS": return Country(name: "Bahamas", capital: "Nassau", region: "Americas", iso2Code: "BS", iso3Code: "BHS", numericCode: "044", phonePrefix: "+1")
        case "BH": return Country(name: "Bahrain", capital: "Manama", region: "Asia", iso2Code: "BH", iso3Code: "BHR", numericCode: "048", phonePrefix: "+973")
        case "BD": return Country(name: "Bangladesh", capital: "Dhaka", region: "Asia", iso2Code: "BD", iso3Code: "BGD", numericCode: "050", phonePrefix: "+880")
        case "BB": return Country(name: "Barbados", capital: "Bridgetown", region: "Americas", iso2Code: "BB", iso3Code: "BRB", numericCode: "052", phonePrefix: "+1")
        case "BY": return Country(name: "Belarus", capital: "Minsk", region: "Europe", iso2Code: "BY", iso3Code: "BLR", numericCode: "112", phonePrefix: "+375")
        case "BE": return Country(name: "Belgium", capital: "Brussels", region: "Europe", iso2Code: "BE", iso3Code: "BEL", numericCode: "056", phonePrefix: "+32")
        case "BZ": return Country(name: "Belize", capital: "Belmopan", region: "Americas", iso2Code: "BZ", iso3Code: "BLZ", numericCode: "084", phonePrefix: "+501")
        case "BJ": return Country(name: "Benin", capital: "Porto-Novo", region: "Africa", iso2Code: "BJ", iso3Code: "BEN", numericCode: "204", phonePrefix: "+229")
        case "BM": return Country(name: "Bermuda", capital: "Hamilton", region: "Americas", iso2Code: "BM", iso3Code: "BMU", numericCode: "060", phonePrefix: "+1")
        case "BT": return Country(name: "Bhutan", capital: "Thimphu", region: "Asia", iso2Code: "BT", iso3Code: "BTN", numericCode: "064", phonePrefix: "+975")
        case "BO": return Country(name: "Bolivia (Plurinational State of)", capital: "Sucre", region: "Americas", iso2Code: "BO", iso3Code: "BOL", numericCode: "068", phonePrefix: "+591")
        case "BQ": return Country(name: "Bonaire, Sint Eustatius and Saba", capital: "Kralendijk", region: "Americas", iso2Code: "BQ", iso3Code: "BES", numericCode: "535", phonePrefix: "+599")
        case "BA": return Country(name: "Bosnia and Herzegovina", capital: "Sarajevo", region: "Europe", iso2Code: "BA", iso3Code: "BIH", numericCode: "070", phonePrefix: "+387")
        case "BW": return Country(name: "Botswana", capital: "Gaborone", region: "Africa", iso2Code: "BW", iso3Code: "BWA", numericCode: "072", phonePrefix: "+267")
        case "BV": return Country(name: "Bouvet Island", capital: nil, region: "Antarctic Ocean", iso2Code: "BV", iso3Code: "BVT", numericCode: "074", phonePrefix: "+47")
        case "BR": return Country(name: "Brazil", capital: "Brasília", region: "Americas", iso2Code: "BR", iso3Code: "BRA", numericCode: "076", phonePrefix: "+55")
        case "IO": return Country(name: "British Indian Ocean Territory", capital: "Diego Garcia", region: "Africa", iso2Code: "IO", iso3Code: "IOT", numericCode: "086", phonePrefix: "+246")
        case "UM": return Country(name: "United States Minor Outlying Islands", capital: nil, region: "Americas", iso2Code: "UM", iso3Code: "UMI", numericCode: "581", phonePrefix: "+246")
        case "VG": return Country(name: "Virgin Islands (British)", capital: "Road Town", region: "Americas", iso2Code: "VG", iso3Code: "VGB", numericCode: "092", phonePrefix: "+1")
        case "VI": return Country(name: "Virgin Islands (U.S.)", capital: "Charlotte Amalie", region: "Americas", iso2Code: "VI", iso3Code: "VIR", numericCode: "850", phonePrefix: "+1-340")
        case "BN": return Country(name: "Brunei Darussalam", capital: "Bandar Seri Begawan", region: "Asia", iso2Code: "BN", iso3Code: "BRN", numericCode: "096", phonePrefix: "+673")
        case "BG": return Country(name: "Bulgaria", capital: "Sofia", region: "Europe", iso2Code: "BG", iso3Code: "BGR", numericCode: "100", phonePrefix: "+359")
        case "BF": return Country(name: "Burkina Faso", capital: "Ouagadougou", region: "Africa", iso2Code: "BF", iso3Code: "BFA", numericCode: "854", phonePrefix: "+226")
        case "BI": return Country(name: "Burundi", capital: "Gitega", region: "Africa", iso2Code: "BI", iso3Code: "BDI", numericCode: "108", phonePrefix: "+257")
        case "KH": return Country(name: "Cambodia", capital: "Phnom Penh", region: "Asia", iso2Code: "KH", iso3Code: "KHM", numericCode: "116", phonePrefix: "+855")
        case "CM": return Country(name: "Cameroon", capital: "Yaoundé", region: "Africa", iso2Code: "CM", iso3Code: "CMR", numericCode: "120", phonePrefix: "+237")
        case "CA": return Country(name: "Canada", capital: "Ottawa", region: "Americas", iso2Code: "CA", iso3Code: "CAN", numericCode: "124", phonePrefix: "+1")
        case "CV": return Country(name: "Cabo Verde", capital: "Praia", region: "Africa", iso2Code: "CV", iso3Code: "CPV", numericCode: "132", phonePrefix: "+238")
        case "KY": return Country(name: "Cayman Islands", capital: "George Town", region: "Americas", iso2Code: "KY", iso3Code: "CYM", numericCode: "136", phonePrefix: "+1")
        case "CF": return Country(name: "Central African Republic", capital: "Bangui", region: "Africa", iso2Code: "CF", iso3Code: "CAF", numericCode: "140", phonePrefix: "+236")
        case "TD": return Country(name: "Chad", capital: "N'Djamena", region: "Africa", iso2Code: "TD", iso3Code: "TCD", numericCode: "148", phonePrefix: "+235")
        case "CL": return Country(name: "Chile", capital: "Santiago", region: "Americas", iso2Code: "CL", iso3Code: "CHL", numericCode: "152", phonePrefix: "+56")
        case "CN": return Country(name: "China", capital: "Beijing", region: "Asia", iso2Code: "CN", iso3Code: "CHN", numericCode: "156", phonePrefix: "+86")
        case "CX": return Country(name: "Christmas Island", capital: "Flying Fish Cove", region: "Oceania", iso2Code: "CX", iso3Code: "CXR", numericCode: "162", phonePrefix: "+61")
        case "CC": return Country(name: "Cocos (Keeling) Islands", capital: "West Island", region: "Oceania", iso2Code: "CC", iso3Code: "CCK", numericCode: "166", phonePrefix: "+61")
        case "CO": return Country(name: "Colombia", capital: "Bogotá", region: "Americas", iso2Code: "CO", iso3Code: "COL", numericCode: "170", phonePrefix: "+57")
        case "KM": return Country(name: "Comoros", capital: "Moroni", region: "Africa", iso2Code: "KM", iso3Code: "COM", numericCode: "174", phonePrefix: "+269")
        case "CG": return Country(name: "Congo", capital: "Brazzaville", region: "Africa", iso2Code: "CG", iso3Code: "COG", numericCode: "178", phonePrefix: "+242")
        case "CD": return Country(name: "Congo (Democratic Republic of the)", capital: "Kinshasa", region: "Africa", iso2Code: "CD", iso3Code: "COD", numericCode: "180", phonePrefix: "+243")
        case "CK": return Country(name: "Cook Islands", capital: "Avarua", region: "Oceania", iso2Code: "CK", iso3Code: "COK", numericCode: "184", phonePrefix: "+682")
        case "CR": return Country(name: "Costa Rica", capital: "San José", region: "Americas", iso2Code: "CR", iso3Code: "CRI", numericCode: "188", phonePrefix: "+506")
        case "HR": return Country(name: "Croatia", capital: "Zagreb", region: "Europe", iso2Code: "HR", iso3Code: "HRV", numericCode: "191", phonePrefix: "+385")
        case "CU": return Country(name: "Cuba", capital: "Havana", region: "Americas", iso2Code: "CU", iso3Code: "CUB", numericCode: "192", phonePrefix: "+53")
        case "CW": return Country(name: "Curaçao", capital: "Willemstad", region: "Americas", iso2Code: "CW", iso3Code: "CUW", numericCode: "531", phonePrefix: "+599")
        case "CY": return Country(name: "Cyprus", capital: "Nicosia", region: "Europe", iso2Code: "CY", iso3Code: "CYP", numericCode: "196", phonePrefix: "+357")
        case "CZ": return Country(name: "Czech Republic", capital: "Prague", region: "Europe", iso2Code: "CZ", iso3Code: "CZE", numericCode: "203", phonePrefix: "+420")
        case "DK": return Country(name: "Denmark", capital: "Copenhagen", region: "Europe", iso2Code: "DK", iso3Code: "DNK", numericCode: "208", phonePrefix: "+45")
        case "DJ": return Country(name: "Djibouti", capital: "Djibouti", region: "Africa", iso2Code: "DJ", iso3Code: "DJI", numericCode: "262", phonePrefix: "+253")
        case "DM": return Country(name: "Dominica", capital: "Roseau", region: "Americas", iso2Code: "DM", iso3Code: "DMA", numericCode: "212", phonePrefix: "+1")
        case "DO": return Country(name: "Dominican Republic", capital: "Santo Domingo", region: "Americas", iso2Code: "DO", iso3Code: "DOM", numericCode: "214", phonePrefix: "+1")
        case "EC": return Country(name: "Ecuador", capital: "Quito", region: "Americas", iso2Code: "EC", iso3Code: "ECU", numericCode: "218", phonePrefix: "+593")
        case "EG": return Country(name: "Egypt", capital: "Cairo", region: "Africa", iso2Code: "EG", iso3Code: "EGY", numericCode: "818", phonePrefix: "+20")
        case "SV": return Country(name: "El Salvador", capital: "San Salvador", region: "Americas", iso2Code: "SV", iso3Code: "SLV", numericCode: "222", phonePrefix: "+503")
        case "GQ": return Country(name: "Equatorial Guinea", capital: "Malabo", region: "Africa", iso2Code: "GQ", iso3Code: "GNQ", numericCode: "226", phonePrefix: "+240")
        case "ER": return Country(name: "Eritrea", capital: "Asmara", region: "Africa", iso2Code: "ER", iso3Code: "ERI", numericCode: "232", phonePrefix: "+291")
        case "EE": return Country(name: "Estonia", capital: "Tallinn", region: "Europe", iso2Code: "EE", iso3Code: "EST", numericCode: "233", phonePrefix: "+372")
        case "ET": return Country(name: "Ethiopia", capital: "Addis Ababa", region: "Africa", iso2Code: "ET", iso3Code: "ETH", numericCode: "231", phonePrefix: "+251")
        case "FK": return Country(name: "Falkland Islands (Malvinas)", capital: "Stanley", region: "Americas", iso2Code: "FK", iso3Code: "FLK", numericCode: "238", phonePrefix: "+500")
        case "FO": return Country(name: "Faroe Islands", capital: "Tórshavn", region: "Europe", iso2Code: "FO", iso3Code: "FRO", numericCode: "234", phonePrefix: "+298")
        case "FJ": return Country(name: "Fiji", capital: "Suva", region: "Oceania", iso2Code: "FJ", iso3Code: "FJI", numericCode: "242", phonePrefix: "+679")
        case "FI": return Country(name: "Finland", capital: "Helsinki", region: "Europe", iso2Code: "FI", iso3Code: "FIN", numericCode: "246", phonePrefix: "+358")
        case "FR": return Country(name: "France", capital: "Paris", region: "Europe", iso2Code: "FR", iso3Code: "FRA", numericCode: "250", phonePrefix: "+33")
        case "GF": return Country(name: "French Guiana", capital: "Cayenne", region: "Americas", iso2Code: "GF", iso3Code: "GUF", numericCode: "254", phonePrefix: "+594")
        case "PF": return Country(name: "French Polynesia", capital: "Papeetē", region: "Oceania", iso2Code: "PF", iso3Code: "PYF", numericCode: "258", phonePrefix: "+689")
        case "TF": return Country(name: "French Southern Territories", capital: "Port-aux-Français", region: "Africa", iso2Code: "TF", iso3Code: "ATF", numericCode: "260", phonePrefix: "+262")
        case "GA": return Country(name: "Gabon", capital: "Libreville", region: "Africa", iso2Code: "GA", iso3Code: "GAB", numericCode: "266", phonePrefix: "+241")
        case "GM": return Country(name: "Gambia", capital: "Banjul", region: "Africa", iso2Code: "GM", iso3Code: "GMB", numericCode: "270", phonePrefix: "+220")
        case "GE": return Country(name: "Georgia", capital: "Tbilisi", region: "Asia", iso2Code: "GE", iso3Code: "GEO", numericCode: "268", phonePrefix: "+995")
        case "DE": return Country(name: "Germany", capital: "Berlin", region: "Europe", iso2Code: "DE", iso3Code: "DEU", numericCode: "276", phonePrefix: "+49")
        case "GH": return Country(name: "Ghana", capital: "Accra", region: "Africa", iso2Code: "GH", iso3Code: "GHA", numericCode: "288", phonePrefix: "+233")
        case "GI": return Country(name: "Gibraltar", capital: "Gibraltar", region: "Europe", iso2Code: "GI", iso3Code: "GIB", numericCode: "292", phonePrefix: "+350")
        case "GR": return Country(name: "Greece", capital: "Athens", region: "Europe", iso2Code: "GR", iso3Code: "GRC", numericCode: "300", phonePrefix: "+30")
        case "GL": return Country(name: "Greenland", capital: "Nuuk", region: "Americas", iso2Code: "GL", iso3Code: "GRL", numericCode: "304", phonePrefix: "+299")
        case "GD": return Country(name: "Grenada", capital: "St. George's", region: "Americas", iso2Code: "GD", iso3Code: "GRD", numericCode: "308", phonePrefix: "+1")
        case "GP": return Country(name: "Guadeloupe", capital: "Basse-Terre", region: "Americas", iso2Code: "GP", iso3Code: "GLP", numericCode: "312", phonePrefix: "+590")
        case "GU": return Country(name: "Guam", capital: "Hagåtña", region: "Oceania", iso2Code: "GU", iso3Code: "GUM", numericCode: "316", phonePrefix: "+1")
        case "GT": return Country(name: "Guatemala", capital: "Guatemala City", region: "Americas", iso2Code: "GT", iso3Code: "GTM", numericCode: "320", phonePrefix: "+502")
        case "GG": return Country(name: "Guernsey", capital: "St. Peter Port", region: "Europe", iso2Code: "GG", iso3Code: "GGY", numericCode: "831", phonePrefix: "+44")
        case "GN": return Country(name: "Guinea", capital: "Conakry", region: "Africa", iso2Code: "GN", iso3Code: "GIN", numericCode: "324", phonePrefix: "+224")
        case "GW": return Country(name: "Guinea-Bissau", capital: "Bissau", region: "Africa", iso2Code: "GW", iso3Code: "GNB", numericCode: "624", phonePrefix: "+245")
        case "GY": return Country(name: "Guyana", capital: "Georgetown", region: "Americas", iso2Code: "GY", iso3Code: "GUY", numericCode: "328", phonePrefix: "+592")
        case "HT": return Country(name: "Haiti", capital: "Port-au-Prince", region: "Americas", iso2Code: "HT", iso3Code: "HTI", numericCode: "332", phonePrefix: "+509")
        case "HM": return Country(name: "Heard Island and McDonald Islands", capital: nil, region: "Antarctic", iso2Code: "HM", iso3Code: "HMD", numericCode: "334", phonePrefix: "+672")
        case "VA": return Country(name: "Vatican City", capital: "Vatican City", region: "Europe", iso2Code: "VA", iso3Code: "VAT", numericCode: "336", phonePrefix: "+379")
        case "HN": return Country(name: "Honduras", capital: "Tegucigalpa", region: "Americas", iso2Code: "HN", iso3Code: "HND", numericCode: "340", phonePrefix: "+504")
        case "HU": return Country(name: "Hungary", capital: "Budapest", region: "Europe", iso2Code: "HU", iso3Code: "HUN", numericCode: "348", phonePrefix: "+36")
        case "HK": return Country(name: "Hong Kong", capital: "City of Victoria", region: "Asia", iso2Code: "HK", iso3Code: "HKG", numericCode: "344", phonePrefix: "+852")
        case "IS": return Country(name: "Iceland", capital: "Reykjavík", region: "Europe", iso2Code: "IS", iso3Code: "ISL", numericCode: "352", phonePrefix: "+354")
        case "IN": return Country(name: "India", capital: "New Delhi", region: "Asia", iso2Code: "IN", iso3Code: "IND", numericCode: "356", phonePrefix: "+91")
        case "ID": return Country(name: "Indonesia", capital: "Jakarta", region: "Asia", iso2Code: "ID", iso3Code: "IDN", numericCode: "360", phonePrefix: "+62")
        case "CI": return Country(name: "Ivory Coast", capital: "Yamoussoukro", region: "Africa", iso2Code: "CI", iso3Code: "CIV", numericCode: "384", phonePrefix: "+225")
        case "IR": return Country(name: "Iran (Islamic Republic of)", capital: "Tehran", region: "Asia", iso2Code: "IR", iso3Code: "IRN", numericCode: "364", phonePrefix: "+98")
        case "IQ": return Country(name: "Iraq", capital: "Baghdad", region: "Asia", iso2Code: "IQ", iso3Code: "IRQ", numericCode: "368", phonePrefix: "+964")
        case "IE": return Country(name: "Ireland", capital: "Dublin", region: "Europe", iso2Code: "IE", iso3Code: "IRL", numericCode: "372", phonePrefix: "+353")
        case "IM": return Country(name: "Isle of Man", capital: "Douglas", region: "Europe", iso2Code: "IM", iso3Code: "IMN", numericCode: "833", phonePrefix: "+44")
        case "IL": return Country(name: "Israel", capital: "Jerusalem", region: "Asia", iso2Code: "IL", iso3Code: "ISR", numericCode: "376", phonePrefix: "+972")
        case "IT": return Country(name: "Italy", capital: "Rome", region: "Europe", iso2Code: "IT", iso3Code: "ITA", numericCode: "380", phonePrefix: "+39")
        case "JM": return Country(name: "Jamaica", capital: "Kingston", region: "Americas", iso2Code: "JM", iso3Code: "JAM", numericCode: "388", phonePrefix: "+1")
        case "JP": return Country(name: "Japan", capital: "Tokyo", region: "Asia", iso2Code: "JP", iso3Code: "JPN", numericCode: "392", phonePrefix: "+81")
        case "JE": return Country(name: "Jersey", capital: "Saint Helier", region: "Europe", iso2Code: "JE", iso3Code: "JEY", numericCode: "832", phonePrefix: "+44")
        case "JO": return Country(name: "Jordan", capital: "Amman", region: "Asia", iso2Code: "JO", iso3Code: "JOR", numericCode: "400", phonePrefix: "+962")
        case "KZ": return Country(name: "Kazakhstan", capital: "Nur-Sultan", region: "Asia", iso2Code: "KZ", iso3Code: "KAZ", numericCode: "398", phonePrefix: "+76")
        case "KE": return Country(name: "Kenya", capital: "Nairobi", region: "Africa", iso2Code: "KE", iso3Code: "KEN", numericCode: "404", phonePrefix: "+254")
        case "KI": return Country(name: "Kiribati", capital: "South Tarawa", region: "Oceania", iso2Code: "KI", iso3Code: "KIR", numericCode: "296", phonePrefix: "+686")
        case "KW": return Country(name: "Kuwait", capital: "Kuwait City", region: "Asia", iso2Code: "KW", iso3Code: "KWT", numericCode: "414", phonePrefix: "+965")
        case "KG": return Country(name: "Kyrgyzstan", capital: "Bishkek", region: "Asia", iso2Code: "KG", iso3Code: "KGZ", numericCode: "417", phonePrefix: "+996")
        case "LA": return Country(name: "Lao People's Democratic Republic", capital: "Vientiane", region: "Asia", iso2Code: "LA", iso3Code: "LAO", numericCode: "418", phonePrefix: "+856")
        case "LV": return Country(name: "Latvia", capital: "Riga", region: "Europe", iso2Code: "LV", iso3Code: "LVA", numericCode: "428", phonePrefix: "+371")
        case "LB": return Country(name: "Lebanon", capital: "Beirut", region: "Asia", iso2Code: "LB", iso3Code: "LBN", numericCode: "422", phonePrefix: "+961")
        case "LS": return Country(name: "Lesotho", capital: "Maseru", region: "Africa", iso2Code: "LS", iso3Code: "LSO", numericCode: "426", phonePrefix: "+266")
        case "LR": return Country(name: "Liberia", capital: "Monrovia", region: "Africa", iso2Code: "LR", iso3Code: "LBR", numericCode: "430", phonePrefix: "+231")
        case "LY": return Country(name: "Libya", capital: "Tripoli", region: "Africa", iso2Code: "LY", iso3Code: "LBY", numericCode: "434", phonePrefix: "+218")
        case "LI": return Country(name: "Liechtenstein", capital: "Vaduz", region: "Europe", iso2Code: "LI", iso3Code: "LIE", numericCode: "438", phonePrefix: "+423")
        case "LT": return Country(name: "Lithuania", capital: "Vilnius", region: "Europe", iso2Code: "LT", iso3Code: "LTU", numericCode: "440", phonePrefix: "+370")
        case "LU": return Country(name: "Luxembourg", capital: "Luxembourg", region: "Europe", iso2Code: "LU", iso3Code: "LUX", numericCode: "442", phonePrefix: "+352")
        case "MO": return Country(name: "Macao", capital: nil, region: "Asia", iso2Code: "MO", iso3Code: "MAC", numericCode: "446", phonePrefix: "+853")
        case "MK": return Country(name: "North Macedonia", capital: "Skopje", region: "Europe", iso2Code: "MK", iso3Code: "MKD", numericCode: "807", phonePrefix: "+389")
        case "MG": return Country(name: "Madagascar", capital: "Antananarivo", region: "Africa", iso2Code: "MG", iso3Code: "MDG", numericCode: "450", phonePrefix: "+261")
        case "MW": return Country(name: "Malawi", capital: "Lilongwe", region: "Africa", iso2Code: "MW", iso3Code: "MWI", numericCode: "454", phonePrefix: "+265")
        case "MY": return Country(name: "Malaysia", capital: "Kuala Lumpur", region: "Asia", iso2Code: "MY", iso3Code: "MYS", numericCode: "458", phonePrefix: "+60")
        case "MV": return Country(name: "Maldives", capital: "Malé", region: "Asia", iso2Code: "MV", iso3Code: "MDV", numericCode: "462", phonePrefix: "+960")
        case "ML": return Country(name: "Mali", capital: "Bamako", region: "Africa", iso2Code: "ML", iso3Code: "MLI", numericCode: "466", phonePrefix: "+223")
        case "MT": return Country(name: "Malta", capital: "Valletta", region: "Europe", iso2Code: "MT", iso3Code: "MLT", numericCode: "470", phonePrefix: "+356")
        case "MH": return Country(name: "Marshall Islands", capital: "Majuro", region: "Oceania", iso2Code: "MH", iso3Code: "MHL", numericCode: "584", phonePrefix: "+692")
        case "MQ": return Country(name: "Martinique", capital: "Fort-de-France", region: "Americas", iso2Code: "MQ", iso3Code: "MTQ", numericCode: "474", phonePrefix: "+596")
        case "MR": return Country(name: "Mauritania", capital: "Nouakchott", region: "Africa", iso2Code: "MR", iso3Code: "MRT", numericCode: "478", phonePrefix: "+222")
        case "MU": return Country(name: "Mauritius", capital: "Port Louis", region: "Africa", iso2Code: "MU", iso3Code: "MUS", numericCode: "480", phonePrefix: "+230")
        case "YT": return Country(name: "Mayotte", capital: "Mamoudzou", region: "Africa", iso2Code: "YT", iso3Code: "MYT", numericCode: "175", phonePrefix: "+262")
        case "MX": return Country(name: "Mexico", capital: "Mexico City", region: "Americas", iso2Code: "MX", iso3Code: "MEX", numericCode: "484", phonePrefix: "+52")
        case "FM": return Country(name: "Micronesia (Federated States of)", capital: "Palikir", region: "Oceania", iso2Code: "FM", iso3Code: "FSM", numericCode: "583", phonePrefix: "+691")
        case "MD": return Country(name: "Moldova (Republic of)", capital: "Chișinău", region: "Europe", iso2Code: "MD", iso3Code: "MDA", numericCode: "498", phonePrefix: "+373")
        case "MC": return Country(name: "Monaco", capital: "Monaco", region: "Europe", iso2Code: "MC", iso3Code: "MCO", numericCode: "492", phonePrefix: "+377")
        case "MN": return Country(name: "Mongolia", capital: "Ulan Bator", region: "Asia", iso2Code: "MN", iso3Code: "MNG", numericCode: "496", phonePrefix: "+976")
        case "ME": return Country(name: "Montenegro", capital: "Podgorica", region: "Europe", iso2Code: "ME", iso3Code: "MNE", numericCode: "499", phonePrefix: "+382")
        case "MS": return Country(name: "Montserrat", capital: "Plymouth", region: "Americas", iso2Code: "MS", iso3Code: "MSR", numericCode: "500", phonePrefix: "+1")
        case "MA": return Country(name: "Morocco", capital: "Rabat", region: "Africa", iso2Code: "MA", iso3Code: "MAR", numericCode: "504", phonePrefix: "+212")
        case "MZ": return Country(name: "Mozambique", capital: "Maputo", region: "Africa", iso2Code: "MZ", iso3Code: "MOZ", numericCode: "508", phonePrefix: "+258")
        case "MM": return Country(name: "Myanmar", capital: "Naypyidaw", region: "Asia", iso2Code: "MM", iso3Code: "MMR", numericCode: "104", phonePrefix: "+95")
        case "NA": return Country(name: "Namibia", capital: "Windhoek", region: "Africa", iso2Code: "NA", iso3Code: "NAM", numericCode: "516", phonePrefix: "+264")
        case "NR": return Country(name: "Nauru", capital: "Yaren", region: "Oceania", iso2Code: "NR", iso3Code: "NRU", numericCode: "520", phonePrefix: "+674")
        case "NP": return Country(name: "Nepal", capital: "Kathmandu", region: "Asia", iso2Code: "NP", iso3Code: "NPL", numericCode: "524", phonePrefix: "+977")
        case "NL": return Country(name: "Netherlands", capital: "Amsterdam", region: "Europe", iso2Code: "NL", iso3Code: "NLD", numericCode: "528", phonePrefix: "+31")
        case "NC": return Country(name: "New Caledonia", capital: "Nouméa", region: "Oceania", iso2Code: "NC", iso3Code: "NCL", numericCode: "540", phonePrefix: "+687")
        case "NZ": return Country(name: "New Zealand", capital: "Wellington", region: "Oceania", iso2Code: "NZ", iso3Code: "NZL", numericCode: "554", phonePrefix: "+64")
        case "NI": return Country(name: "Nicaragua", capital: "Managua", region: "Americas", iso2Code: "NI", iso3Code: "NIC", numericCode: "558", phonePrefix: "+505")
        case "NE": return Country(name: "Niger", capital: "Niamey", region: "Africa", iso2Code: "NE", iso3Code: "NER", numericCode: "562", phonePrefix: "+227")
        case "NG": return Country(name: "Nigeria", capital: "Abuja", region: "Africa", iso2Code: "NG", iso3Code: "NGA", numericCode: "566", phonePrefix: "+234")
        case "NU": return Country(name: "Niue", capital: "Alofi", region: "Oceania", iso2Code: "NU", iso3Code: "NIU", numericCode: "570", phonePrefix: "+683")
        case "NF": return Country(name: "Norfolk Island", capital: "Kingston", region: "Oceania", iso2Code: "NF", iso3Code: "NFK", numericCode: "574", phonePrefix: "+672")
        case "KP": return Country(name: "Korea (Democratic People's Republic of)", capital: "Pyongyang", region: "Asia", iso2Code: "KP", iso3Code: "PRK", numericCode: "408", phonePrefix: "+850")
        case "MP": return Country(name: "Northern Mariana Islands", capital: "Saipan", region: "Oceania", iso2Code: "MP", iso3Code: "MNP", numericCode: "580", phonePrefix: "+1")
        case "NO": return Country(name: "Norway", capital: "Oslo", region: "Europe", iso2Code: "NO", iso3Code: "NOR", numericCode: "578", phonePrefix: "+47")
        case "OM": return Country(name: "Oman", capital: "Muscat", region: "Asia", iso2Code: "OM", iso3Code: "OMN", numericCode: "512", phonePrefix: "+968")
        case "PK": return Country(name: "Pakistan", capital: "Islamabad", region: "Asia", iso2Code: "PK", iso3Code: "PAK", numericCode: "586", phonePrefix: "+92")
        case "PW": return Country(name: "Palau", capital: "Ngerulmud", region: "Oceania", iso2Code: "PW", iso3Code: "PLW", numericCode: "585", phonePrefix: "+680")
        case "PS": return Country(name: "Palestine, State of", capital: "Ramallah", region: "Asia", iso2Code: "PS", iso3Code: "PSE", numericCode: "275", phonePrefix: "+970")
        case "PA": return Country(name: "Panama", capital: "Panama City", region: "Americas", iso2Code: "PA", iso3Code: "PAN", numericCode: "591", phonePrefix: "+507")
        case "PG": return Country(name: "Papua New Guinea", capital: "Port Moresby", region: "Oceania", iso2Code: "PG", iso3Code: "PNG", numericCode: "598", phonePrefix: "+675")
        case "PY": return Country(name: "Paraguay", capital: "Asunción", region: "Americas", iso2Code: "PY", iso3Code: "PRY", numericCode: "600", phonePrefix: "+595")
        case "PE": return Country(name: "Peru", capital: "Lima", region: "Americas", iso2Code: "PE", iso3Code: "PER", numericCode: "604", phonePrefix: "+51")
        case "PH": return Country(name: "Philippines", capital: "Manila", region: "Asia", iso2Code: "PH", iso3Code: "PHL", numericCode: "608", phonePrefix: "+63")
        case "PN": return Country(name: "Pitcairn", capital: "Adamstown", region: "Oceania", iso2Code: "PN", iso3Code: "PCN", numericCode: "612", phonePrefix: "+64")
        case "PL": return Country(name: "Poland", capital: "Warsaw", region: "Europe", iso2Code: "PL", iso3Code: "POL", numericCode: "616", phonePrefix: "+48")
        case "PT": return Country(name: "Portugal", capital: "Lisbon", region: "Europe", iso2Code: "PT", iso3Code: "PRT", numericCode: "620", phonePrefix: "+351")
        case "PR": return Country(name: "Puerto Rico", capital: "San Juan", region: "Americas", iso2Code: "PR", iso3Code: "PRI", numericCode: "630", phonePrefix: "+1")
        case "QA": return Country(name: "Qatar", capital: "Doha", region: "Asia", iso2Code: "QA", iso3Code: "QAT", numericCode: "634", phonePrefix: "+974")
        case "XK": return Country(name: "Republic of Kosovo", capital: "Pristina", region: "Europe", iso2Code: "XK", iso3Code: "UNK", numericCode: "926", phonePrefix: "+383")
        case "RE": return Country(name: "Réunion", capital: "Saint-Denis", region: "Africa", iso2Code: "RE", iso3Code: "REU", numericCode: "638", phonePrefix: "+262")
        case "RO": return Country(name: "Romania", capital: "Bucharest", region: "Europe", iso2Code: "RO", iso3Code: "ROU", numericCode: "642", phonePrefix: "+40")
        case "RU": return Country(name: "Russian Federation", capital: "Moscow", region: "Europe", iso2Code: "RU", iso3Code: "RUS", numericCode: "643", phonePrefix: "+7")
        case "RW": return Country(name: "Rwanda", capital: "Kigali", region: "Africa", iso2Code: "RW", iso3Code: "RWA", numericCode: "646", phonePrefix: "+250")
        case "BL": return Country(name: "Saint Barthélemy", capital: "Gustavia", region: "Americas", iso2Code: "BL", iso3Code: "BLM", numericCode: "652", phonePrefix: "+590")
        case "SH": return Country(name: "Saint Helena, Ascension and Tristan da Cunha", capital: "Jamestown", region: "Africa", iso2Code: "SH", iso3Code: "SHN", numericCode: "654", phonePrefix: "+290")
        case "KN": return Country(name: "Saint Kitts and Nevis", capital: "Basseterre", region: "Americas", iso2Code: "KN", iso3Code: "KNA", numericCode: "659", phonePrefix: "+1")
        case "LC": return Country(name: "Saint Lucia", capital: "Castries", region: "Americas", iso2Code: "LC", iso3Code: "LCA", numericCode: "662", phonePrefix: "+1")
        case "MF": return Country(name: "Saint Martin (French part)", capital: "Marigot", region: "Americas", iso2Code: "MF", iso3Code: "MAF", numericCode: "663", phonePrefix: "+590")
        case "PM": return Country(name: "Saint Pierre and Miquelon", capital: "Saint-Pierre", region: "Americas", iso2Code: "PM", iso3Code: "SPM", numericCode: "666", phonePrefix: "+508")
        case "VC": return Country(name: "Saint Vincent and the Grenadines", capital: "Kingstown", region: "Americas", iso2Code: "VC", iso3Code: "VCT", numericCode: "670", phonePrefix: "+1")
        case "WS": return Country(name: "Samoa", capital: "Apia", region: "Oceania", iso2Code: "WS", iso3Code: "WSM", numericCode: "882", phonePrefix: "+685")
        case "SM": return Country(name: "San Marino", capital: "City of San Marino", region: "Europe", iso2Code: "SM", iso3Code: "SMR", numericCode: "674", phonePrefix: "+378")
        case "ST": return Country(name: "Sao Tome and Principe", capital: "São Tomé", region: "Africa", iso2Code: "ST", iso3Code: "STP", numericCode: "678", phonePrefix: "+239")
        case "SA": return Country(name: "Saudi Arabia", capital: "Riyadh", region: "Asia", iso2Code: "SA", iso3Code: "SAU", numericCode: "682", phonePrefix: "+966")
        case "SN": return Country(name: "Senegal", capital: "Dakar", region: "Africa", iso2Code: "SN", iso3Code: "SEN", numericCode: "686", phonePrefix: "+221")
        case "RS": return Country(name: "Serbia", capital: "Belgrade", region: "Europe", iso2Code: "RS", iso3Code: "SRB", numericCode: "688", phonePrefix: "+381")
        case "SC": return Country(name: "Seychelles", capital: "Victoria", region: "Africa", iso2Code: "SC", iso3Code: "SYC", numericCode: "690", phonePrefix: "+248")
        case "SL": return Country(name: "Sierra Leone", capital: "Freetown", region: "Africa", iso2Code: "SL", iso3Code: "SLE", numericCode: "694", phonePrefix: "+232")
        case "SG": return Country(name: "Singapore", capital: "Singapore", region: "Asia", iso2Code: "SG", iso3Code: "SGP", numericCode: "702", phonePrefix: "+65")
        case "SX": return Country(name: "Sint Maarten (Dutch part)", capital: "Philipsburg", region: "Americas", iso2Code: "SX", iso3Code: "SXM", numericCode: "534", phonePrefix: "+1")
        case "SK": return Country(name: "Slovakia", capital: "Bratislava", region: "Europe", iso2Code: "SK", iso3Code: "SVK", numericCode: "703", phonePrefix: "+421")
        case "SI": return Country(name: "Slovenia", capital: "Ljubljana", region: "Europe", iso2Code: "SI", iso3Code: "SVN", numericCode: "705", phonePrefix: "+386")
        case "SB": return Country(name: "Solomon Islands", capital: "Honiara", region: "Oceania", iso2Code: "SB", iso3Code: "SLB", numericCode: "090", phonePrefix: "+677")
        case "SO": return Country(name: "Somalia", capital: "Mogadishu", region: "Africa", iso2Code: "SO", iso3Code: "SOM", numericCode: "706", phonePrefix: "+252")
        case "ZA": return Country(name: "South Africa", capital: "Pretoria", region: "Africa", iso2Code: "ZA", iso3Code: "ZAF", numericCode: "710", phonePrefix: "+27")
        case "GS": return Country(name: "South Georgia and the South Sandwich Islands", capital: "King Edward Point", region: "Americas", iso2Code: "GS", iso3Code: "SGS", numericCode: "239", phonePrefix: "+500")
        case "KR": return Country(name: "Korea (Republic of)", capital: "Seoul", region: "Asia", iso2Code: "KR", iso3Code: "KOR", numericCode: "410", phonePrefix: "+82")
        case "ES": return Country(name: "Spain", capital: "Madrid", region: "Europe", iso2Code: "ES", iso3Code: "ESP", numericCode: "724", phonePrefix: "+34")
        case "LK": return Country(name: "Sri Lanka", capital: "Sri Jayawardenepura Kotte", region: "Asia", iso2Code: "LK", iso3Code: "LKA", numericCode: "144", phonePrefix: "+94")
        case "SD": return Country(name: "Sudan", capital: "Khartoum", region: "Africa", iso2Code: "SD", iso3Code: "SDN", numericCode: "729", phonePrefix: "+249")
        case "SS": return Country(name: "South Sudan", capital: "Juba", region: "Africa", iso2Code: "SS", iso3Code: "SSD", numericCode: "728", phonePrefix: "+211")
        case "SR": return Country(name: "Suriname", capital: "Paramaribo", region: "Americas", iso2Code: "SR", iso3Code: "SUR", numericCode: "740", phonePrefix: "+597")
        case "SJ": return Country(name: "Svalbard and Jan Mayen", capital: "Longyearbyen", region: "Europe", iso2Code: "SJ", iso3Code: "SJM", numericCode: "744", phonePrefix: "+47")
        case "SZ": return Country(name: "Swaziland", capital: "Mbabane", region: "Africa", iso2Code: "SZ", iso3Code: "SWZ", numericCode: "748", phonePrefix: "+268")
        case "SE": return Country(name: "Sweden", capital: "Stockholm", region: "Europe", iso2Code: "SE", iso3Code: "SWE", numericCode: "752", phonePrefix: "+46")
        case "CH": return Country(name: "Switzerland", capital: "Bern", region: "Europe", iso2Code: "CH", iso3Code: "CHE", numericCode: "756", phonePrefix: "+41")
        case "SY": return Country(name: "Syrian Arab Republic", capital: "Damascus", region: "Asia", iso2Code: "SY", iso3Code: "SYR", numericCode: "760", phonePrefix: "+963")
        case "TW": return Country(name: "Taiwan", capital: "Taipei", region: "Asia", iso2Code: "TW", iso3Code: "TWN", numericCode: "158", phonePrefix: "+886")
        case "TJ": return Country(name: "Tajikistan", capital: "Dushanbe", region: "Asia", iso2Code: "TJ", iso3Code: "TJK", numericCode: "762", phonePrefix: "+992")
        case "TZ": return Country(name: "Tanzania, United Republic of", capital: "Dodoma", region: "Africa", iso2Code: "TZ", iso3Code: "TZA", numericCode: "834", phonePrefix: "+255")
        case "TH": return Country(name: "Thailand", capital: "Bangkok", region: "Asia", iso2Code: "TH", iso3Code: "THA", numericCode: "764", phonePrefix: "+66")
        case "TL": return Country(name: "Timor-Leste", capital: "Dili", region: "Asia", iso2Code: "TL", iso3Code: "TLS", numericCode: "626", phonePrefix: "+670")
        case "TG": return Country(name: "Togo", capital: "Lomé", region: "Africa", iso2Code: "TG", iso3Code: "TGO", numericCode: "768", phonePrefix: "+228")
        case "TK": return Country(name: "Tokelau", capital: "Fakaofo", region: "Oceania", iso2Code: "TK", iso3Code: "TKL", numericCode: "772", phonePrefix: "+690")
        case "TO": return Country(name: "Tonga", capital: "Nuku'alofa", region: "Oceania", iso2Code: "TO", iso3Code: "TON", numericCode: "776", phonePrefix: "+676")
        case "TT": return Country(name: "Trinidad and Tobago", capital: "Port of Spain", region: "Americas", iso2Code: "TT", iso3Code: "TTO", numericCode: "780", phonePrefix: "+1")
        case "TN": return Country(name: "Tunisia", capital: "Tunis", region: "Africa", iso2Code: "TN", iso3Code: "TUN", numericCode: "788", phonePrefix: "+216")
        case "TR": return Country(name: "Turkey", capital: "Ankara", region: "Asia", iso2Code: "TR", iso3Code: "TUR", numericCode: "792", phonePrefix: "+90")
        case "TM": return Country(name: "Turkmenistan", capital: "Ashgabat", region: "Asia", iso2Code: "TM", iso3Code: "TKM", numericCode: "795", phonePrefix: "+993")
        case "TC": return Country(name: "Turks and Caicos Islands", capital: "Cockburn Town", region: "Americas", iso2Code: "TC", iso3Code: "TCA", numericCode: "796", phonePrefix: "+1")
        case "TV": return Country(name: "Tuvalu", capital: "Funafuti", region: "Oceania", iso2Code: "TV", iso3Code: "TUV", numericCode: "798", phonePrefix: "+688")
        case "UG": return Country(name: "Uganda", capital: "Kampala", region: "Africa", iso2Code: "UG", iso3Code: "UGA", numericCode: "800", phonePrefix: "+256")
        case "UA": return Country(name: "Ukraine", capital: "Kyiv", region: "Europe", iso2Code: "UA", iso3Code: "UKR", numericCode: "804", phonePrefix: "+380")
        case "AE": return Country(name: "United Arab Emirates", capital: "Abu Dhabi", region: "Asia", iso2Code: "AE", iso3Code: "ARE", numericCode: "784", phonePrefix: "+971")
        case "GB": return Country(name: "United Kingdom of Great Britain and Northern Ireland", capital: "London", region: "Europe", iso2Code: "GB", iso3Code: "GBR", numericCode: "826", phonePrefix: "+44")
        case "US": return Country(name: "United States of America", capital: "Washington, D.C.", region: "Americas", iso2Code: "US", iso3Code: "USA", numericCode: "840", phonePrefix: "+1")
        case "UY": return Country(name: "Uruguay", capital: "Montevideo", region: "Americas", iso2Code: "UY", iso3Code: "URY", numericCode: "858", phonePrefix: "+598")
        case "UZ": return Country(name: "Uzbekistan", capital: "Tashkent", region: "Asia", iso2Code: "UZ", iso3Code: "UZB", numericCode: "860", phonePrefix: "+998")
        case "VU": return Country(name: "Vanuatu", capital: "Port Vila", region: "Oceania", iso2Code: "VU", iso3Code: "VUT", numericCode: "548", phonePrefix: "+678")
        case "VE": return Country(name: "Venezuela (Bolivarian Republic of)", capital: "Caracas", region: "Americas", iso2Code: "VE", iso3Code: "VEN", numericCode: "862", phonePrefix: "+58")
        case "VN": return Country(name: "Vietnam", capital: "Hanoi", region: "Asia", iso2Code: "VN", iso3Code: "VNM", numericCode: "704", phonePrefix: "+84")
        case "WF": return Country(name: "Wallis and Futuna", capital: "Mata-Utu", region: "Oceania", iso2Code: "WF", iso3Code: "WLF", numericCode: "876", phonePrefix: "+681")
        case "EH": return Country(name: "Western Sahara", capital: "El Aaiún", region: "Africa", iso2Code: "EH", iso3Code: "ESH", numericCode: "732", phonePrefix: "+212")
        case "YE": return Country(name: "Yemen", capital: "Sana'a", region: "Asia", iso2Code: "YE", iso3Code: "YEM", numericCode: "887", phonePrefix: "+967")
        case "ZM": return Country(name: "Zambia", capital: "Lusaka", region: "Africa", iso2Code: "ZM", iso3Code: "ZMB", numericCode: "894", phonePrefix: "+260")
        case "ZW": return Country(name: "Zimbabwe", capital: "Harare", region: "Africa", iso2Code: "ZW", iso3Code: "ZWE", numericCode: "716", phonePrefix: "+263")
        default: return nil
        }
        
    }
}
