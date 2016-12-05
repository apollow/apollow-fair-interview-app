//
//  Car.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

struct Car {
    let id : String
    let make: String
    let model: String
    let year: Int
    let trim: String
    let name : String
    
    init(_ id : String, _ name: String, _ make: String, _ model: String, _ year : Int, _ trim : String) {
        self.id = id
        self.name = name
        self.make = make
        self.model = model
        self.year = year
        self.trim = trim
    }
    
    init() {
        self.id = ""
        self.make = ""
        self.name = ""
        self.model = ""
        self.year = 0
        self.trim = ""
    }
    
    func getImageUrlString(type : String? = "side") -> String {
        return APIUrls.GETCARIMAGE(make: make, model: model, year: year, type: type ?? "side")
    }
    
    public var getDetailedDescription: [String] {
        var list : [String] = []
        list.append("Name - \(self.name)")
        list.append("Model - \(self.model)")
        list.append("Year - \(self.year)")
        return list
    }
    
    static func fromJSON(_ json:JSON) -> [Car] {
        
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let make = json["niceName"].stringValue
        
        var carList = [Car]()
        guard let models = json["models"].array else {
            return []
        }
        for m in models {
            let model = m["niceName"].stringValue
            //Trivializing differences in years
            let year = m["years"][0]["year"].intValue
            carList.append(Car(id, name, make, model, year, ""))
        }
        
        return carList
    }
    
    static func fromJSONIntoList(_ data:Data) -> [Car] {
        let json = JSON(data: data)
        guard let makes = json["makes"].array else { return [] }
        
        var car = [Car]()
        for m in makes {
            car += fromJSON(m)
        }
        
        return car
    }
}

struct CarViewModel {
    var data : Observable<Array<Car>>
    init(list : [Car]) {
        data = Observable.just(list)
    }
    
    init(response : Data) {
        self.init(list : Car.fromJSONIntoList(response))
    }

    static let empty = CarViewModel(list: [])
}


