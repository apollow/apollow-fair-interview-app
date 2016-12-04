//
//  RootViewController.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class RootViewController: UIViewController {
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var queryEmptyLabel: UILabel!
    
    var activityIndicator : UIActivityIndicatorView?
    var disposeBag : DisposeBag?
    var carViewModel : CarViewModel?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        activityIndicator = createAndEmbedActivityIndicator(view: emptyView)
        activityIndicator?.startAnimating()
        makeModelsRequest()
        self.title = .Browse
    }
    
    func configureTableDataSource() {
        tableView.register(UINib(nibName: "CarTableViewCell", bundle: nil), forCellReuseIdentifier: "CarCell")
        tableView.rowHeight = 194
        
        let results = searchBar.rx.text.orEmpty
            .asDriver()
            .flatMapLatest { query in
                self.carViewModel!.data
                    .map {
                        self.filterAndDetermineEmpty(query, $0)
                    }
                    .asDriver(onErrorJustReturn: [])
            }
        
        results
            .drive(tableView.rx.items(cellIdentifier: "CarCell", cellType: CarTableViewCell.self)) { (_, viewModel, cell) in
                cell.dataModel = viewModel
            }
            .addDisposableTo(disposeBag!)
    }
    
    
    func makeModelsRequest() {
        getEdmundProvider().request(.make)
            .retry(3)
            .subscribe { event in
            switch event {
                case let .next(response):
                    self.carViewModel = CarViewModel(response: response.data)
                    self.activityIndicator?.stopAnimating()
                    self.queryEmptyLabel?.isHidden = false
//                    self.configureTableDataSource()
                    self.configureNavigateOnRowClick()
            case let .error(error):
                print(error)
            default:
                break
            }
        }.addDisposableTo(disposeBag!)
    }
    
    
    func configureNavigateOnRowClick() {
        tableView.rx.modelSelected(Car.self)
            .asDriver()
            .drive(onNext: { car in
                let viewController = UIStoryboard.main().viewController(withID: .CarDetail) as! CarDetailViewController
                viewController.car = car
                self.navigationController?.pushViewController(viewController, animated: false)
            })
            .addDisposableTo(disposeBag!)
    }
    
    func filterAndDetermineEmpty(_ query : String, _ list : [Car]) -> [Car] {
        print(query)
        let filtered = list.filter { car in
            car.make.lowercased().contains(query.lowercased())
        }
        self.emptyView.isHidden = (!filtered.isEmpty || query.isEmpty)
        return (query.isEmpty) ? list : filtered
    }
}

