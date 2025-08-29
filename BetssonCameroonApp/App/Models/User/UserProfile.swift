
import Foundation

struct UserProfile: Codable, Hashable {

    var userIdentifier: String
    var sessionKey: String

    var username: String
    var email: String
    var firstName: String?
    var middleName: String?
    var lastName: String?
    var birthDate: Date

    var nationality: Country?
    var country: Country?

    var gender: UserGender
    var title: UserTitle?

    var personalIdNumber: String?
    var address: String?
    var province: String?
    var city: String?
    var postalCode: String?

    var birthDepartment: String?
    var streetNumber: String?
    var phoneNumber: String?
    var mobilePhone: String?
    var mobileCountryCode: String?
    var mobileLocalNumber: String?

    var avatarName: String?
    var godfatherCode: String?
    var placeOfBirth: String?
    var additionalStreetLine: String?

    var isEmailVerified: Bool
    var isRegistrationCompleted: Bool

    var kycStatus: KnowYourCustomerStatus
    var lockedStatus: LockedStatus
    var hasMadeDeposit: Bool
    var kycExpire: String?

    var currency: String?

    init(userIdentifier: String, sessionKey: String, username: String, email: String, firstName: String? = nil, middleName: String? = nil, lastName: String? = nil,
         birthDate: Date, nationality: Country?, country: Country?, gender: UserGender, title: UserTitle?, personalIdNumber: String?,
         address: String?, province: String?, city: String?, postalCode: String?, birthDepartment: String?, streetNumber: String?,
         phoneNumber: String?, mobilePhone: String?, mobileCountryCode: String?, mobileLocalNumber: String?, avatarName: String?,
         godfatherCode: String?, placeOfBirth: String?, additionalStreetLine: String?, isEmailVerified: Bool,
         isRegistrationCompleted: Bool, kycStatus: KnowYourCustomerStatus, lockedStatus: LockedStatus, hasMadeDeposit: Bool, kycExpire: String?, currency: String?) {

        self.userIdentifier = userIdentifier
        self.sessionKey = sessionKey
        self.username = username
        self.email = email
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.birthDate = birthDate
        self.nationality = nationality
        self.country = country
        self.gender = gender
        self.title = title
        self.personalIdNumber = personalIdNumber
        self.address = address
        self.province = province
        self.city = city
        self.postalCode = postalCode
        self.birthDepartment = birthDepartment
        self.streetNumber = streetNumber
        self.phoneNumber = phoneNumber
        self.mobilePhone = mobilePhone
        self.mobileCountryCode = mobileCountryCode
        self.mobileLocalNumber = mobileLocalNumber

        self.avatarName = avatarName
        self.godfatherCode = godfatherCode
        self.placeOfBirth = placeOfBirth
        self.additionalStreetLine = additionalStreetLine

        self.isEmailVerified = isEmailVerified
        self.isRegistrationCompleted = isRegistrationCompleted
        self.kycStatus = kycStatus
        self.lockedStatus = lockedStatus
        self.hasMadeDeposit = hasMadeDeposit
        self.kycExpire = kycExpire
        self.currency = currency
    }

}
