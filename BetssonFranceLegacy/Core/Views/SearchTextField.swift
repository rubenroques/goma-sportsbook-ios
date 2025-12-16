//
//  SearchTextField.swift
//  Sportsbook
//
//  Created by Ruben Roques on 07/10/2021.
//

/*
import SwiftUI
import Combine

class SearchTextFieldOutput: ObservableObject {
    @Published var searchText: String

    init(searchText: String) {
        self.searchText = searchText
    }
}

struct SearchTextField: View {

    @State private var isEditing = false
    @State var searchText: String = ""

    @ObservedObject var output: SearchTextFieldOutput

    var body: some View {
        ZStack {
            TextField("Search", text: self.$output.searchText, onCommit: {
                self.isEditing = false
            })
            .padding(8)
            .padding(.horizontal, 26)
            .background(Color.init(hex: 0xe4e4e6))
            .cornerRadius(8)
            .padding(.horizontal, 8)
            .onTapGesture {
                self.isEditing = true
            }

            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 16)

                if self.searchText.isNotEmpty || isEditing {
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 16)
                    }
                }
            }
        }
    }
}

struct SearchTextField_Previews: PreviewProvider {
    static var previews: some View {
        SearchTextField(output: SearchTextFieldOutput(searchText: "AAA"))
    }
}
*/
