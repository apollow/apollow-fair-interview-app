//
//  CarDealershipDetailViewController.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/27/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

private extension Reactive where Base: UIView {
    var driveAuthorization: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: base) { view, authorized in
            if authorized {
                view.isHidden = true
                view.superview?.sendSubview(toBack:view)
            }
            else {
                view.isHidden = false
                view.superview?.bringSubview(toFront:view)
            }
        }
    }
}

class CarDealershipDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var openPermissionsButton: UIButton!
    @IBOutlet weak var noGeolocation: UIView!
    
    var car : Car = Car()
    var dealershipViewModel : DealerViewModel?
    var disposeBag : DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disposeBag = DisposeBag()
        let geolocationService = GeolocationService.instance
        
        openPermissionsButton.rx.tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .addDisposableTo(disposeBag!)
        
        geolocationService.authorized
            .drive(noGeolocation.rx.driveAuthorization)
            .addDisposableTo(disposeBag!)
        
        geolocationService.clocation
            .drive(onNext: {
            cloc in
            CLGeocoder().reverseGeocodeLocation(cloc, completionHandler:  {
                (array, error) in
                    if (error != nil) {
                    } else {
                        self.getDealerships(array)
                    }
                })
            }, onCompleted: {
                
            }).addDisposableTo(disposeBag!)
        
    }
    
    func getDealerships(_ array : [CLPlacemark]?) {
        guard let arr = array else {
            return
        }
        if (arr.isEmpty) {
            return
        }
        disposeBag = DisposeBag()
        let zipcode = arr.last!.postalCode
        
        EdmundProvider.request(.dealershipsForVehicle(zip: zipcode!, make: car.make))
            .retry(3)
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.dealershipViewModel = DealerViewModel.init(response: response.data)
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
        
        dealershipViewModel!.data
            .map { (deals : [Dealer]) in
                return deals.filter { deal in
                    deal.active == true
                }
            }
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) {
                (_, viewModel, cell) in
                cell.textLabel?.text = viewModel.name
        }.addDisposableTo(disposeBag!)
    }
    
    
    func configureNavigateOnRowClick() {
        tableView.rx.modelSelected(Dealer.self)
            .asDriver()
            .drive(onNext: { deal in
                let str = "http://maps.apple.com/?daddr=\(deal.latLongRepr)"
                guard let url = URL(string: str) else {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            .addDisposableTo(disposeBag!)

    }
    
    private func openAppPreferences() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
    }
}
