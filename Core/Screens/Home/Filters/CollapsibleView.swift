//
//  CollapsibleView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/10/2021.
//

import SwiftUI

//
struct CollapsibleView<Content: View>: View {
    
    @State var label: () -> Text
    @State var content: () -> Content
    
    @State private var isOptional: Bool = true
    @State private var isEnabled: Bool = true
    @State private var isCollapsed: Bool = false
    
    init(isOptional: Bool = true, label: @escaping () -> Text, content: @escaping () -> Content) {
        self.isOptional = isOptional
        self.label = label
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                if isOptional {
                    Button(action: {
                        self.isEnabled.toggle()
                    }, label: {
                        VStack {
                            Image(systemName: self.isEnabled ? "checkmark.square.fill" : "square")
                                .foregroundColor(.blue)
                                .font(.system(size: 26, weight: .medium))
                        }
                        .frame(width: 32.0, height: 32.0)
                    })
                }

                Button(
                    action: {
                        self.isCollapsed.toggle()
                    },
                    label: {
                        HStack {
                            self.label().foregroundColor(.white)
                            Spacer()
                            VStack {
                                Image(systemName: self.isCollapsed ? "chevron.down" : "chevron.up")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 32.0, height: 32.0)
                        }
                    }
                )
            }
            VStack(spacing: 0) {
                self.content().opacity( isEnabled ? 1.0 : 0.3 )
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: isCollapsed ? 0 : .none)
            .clipped(antialiased: true)
        }
        .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
        .background(Color(hex: 0x313543))
        .cornerRadius(6)
        .animation(.easeOut)
        .transition(.slide)
    }
}

struct CollapsibleView_Previews: PreviewProvider {
    static var previews: some View {
        CollapsibleView(
            isOptional: true,
            label: {
                Text("Collapsible")
                    .font(.system(size: 18, weight: .bold))
            },
            content: {
                VStack(spacing: 5) {
                    FilterLineView(title: "Value 1 - Title",
                                   selected: false,
                                   multiSelection: true)
                    Rectangle().fill(Color(hex: 0x979797))
                        .frame(height: 1)
                        .opacity(0.3)
                    FilterLineView(title: "Value 2 - Title",
                                   selected: true,
                                   multiSelection: true)
                    Rectangle().fill(Color(hex: 0x979797))
                        .frame(height: 1)
                        .opacity(0.3)
                    FilterLineView(title: "Value 3dddwd da kfjn ej fje jsnd - Title",
                                   selected: false,
                                   multiSelection: false)
                    Rectangle().fill(Color(hex: 0x979797))
                        .frame(height: 1)
                        .opacity(0.3)
                    FilterLineView(title: "Value 1 - Title",
                                   selected: true,
                                   multiSelection: false)
                }
            }
        )
        .frame(maxWidth: 300)
    }
}
