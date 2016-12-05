//
//  Dealer.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/27/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

class Dealer {
    let name : String
    let latLongRepr : String
    let active : Bool
    
    init(_ name : String, _ active: Bool, _ latLongRepr: String) {
        self.name = name
        self.active = active
        self.latLongRepr = latLongRepr
    }
    
    static func fromJSON(_ json:JSON) throws -> Dealer {
        print(json)
        let name = json["name"].stringValue
        let active = json["active"].boolValue
        let address = json["address"]
        let latLongRepr = "\(address["latitude"].floatValue),\(address["longitude"].floatValue)"
        
        return Dealer(name, active, latLongRepr)
    }
    
    static func fromJSONIntoList(_ data:Data) -> [Dealer] {
        let json = JSON(data: data)
        
        guard let deals = json["dealers"].array else {
            return []
        }
        
        var dealer : [Dealer] = []
        for d in deals {
            do {
                dealer.append(try fromJSON(d))
            } catch {
                return []
            }
        }
        
        return dealer
    }
}

struct DealerViewModel {
    var data : Observable<Array<Dealer>>
    init(list : [Dealer]) {
        data = Observable.just(list)
    }
    
    init(response : Data) {
        self.init(list : Dealer.fromJSONIntoList(response))
    }
    
    static let empty = CarViewModel(list: [])
}
