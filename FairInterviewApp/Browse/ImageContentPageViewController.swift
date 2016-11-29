//
//  CarContentPageViewController.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/28/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import PureLayout

class ImageContentPageViewController: UIViewController {
    var imageView : UIImageView?
    
    var disposeBag : DisposeBag?
    var urlString : String = ""
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageView!.rx.downloadableImageAnimated(kCATransitionFade))
                .addDisposableTo(disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageService = DefaultImageService.sharedImageService
        let url = URL(string: urlString)!
        imageView = UIImageView()
        view.addSubview(imageView!)
        downloadableImage = imageService.imageFromURL(url)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        imageView?.autoPinEdgesToSuperviewEdges()
    }
}
