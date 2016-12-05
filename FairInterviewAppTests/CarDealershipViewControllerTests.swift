//
//  CarDealershipViewControllerTests.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 12/4/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import Nimble
import Nimble_Snapshots
import Moya
import Quick
import RxSwift
@testable
import FairInterviewApp

//Barebones test coverage!
class CarDealershipViewControllerTests: QuickSpec {
    override func spec() {
        var subject: CarDealershipDetailViewController!
        let car = Car("Acura_ILX", "Acura", "acura", "ilx", 2017, "")
        let zipcode = "94103"
        
        beforeSuite {
            setEdmundAPITestMode(true)
            subject = UIStoryboard.main().viewController(withID: .CarDealership) as! CarDealershipDetailViewController
            subject.car = car
            subject.loadViewProgrammatically()
        }
        
        describe("provider") {
            it("gets the list of dealerships nearby and is parsed properly") {
                var response: Response?
                let target: EdmundSimpleAPI = .dealershipsForVehicle(zip: zipcode, make: car.make)
                waitUntil { done in
                    getEdmundProvider().request(target) { result in
                        if case let .success(resp) = result {
                            response = resp
                            done()
                        }
                    }
                }
                expect(response).toNot(beNil())
                expect(response!.request).toNot(beNil())
                
                let data = response!.data
                expect(data).toNot(beNil())
                
                let list = Dealer.fromJSONIntoList(data)
                expect(list).toNot(beEmpty())
                
                let errorList = Dealer.fromJSONIntoList("Mrglglglggll!".data(using: String.Encoding.utf8)!)
                expect(errorList).to(beEmpty())
            }
        }
        
        describe("view") {
            
            it("geolocates to a nearbylocation"){
                //TODO
            }
            
            describe("dealerships") {
                it ("has dealerships available for browsing") {
                    subject.loadViewProgrammatically()
                    waitUntil { done in
                        subject.getDealerships(zipcode: zipcode)
                        done()
                    }
                    expect(subject.dealershipViewModel).toEventuallyNot(beNil())
                }
                
                it ("shows emptyview if no dealerships found") {
                    //TODO
                }
                
                it ("responds to tap controls that navigate to directions for that dealership") {
                    subject.loadViewProgrammatically()
                    waitUntil { done in
                        subject.getDealerships(zipcode: zipcode)
                        done()
                    }
                    expect(subject.dealershipViewModel).toEventuallyNot(beNil())
                    
                    let ndxPath = IndexPath(row: 0, section: 0)
                    subject.tableView.delegate?.tableView!(subject.tableView, didSelectRowAt: ndxPath)
                    
                    let state = UIApplication.shared.applicationState
                    expect(state).toNotEventually(be(UIApplicationState.active))
                }
            }
        }
    }
}
