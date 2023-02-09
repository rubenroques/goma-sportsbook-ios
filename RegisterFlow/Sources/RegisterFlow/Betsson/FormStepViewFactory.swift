//
//  File.swift
//  
//
//  Created by Ruben Roques on 28/01/2023.
//

import Foundation
import UIKit
import ServicesProvider

struct FormStepViewFactory {

    static func formStepView(forFormStep formStep: FormStep,
                             serviceProvider: ServicesProviderClient,
                             userRegisterEnvelop: UserRegisterEnvelop,
                             userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater) -> FormStepView {

        let defaultCountryIso3Code = "FRA"

        switch formStep {
        case .gender:
            var gender: GenderFormStepViewModel.Gender? = nil
            if let filledGender = userRegisterEnvelop.gender {
                switch filledGender {
                case .male:  gender = .male
                case .female: gender = .female
                }
            }
            let genderFormStepViewModel = GenderFormStepViewModel(title: "Gender",
                                                                  selectedGender: gender,
                                                                  userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return GenderFormStepView(viewModel: genderFormStepViewModel)
            //
            //
        case .names:
            return NamesFormStepView(viewModel: NamesFormStepViewModel(title: "Names",
                                                                       firstName: userRegisterEnvelop.name,
                                                                       lastName: userRegisterEnvelop.surname,
                                                                       userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .avatar:
            let avatarFormStepViewModel = AvatarFormStepViewModel(title: "Avatar",
                                                                  subtitle: "Choose one of our standard avatars for your icon.",
                                                                  avatarIconNames: ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6",],
                                                                  selectedAvatarName: userRegisterEnvelop.avatarName,
                                                                  userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return AvatarFormStepView(viewModel: avatarFormStepViewModel)
            //
            //
        case .nickname:
            let nicknameFormStepViewModel = NicknameFormStepViewModel(title: "Nickname",
                                                                      nickname: userRegisterEnvelop.nickname,
                                                                      serviceProvider: serviceProvider,
                                                                      userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return NicknameFormStepView(viewModel: nicknameFormStepViewModel)
            //
            //
        case .ageCountry:
            let ageCountryFormStepViewModel = AgeCountryFormStepViewModel(title: "Age and Country",
                                                                          defaultCountryIso3Code: defaultCountryIso3Code,
                                                                          birthDate: userRegisterEnvelop.dateOfBirth,
                                                                          selectedCountry: userRegisterEnvelop.countryBirth,
                                                                          placeBirth: userRegisterEnvelop.placeBirth,
                                                                          serviceProvider: serviceProvider,
                                                                          userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return AgeCountryFormStepView(viewModel: ageCountryFormStepViewModel)
            //
            //
        case .address:
            return AddressFormStepView(viewModel: AddressFormStepViewModel(title: "Address",
                                                                           countryCodeForSuggestions: defaultCountryIso3Code,
                                                                           place: userRegisterEnvelop.placeAddress,
                                                                           street: userRegisterEnvelop.streetAddress,
                                                                           additionalStreet: userRegisterEnvelop.additionalStreetAddress,
                                                                           userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .contacts:
            return ContactsFormStepView(viewModel: ContactsFormStepViewModel(title: "Contacts",
                                                                             email: userRegisterEnvelop.email,
                                                                             phoneNumber: userRegisterEnvelop.phoneNumber,
                                                                             prefixCountry: userRegisterEnvelop.phonePrefixCountry,
                                                                             defaultCountryIso3Code: defaultCountryIso3Code,
                                                                             serviceProvider: serviceProvider,
                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .password:
            return PasswordFormStepView(viewModel: PasswordFormStepViewModel(title: "Security",
                                                                             password: userRegisterEnvelop.password,
                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .terms:
            return TermsCondFormStepView(viewModel: TermsCondFormStepViewModel(title: "Terms and Conditions",
                                                                               isMarketingOn: userRegisterEnvelop.acceptedMarketing,
                                                                               isTermsOn: userRegisterEnvelop.acceptedTerms,
                                                                               userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .promoCodes:
            return PromoCodeFormStepView(viewModel: PromoCodeFormStepViewModel.init(title: "Promo",
                                                                                    promoCode: userRegisterEnvelop.promoCode,
                                                                                    godfatherCode: userRegisterEnvelop.godfatherCode,
                                                                                    userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .phoneConfirmation:
            return ConfirmationCodeFormStepView(viewModel: ConfirmationCodeFormStepViewModel(title: "Code Verification",
                                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
        }
    }
}
