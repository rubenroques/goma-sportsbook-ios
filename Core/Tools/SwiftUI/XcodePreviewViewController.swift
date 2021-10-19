//
//  XcodePreviewViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 19/10/2021.
//

import UIKit
import SwiftUI

struct XcodePreviewViewController: UIViewControllerRepresentable {
    let viewControllerBuilder: () -> UIViewController

    init(_ viewControllerBuilder: @escaping () -> UIViewController) {
        self.viewControllerBuilder = viewControllerBuilder
    }

    func makeUIViewController(context: Context) -> some UIViewController {
        return viewControllerBuilder()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        // Not needed
    }
}

struct XcodePreviewView: UIViewRepresentable {
    let viewBuilder: () -> UIView

    init(_ viewBuilder: @escaping () -> UIView) {
        self.viewBuilder = viewBuilder
    }

    func makeUIView(context: Context) -> some UIView {
        viewBuilder()
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Not needed
    }
}

//
// USAGE:
//
// struct PreviewViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        ViewControllerPreview {
//            PreviewViewController()
//        }
//    }
// }
//

struct PreviewViewController_Previews: PreviewProvider {
    static var previews: some View {
        XcodePreviewView.init({
            let checkboxToggleView = CheckboxToggleView()
            checkboxToggleView.unselectedColor = UIColor.App.separatorLine
            checkboxToggleView.selectedColor = UIColor.App.mainBackground
            checkboxToggleView.isSelected = true
            return checkboxToggleView
        })
    }
}
