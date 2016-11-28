//
//  UIImageView+DownloadableImage.swift
//  RxExample
//
//  Created by Vodovozov Gleb on 11/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import UIKit

extension Reactive where Base: UIImageView {
    
    var downloadableImage: UIBindingObserver<Base, DownloadableImage>{
        return downloadableImageAnimated(nil)
    }
    
    func downloadableImageAnimated(_ transitionType:String?) -> UIBindingObserver<Base, DownloadableImage> {
        return UIBindingObserver(UIElement: base) { imageView, image in
            for subview in imageView.subviews {
                subview.removeFromSuperview()
            }
            switch image {
            case .content(let image):
                (imageView as UIImageView).rx.image.on(.next(image))
            case .offlinePlaceholder:
                let image = UIImage(named: "CarPlaceHolder")
                (imageView as UIImageView).rx.image.on(.next(image))
            }
        }
    }
}
#endif
