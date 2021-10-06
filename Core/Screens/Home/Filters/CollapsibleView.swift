//
//  CollapsibleView.swift
//  Sportsbook
//
//  Created by Ruben Roques on 05/10/2021.
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
        HStack {
            Text(self.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            
            if allowMultiSelection {
                Button(
                    action: {
                        self.selected.toggle()
                    },
                    label: { Image(systemName: self.selected ?
                                    "record.circle" : "circle")
                        .foregroundColor(.blue)
                        .font(.system(size: 26, weight: .medium))
                    }
                )
            }
            else {
                Button(
                    action: {
                        self.selected.toggle()
                    },
                    label: {
                        Image(systemName: self.selected ?
                                "checkmark.square.fill" : "square")
                            .foregroundColor(.blue)
                            .font(.system(size: 26, weight: .medium))
                    })
            }
        }.frame(minHeight: 60)
    }
}
//
//
//
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
        VStack {
            HStack {
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
            //Rectangle().fill(Color(hex: 0x979797)).frame(height: isCollapsed ? 0 : 1).opacity(0.3)
            VStack {
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

//
//
//
struct CollapsibleView_Previews: PreviewProvider {
    static var previews: some View {
        CollapsibleView(
            isOptional: false,
            label: {
                Text("Collapsible")
                    .font(.system(size: 18, weight: .bold))
            },
            content: {
                VStack {
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

extension EdgeInsets {
    static var zero: EdgeInsets {
        EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    }
}
