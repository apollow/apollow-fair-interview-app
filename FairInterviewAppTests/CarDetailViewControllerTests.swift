//
//  FairInterviewAppTests.swift
//  FairInterviewAppTests
//
//  Created by Mike Wang on 11/26/16.
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

class CarDetailViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: CarDetailViewController!
        let car = Car("Acura_ILX", "Acura", "acura", "ilx", 2017, "")
        
        beforeSuite {
            setEdmundAPITestMode(true)
            subject = UIStoryboard.main().viewController(withID: .CarDetail) as! CarDetailViewController
            subject.car = car
        }
        
        describe("provider") {
            it("gets the list of article apis and is parsed properly") {
                var response: Response?
                let target: EdmundSimpleAPI = .articleOfVehicle(make: car.make, model: car.model)
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
                
                let list = Article.fromJSON(data)
                expect(list).toNot(beEmpty())
                
                let errorList = Article.fromJSON("Mrglglglggll!".data(using: String.Encoding.utf8)!)
                expect(errorList).to(beEmpty())
            }
        }
        
        describe("view") {
            describe("contains details of the car") {
                it ("has vehicle information") {
                    subject.loadViewProgrammatically()
                    expect(self.verifyTextInTableViewCellAtIndex(0, 0, tableView: subject.tableView, string: "Acura")).to(beTrue())
                    expect(self.verifyTextInTableViewCellAtIndex(1, 0, tableView: subject.tableView, string: "ilx")).to(beTrue())
                }
                
                it ("contains article information") {
                    subject.loadViewProgrammatically()
                    
                    expect(self.verifyTextInTableViewCellAtIndex(0, 1, tableView: subject.tableView, string: "lexus")).to(beTrue())
                }
                
                it ("opens articles") {
                    subject.loadViewProgrammatically()
                    
                    let ndxPath = IndexPath(row: 0, section: 1)
                    subject.tableView.delegate?.tableView!(subject.tableView, didSelectRowAt: ndxPath)
                    
                    let state = UIApplication.shared.applicationState
                    expect(state).toNotEventually(be(UIApplicationState.active))
                }
                
                it ("contains images") {
                    subject.loadViewProgrammatically()
                    let pageVCs = subject.pageController?.orderedViewControllers
                    expect(pageVCs).toEventuallyNot(beEmpty())
                    let imagecontentvc = pageVCs![0] as! ImageContentPageViewController
                    expect(imagecontentvc.imageView).toEventuallyNot(beNil())
                    print(imagecontentvc.urlString)
                    expect(imagecontentvc.urlString.range(of: "https://a.tcimg.net/v/")).toNot(beNil())
                    expect(imagecontentvc.imageView?.image).toEventuallyNot(beNil())
                }
            }
        }
    }
    
    func verifyTextInTableViewCellAtIndex(_ ndx : Int, _ section : Int, tableView : UITableView, string : String) -> Bool {
        guard let cell = tableView.cellForRow(at: IndexPath(item: ndx, section: section)) else {
            return false
        }
        return ((cell.textLabel?.text?.range(of: string)) != nil)
    }
}
