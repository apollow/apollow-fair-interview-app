//
//  BrowseViewControllerTests.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/29/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import Nimble
import Nimble_Snapshots
import Quick
import RxSwift
@testable
import FairInterviewApp

class BrowseViewControllerSpec: QuickSpec {
    override func spec() {
        describe("view") {
            var subject: RootViewController!
            var fakeReachability: Variable<Bool>!
            
            beforeEach {
                subject = RootViewController.instantiate(from: auctionStoryboard)
                subject.provider = Networking.newStubbingNetworking()
                fakeReachability = Variable(true)
                
                subject.reachability = fakeReachability.asObservable()
                subject.apiPinger = Observable.just(true).take(1)
            }
            
            it("shows the offlineBlockingView when offline  is true"){
                subject.loadViewProgrammatically()
                
                subject.offlineBlockingView.isHidden = false
                
                fakeReachability.value = true
                expect(subject.offlineBlockingView.isHidden) == true
            }
            
            it("hides the offlineBlockingView when offline  is false"){
                subject.loadViewProgrammatically()
                
                fakeReachability.value = true
                expect(subject.offlineBlockingView.isHidden) == true
                
                
                fakeReachability.value = false
                expect(subject.offlineBlockingView.isHidden) == false
                
            }
        }
    }
}
