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
}
