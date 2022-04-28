//
//  PreviewChatCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/04/2022.
//

import Foundation

class PreviewChatCellViewModel {
    var cellData: ConversationData

    init(cellData: ConversationData) {
        self.cellData = cellData
    }

    func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }
}
