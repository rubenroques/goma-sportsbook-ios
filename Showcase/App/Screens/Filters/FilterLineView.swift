//
//  FilterLineView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 06/10/2021.
//

import SwiftUI

struct FilterLineView: View {

    var allowMultiSelection: Bool = false
    var title: String
    @State var selected: Bool

    init(title: String, selected: Bool, multiSelection: Bool) {
        self.title = title
        self.selected = selected
        self.allowMultiSelection = multiSelection
    }

    var body: some View {

        Button(
            action: {
                self.selected.toggle()
            },
            label: {
                HStack {
                    Text(self.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if allowMultiSelection {
                        Image(systemName: self.selected ?
                                        "record.circle" : "circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 26, weight: .medium))
                    }
                    else {
                        Image(systemName: self.selected ?
                                "checkmark.square.fill" : "square")
                            .foregroundColor(.blue)
                            .font(.system(size: 26, weight: .medium))
                    }
                }
            }
        )
        .frame(minHeight: 50)
    }
}

struct FilterLineView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Color(.black).edgesIgnoringSafeArea(.all)
                FilterLineView(title: "Option 1", selected: true, multiSelection: true)
            }
        }
    }
}
