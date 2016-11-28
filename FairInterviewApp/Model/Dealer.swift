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
    
    static func fromJSONIntoList(_ data:Data) throws -> [Dealer] {
        let json = JSON(data: data)
        
        guard let deals = json["dealers"].array else {
            throw BasicError.make("Dealers not in json for cars")
        }
        
        let dealer : [Dealer] = try deals.map { (m : JSON) in
            do {
                return try fromJSON(m)
            } catch {
                throw BasicError.make("Models not in json for cars")
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
        do {
            try self.init(list : Dealer.fromJSONIntoList(response))
        }
        catch {
            self.init(list: [])
        }
    }
    
    static let empty = CarViewModel(list: [])
}
