//
//  Loadable.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/11/2022.
//

import Foundation
import UIKit

protocol Loadable {
    func showLoadingView()
    func hideLoadingView()
}

fileprivate struct Constants {
    // an arbitrary tag id for the loading view, so it can be retrieved later without keeping a reference to it
    fileprivate static let loadingViewTag = 742
}

// implementation for UIViewController
extension UIViewController: Loadable {
    
    func showLoadingView() {
        DispatchQueue.main.async {
            let loadingView = LoadingView()
            self.view.addSubview(loadingView)
            
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            loadingView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            loadingView.heightAnchor.constraint(equalToConstant: 100).isActive = true
            loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            loadingView.animate()
            
            loadingView.tag = Constants.loadingViewTag
        }
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            self.view.subviews.forEach { subview in
                if subview.tag == Constants.loadingViewTag {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}

final class LoadingView: UIView {
    private let activityIndicatorView = UIActivityIndicatorView(style: .large)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        layer.cornerRadius = 5
        
        if activityIndicatorView.superview == nil {
            addSubview(activityIndicatorView)
            
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            activityIndicatorView.startAnimating()
        }
    }
    
    public func animate() {
        activityIndicatorView.startAnimating()
    }
}
