//
//  UIViewControllerExtension.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/28/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import PureLayout

extension UIViewController {
    func createAndEmbedActivityIndicator(view : UIView,
                                         style : UIActivityIndicatorViewStyle? = .gray) -> UIActivityIndicatorView {
        let actIndicator = UIActivityIndicatorView(activityIndicatorStyle: style!)
        actIndicator.hidesWhenStopped = true
        view.addSubview(actIndicator)
        actIndicator.autoCenterInSuperview()
        return actIndicator;
    }
    
    /// Short hand syntax for loading the view controller
    
    func loadViewProgrammatically(){
        self.beginAppearanceTransition(true, animated: false)
        self.endAppearanceTransition()
    }
    
    /// Short hand syntax for performing a segue with a known hardcoded identity
    
    func performSegue(_ identifier:SegueIdentifier) {
        self.performSegue(withIdentifier: identifier.rawValue, sender: self)
    }
    
    func findChildViewControllerOfType(_ klass: AnyClass) -> UIViewController? {
        for child in childViewControllers {
            if child.isKind(of: klass) {
                return child
            }
        }
        return nil
    }
}
