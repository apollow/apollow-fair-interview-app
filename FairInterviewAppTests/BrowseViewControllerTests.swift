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

class BrowseViewControllerSpec: QuickSpec {
    override func spec() {
        beforeSuite {
        }
        
        describe("provider") {
            var response: Response?
            
            beforeEach {
                let target: EdmundSimpleAPI = .make
                getEdmundProvider(isTestMode: true).request(target) { result in
                    if case let .success(resp) = result {
                        response = resp
                    }
                }
            }
            
            it("gets the list of car apis") {
                expect(response).toNot(beNil())
                expect(response!.request).toNot(beNil())
            }
            
            it("is properly parsed") {
                expect(response).toNot(beNil())
                let data = response!.data
                expect(data).toNot(beNil())
                expect{
                    let list = try Car.fromJSONIntoList(data)
                    return expect(list.count).to(beGreaterThan(0))
                }.toNot(throwError())
            }
        }
        
        describe("view") {
            var subject: RootViewController!
            var searchBar : UISearchBar!
            
            beforeEach {
                subject = UIStoryboard.main().viewController(withID: .Browse) as! RootViewController
                subject.loadViewProgrammatically()
                searchBar = subject.searchBar
//                
//                subject.reachability = fakeReachability.asObservable()
//                subject.apiPinger = Observable.just(true).take(1)
            }
            
            it("contains the search bar necessary for searching"){
                expect(searchBar.isHidden) == false
            }
            
            describe("loading") {
                it ("shows emptyview when loading") {
                    expect(subject.emptyView.isHidden) == false
                }
            }
            
            describe("browse and search") {
//                beforeEach {
//                    let target: EdmundSimpleAPI = .make
//                    getEdmundProvider().request(target) { result in
//                        if case let .success(response) = result {
//                            subject.carViewModel = CarViewModel(response : response.data)
//                            subject.configureTableDataSource()
//                        }
//                    }
//                }
                
                it ("searches for cars") {
                    let disposeBag = DisposeBag()
                    let str = Observable.just("GMC")
                    str.bindTo(searchBar.rx.text).addDisposableTo(disposeBag)
                    expect(searchBar.text) == "GMC"
                    expect(subject.emptyView.isHidden).toEventually(beTrue())
                }
                
                it ("shows emptyview if no cars are found in query") {
                    let disposeBag = DisposeBag()
                    let dne = Observable.just("_____ThisCarProductDoesNotExist😑")
                    
                    dne.bindTo(searchBar.rx.text).addDisposableTo(disposeBag)
                    expect(searchBar.text) == "_____ThisCarProductDoesNotExist😑"
                    expect(subject.emptyView.isHidden).toEventually(beFalse())
                }
            }
        }
    }
}
