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
    @IBOutlet weak var nearbyDealershipsButton: UIBarButtonItem!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var containerView: UIView!
    weak var pageController : ImagePageViewController?
    var imageTypes : [String] = ["side", "f3q"]
    
    var car : Car = Car()
    var currPageNdx : Int = 0
    var articleList : [String]?
    
    var disposeBag : DisposeBag?
    override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        getArticleLinks()
        createAndEmbedActivityIndicator(view: emptyView).startAnimating()
        self.title = .Car
        nearbyDealershipsButton.title = .NearbyDealerships
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let segueName = segue.identifier
        if segueName == "imagePageSegue" {
            pageController = segue.destination as? ImagePageViewController
            pageController?.orderedViewControllers = createImagePageViewControllers()
        }
    }
    
    
    func getArticleLinks() {
        getEdmundProvider().request(.articleOfVehicle(make: car.make, model: car.model))
            .retry(3)
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.articleList = Article.fromJSON(response.data)
                    self.emptyView?.isHidden = true
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
        let deselectIndexPath = IndexPath(row: 0, section: 1)
        tableView.delegate?.tableView!(tableView, didSelectRowAt: deselectIndexPath)
//        self.tableView.selectRow(at: IndexPath(row: 0, section: 1), animated: false, scrollPosition: UITableViewScrollPosition.none)
//        let viewController = UIStoryboard.main().viewController(withID: .CarDealership) as! CarDealershipDetailViewController
//        viewController.car = car
//        self.navigationController?.pushViewController(viewController, animated: false)
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
    
    func createImagePageViewControllers() -> [UIViewController] {
        var list : [UIViewController] = []
        
        for i in 0..<imageTypes.count {
            let viewController = UIStoryboard.main().viewController(withID: .ImageContentViewController) as! ImageContentPageViewController
            viewController.urlString = (car.getImageUrlString(type: imageTypes[i]))
            list.append(viewController)
        }
        
        return list
    }
    
}
