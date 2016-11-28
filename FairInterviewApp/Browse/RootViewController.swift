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
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var disposeBag : DisposeBag?
    var carViewModel : CarViewModel?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        makeModelsRequest()
    }
    
    func configureTableDataSource() {
        tableView.register(UINib(nibName: "CarTableViewCell", bundle: nil), forCellReuseIdentifier: "CarCell")
        tableView.rowHeight = 194
        
        let results = searchBar.rx.text.orEmpty
            .asDriver()
            .flatMapLatest { query in
                self.carViewModel!.data
                    .map {
                        return (query.isEmpty) ? $0 : $0.filter { car in
                            car.make.lowercased().contains(query.lowercased())
                        }
                    }
                    .asDriver(onErrorJustReturn: [])
            }
        
        results
            .drive(tableView.rx.items(cellIdentifier: "CarCell", cellType: CarTableViewCell.self)) { (_, viewModel, cell) in
                cell.dataModel = viewModel
            }
            .addDisposableTo(disposeBag!)
        
//        results
//            .map { self.carViewModel!.data.count != 0 }
//            .drive(self.emptyView.rx.isHidden)
//            .addDisposableTo(disposeBag)
    }
    
    
    func makeModelsRequest() {
        EdmundProvider.request(.make)
            .retry(3)
            .subscribe { event in
            switch event {
                case let .next(response):
                    self.carViewModel = CarViewModel(response: response.data)
                    self.configureTableDataSource()
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
//                self.showAlert(car.getImageUrlString())
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "CarDetailViewController") as! CarDetailViewController
                viewController.car = car
                self.navigationController?.pushViewController(viewController, animated: false)
            })
            .addDisposableTo(disposeBag!)
    }
    
    
    func showAlert(_ message: String) {
        #if os(iOS)
            UIAlertView(title: "RxExample", message: message, delegate: nil, cancelButtonTitle: "OK").show()
        #elseif os(macOS)
            let alert = NSAlert()
            alert.messageText = message
            alert.runModal()
        #endif
    }
}

