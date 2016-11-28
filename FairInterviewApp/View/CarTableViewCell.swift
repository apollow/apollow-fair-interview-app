//
//  CarTableViewCell.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//


import Foundation
import PureLayout
import RxSwift
import RxCocoa

class CarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var carLabel: UILabel!
    @IBOutlet var imageOutlet: UIImageView!
    let imageService = DefaultImageService.sharedImageService
    var disposeBag: DisposeBag?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var dataModel : Car? = nil {
        didSet {
            guard let dataModel = dataModel else {
                return
            }
            carLabel.text = "\(dataModel.name) - \(dataModel.model)"
            let url = URL(string: dataModel.getImageUrlString())!
            self.downloadableImage = imageService.imageFromURL(url)
        }
    }
    
    var downloadableImage: Observable<DownloadableImage>?{
        didSet{
            let disposeBag = DisposeBag()
            
            self.downloadableImage?
                .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
                .drive(imageOutlet.rx.downloadableImageAnimated(kCATransitionFade))
                .addDisposableTo(disposeBag)
            
            self.disposeBag = disposeBag
        }
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        dataModel = nil
        downloadableImage = nil
        disposeBag = nil
    }
    
    deinit {
    }
    
}
