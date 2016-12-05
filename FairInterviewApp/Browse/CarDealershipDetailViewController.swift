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
                //Empty View text prompt
                if let label = view.viewWithTag(1) as? UILabel {
                    label.text = String.NoDealerships
                }
                //Open locations button
                view.viewWithTag(3)?.isHidden = true
            }
            else {
                view.isHidden = false
                if let label = view.viewWithTag(1) as? UILabel {
                    label.text = String.YouDontHaveGeolocationPermissions
                }
                if let activityIndicator = view.viewWithTag(2) as? UIActivityIndicatorView {
                    activityIndicator.stopAnimating()
                }
            }
        }
    }
}

class CarDealershipDetailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emptyViewLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var openPermissionsButton: UIButton!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var zipcodeField: UITextField!
    
    var car : Car = Car()
    var dealershipViewModel : DealerViewModel?
    var disposeBag : DisposeBag?
    var activityIndicator : UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let geolocationService = GeolocationService.instance
        self.title = .Dealerships
        activityIndicator = createAndEmbedActivityIndicator(view: emptyView)
        activityIndicator?.startAnimating()
        activityIndicator?.tag = 2
        
        
        //DisposeBag for getting nearby zip code
        disposeBag = DisposeBag()
        openPermissionsButton.rx.tap
            .bindNext { [weak self] in
                self?.openAppPreferences()
            }
            .addDisposableTo(disposeBag!)
        
        geolocationService.authorized
            .drive(emptyView.rx.driveAuthorization)
            .addDisposableTo(disposeBag!)
        
        geolocationService.clocation
            .drive(onNext: {
            cloc in
            CLGeocoder().reverseGeocodeLocation(cloc, completionHandler:  {
                (array, error) in
                    if (error != nil) {
                    } else {
                        self.getDealershipsByGeolocation(array: array)
                    }
                })
            }, onCompleted: {
                
            }).addDisposableTo(disposeBag!)
        
        zipcodeField.delegate = self
    }
    
    func getDealershipsByGeolocation(array : [CLPlacemark]?) {
        guard let arr = array else {
            return
        }
        if (arr.isEmpty) {
            return
        }
        let zipcode = arr.last!.postalCode!
        zipcodeField.text = zipcode
        getDealerships(zipcode : zipcode)
    }
    
    func getDealerships(zipcode : String) {
        disposeBag = DisposeBag()
        getEdmundProvider().request(.dealershipsForVehicle(zip: zipcode, make: car.make))
            .retry(3)
            .subscribe { event in
                switch event {
                case let .next(response):
                    self.activityIndicator?.stopAnimating()
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
        emptyViewLabel.text = String.NoDealerships
        
        dealershipViewModel!.data
            .map { (deals : [Dealer]) in
                return self.filterAndDetermineEmpty(deals)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == zipcodeField && !textField.text!.isEmpty {
            getDealerships(zipcode: textField.text!)
        }
        return true
    }
    
    func filterAndDetermineEmpty(_ list : [Dealer]) -> [Dealer] {
        let filtered = list.filter { deal in
            deal.active == true
        }
        self.emptyView.isHidden = !list.isEmpty
        return filtered
    }
}
