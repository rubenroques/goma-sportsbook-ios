//
//  File.swift
//  
//
//  Created by Ruben Roques on 28/01/2023.
//

import Foundation
import UIKit
import ServicesProvider
import Extensions

struct FormStepViewFactory {

    static func formStepView(forFormStep formStep: FormStep,
                             serviceProvider: ServicesProviderClient,
                             userRegisterEnvelop: UserRegisterEnvelop,
                             userRegisterEnvelopUpdater: UserRegisterEnvelopUpdater,
                             hasReferralCode: Bool? = nil) -> FormStepView {

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
            let genderFormStepViewModel = GenderFormStepViewModel(title: Localization.localized("gender"),
                                                                  selectedGender: gender,
                                                                  userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return GenderFormStepView(viewModel: genderFormStepViewModel)
            //
            //
        case .names:
            return NamesFormStepView(viewModel: NamesFormStepViewModel(title: Localization.localized("names"),
                                                                       firstName: userRegisterEnvelop.name,
                                                                       middleName: userRegisterEnvelop.middleName,
                                                                       lastName: userRegisterEnvelop.surname,
                                                                       userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .avatar:
            let avatarFormStepViewModel = AvatarFormStepViewModel(title: Localization.localized("avatar"),
                                                                  subtitle: Localization.localized("choose_avatar"),
                                                                  avatarIconNames: ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6",],
                                                                  selectedAvatarName: userRegisterEnvelop.avatarName,
                                                                  userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return AvatarFormStepView(viewModel: avatarFormStepViewModel)
            //
            //
        case .nickname:
            let nicknameFormStepViewModel = NicknameFormStepViewModel(title: Localization.localized("nickname"),
                                                                      nickname: userRegisterEnvelop.nickname,
                                                                      serviceProvider: serviceProvider,
                                                                      userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return NicknameFormStepView(viewModel: nicknameFormStepViewModel)
            //
            //
        case .ageCountry:
            let ageCountryFormStepViewModel = AgeCountryFormStepViewModel(title: Localization.localized("age_and_birthplace"),
                                                                          defaultCountryIso3Code: defaultCountryIso3Code,
                                                                          birthDate: userRegisterEnvelop.dateOfBirth,
                                                                          selectedCountry: userRegisterEnvelop.countryBirth,
                                                                          departmentOfBirth: userRegisterEnvelop.deparmentOfBirth,
                                                                          placeBirth: userRegisterEnvelop.placeBirth,
                                                                          serviceProvider: serviceProvider,
                                                                          userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)
            return AgeCountryFormStepView(viewModel: ageCountryFormStepViewModel)
            //
            //
        case .address:
            return AddressFormStepView(viewModel: AddressFormStepViewModel(title: Localization.localized("address"),
                                                                           countryCodeForSuggestions: defaultCountryIso3Code,
                                                                           place: userRegisterEnvelop.placeAddress,
                                                                           street: userRegisterEnvelop.streetAddress,
                                                                           postcode: userRegisterEnvelop.postcode,
                                                                           streetNumber: userRegisterEnvelop.streetNumber,
                                                                           userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .contacts:
            return ContactsFormStepView(viewModel: ContactsFormStepViewModel(title: Localization.localized("contacts"),
                                                                             email: userRegisterEnvelop.email,
                                                                             phoneNumber: userRegisterEnvelop.phoneNumber,
                                                                             prefixCountry: userRegisterEnvelop.phonePrefixCountry,
                                                                             defaultCountryIso3Code: defaultCountryIso3Code,
                                                                             serviceProvider: serviceProvider,
                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .password:
            return PasswordFormStepView(viewModel: PasswordFormStepViewModel(title: Localization.localized("security"),
                                                                             password: nil,
                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .terms:
            return TermsCondFormStepView(viewModel: TermsCondFormStepViewModel(title: Localization.localized("terms_and_conditions"),
                                                                               isMarketingOn: userRegisterEnvelop.acceptedMarketing,
                                                                               isTermsOn: userRegisterEnvelop.acceptedTerms,
                                                                               userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
            //
            //
        case .promoCodes:
            return PromoCodeFormStepView(viewModel: PromoCodeFormStepViewModel.init(title: Localization.localized("promo_code"),
                                                                                    promoCode: userRegisterEnvelop.promoCode,
                                                                                    godfatherCode: userRegisterEnvelop.godfatherCode,
                                                                                    userRegisterEnvelopUpdater: userRegisterEnvelopUpdater, hasReferralCode: hasReferralCode))
            //
            //
        case .phoneConfirmation:
            return ConfirmationCodeFormStepView(viewModel: ConfirmationCodeFormStepViewModel(title: Localization.localized("verification_code"),
                                                                                             serviceProvider: serviceProvider,
                                                                                             userRegisterEnvelopUpdater: userRegisterEnvelopUpdater))
        }
    }
}
