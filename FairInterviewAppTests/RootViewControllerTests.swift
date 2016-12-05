//
//  BrowseViewControllerTests.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/29/16.
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

class RootViewControllerSpec: QuickSpec {
    override func spec() {
        var subject: RootViewController!
        beforeSuite {
            setEdmundAPITestMode(true)
            subject = UIStoryboard.main().viewController(withID: .Browse) as! RootViewController
            subject.loadViewProgrammatically()
        }
        
        describe("provider") {
            it("gets the list of car apis and is parsed properly") {
                var response: Response?
                let target: EdmundSimpleAPI = .make
                
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
                
                let list = Car.fromJSONIntoList(data)
                expect(list).toNot(beEmpty())
                
                let errorList = Car.fromJSONIntoList("Mrglglglggll!".data(using: String.Encoding.utf8)!)
                expect(errorList).to(beEmpty())
            }
        }
        
        describe("view") {
            
            it("contains the search bar necessary for searching"){
                expect(subject.searchBar.isHidden) == false
            }
            
            describe("browse and search") {
                it ("has cars available for browsing") {
                    subject.searchBar.text = ""
                    subject.configureTable()
                    expect(subject.searchBar.text) == ""
                    expect(subject.emptyView.isHidden).toEventually(beTrue())
                }
                
                it ("searches for cars") {
                    subject.searchBar.text = "Audi"
                    subject.configureTable()
                    expect(subject.searchBar.text) == "Audi"
                    expect(subject.emptyView.isHidden).toEventually(beTrue())
                }
                
                it ("shows emptyview if no cars are found in query") {
                    subject.searchBar.text = "UnicornuriaCar"
                    subject.configureTable()
                    expect(subject.searchBar.text) == "UnicornuriaCar"
                    expect(subject.emptyView.isHidden).toEventually(beFalse())
                }
                
                it ("responds to tap controls that navigate to car detail") {
                    let navsubject = UINavigationController(rootViewController: subject)
                    
                    expect(navsubject.topViewController).toEventually(beAnInstanceOf(RootViewController.self))
                    expect(subject.navigationController).to(be(navsubject))
                    
                    waitUntil { done in
                        subject.configureTable()
                        done()
                    }
                    expect(subject.tableView.delegate).toNotEventually(beNil())
                    
                    let ndxPath = IndexPath(item: 0, section: 0)
                    subject.tableView.delegate?.tableView!(subject.tableView, didSelectRowAt: ndxPath)
                    
                    expect(navsubject.visibleViewController).toEventually(beAnInstanceOf(CarDetailViewController.self))
                }
            }
        }
    }
}
