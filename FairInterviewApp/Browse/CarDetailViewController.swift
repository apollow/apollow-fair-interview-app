//
//  CarDetailViewController.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/27/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxDataSources

class CarDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var carImageView: UIImageView!
    
    var car : Car = Car()
    var articleList : [String]?
    
    var disposeBag : DisposeBag?
    override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        getArticleLinks()
        
        
        let url = URL(string: car.getImageUrlString())!
        let imageService = DefaultImageService.sharedImageService
        imageService.imageFromURL(url)
            .asDriver(onErrorJustReturn: DownloadableImage.offlinePlaceholder)
            .drive(carImageView.rx.downloadableImageAnimated(kCATransitionFade))
            .addDisposableTo(disposeBag!)
    }
    
    
    func getArticleLinks() {
        EdmundProvider.request(.articleOfVehicle(make: car.make, model: car.model))
            .retry(3)
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.articleList = Article.fromJSON(response.data)
                    self.configureTableDataSource()
                    self.configureNavigateOnRowClick()
                case let .error(error):
                    print(error)
                default:
                    break
                }
            }.addDisposableTo(disposeBag!)
    }
    
    func configureTableDataSource() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, String>>()
        
        dataSource.configureCell = { (_, tv, ip, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
            cell.textLabel?.text = element
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            return cell
        }
        
        let items = Observable.just([
            SectionModel(model: "Details", items: car.getDetailedDescription),
            SectionModel(model: "Articles", items: articleList!)])
        
        items
            .bindTo(tableView.rx.items(dataSource: dataSource))
            .addDisposableTo(disposeBag!)
        
    }
    
    @IBAction func onDealershipTap(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "CarDealershipDetailViewController") as! CarDealershipDetailViewController
        viewController.car = car
        self.navigationController?.pushViewController(viewController, animated: false)
    }
    
    func configureNavigateOnRowClick() {
        tableView.rx.modelSelected(String.self)
            .asDriver()
            .drive(onNext: { str in
                guard let url = URL(string: str) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            .addDisposableTo(disposeBag!)
    }
}
