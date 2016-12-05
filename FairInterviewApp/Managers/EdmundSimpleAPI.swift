//
//  EdmundAPIManager.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import SwiftyJSON
import Moya
import RxSwift

enum EdmundSimpleAPI {
    case make
    case articleOfVehicle(make: String, model : String)
    case dealershipsForVehicle(zip: String, make : String)
}

private let EDMUND_APIKEY  : String =  "syny99wj6n5rpf8zy7deyjtv"
private let EDMUND_SECRET  : String =  "EZmhB2XHhsGNYd6ZNTSBVnB5"

private func EdmundifyString(_ string : String) -> String {
    return "\(string)&api_key=\(EDMUND_APIKEY)"
}

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

//let EdmundProvider = RxMoyaProvider<EdmundSimpleAPI>(plugins: [NetworkLoggerPlugin(verbose: true, responseDataFormatter: JSONResponseDataFormatter)])
private let EdmundProvider = RxMoyaProvider<EdmundSimpleAPI>(plugins: [])
private let StubEdmundProvider = RxMoyaProvider<EdmundSimpleAPI>(stubClosure: MoyaProvider.immediatelyStub)
private var _edmundTestMode : Bool = false

func isRunningUnitTests() -> Bool {
    let env = ProcessInfo.processInfo.environment
    if let injectBundle = env["XCInjectBundle"] {
        return NSString(string: injectBundle).pathExtension == "xctest"
    }
    return false
}

func setEdmundAPITestMode(_ t : Bool) {
    _edmundTestMode = t
}

func getEdmundProvider(isTestMode : Bool? = _edmundTestMode) -> RxMoyaProvider<EdmundSimpleAPI> {
    return (!isTestMode!) ? EdmundProvider : StubEdmundProvider
}

extension EdmundSimpleAPI : TargetType {
    public var task: Task {
        return .request
    }
    
    public var path: String {
        switch self {
            
        case .make:
            let str = "/api/vehicle/v2/makes"
            return str
        case .articleOfVehicle(_,_):
            return "v1/content/"
        case .dealershipsForVehicle(_,_):
            return "api/dealer/v2/dealers"
        }
    }
    
    var base: String { return "https://api.edmunds.com" }
    public var baseURL: URL { return URL(string: base)! }
    
    public var parameters: [String: Any]? {
        switch self {
            
        case .make:
            return ["fmt": "json" as AnyObject,
            "state": "new" as AnyObject,
            "year": "2015" as AnyObject,
            "api_key": EDMUND_APIKEY as AnyObject
            ]
        case .articleOfVehicle(let make, let model):
            return ["fmt": "json" as AnyObject,
            "make": make as AnyObject,
            "model": model as AnyObject,
            "api_key": EDMUND_APIKEY as AnyObject
            ]
        case .dealershipsForVehicle(let zip, let make):
            return ["fmt": "json" as AnyObject,
                    "zipcode": zip as AnyObject,
                    "make": make as AnyObject,
                    "radius": "10" as AnyObject,
                    "api_key": EDMUND_APIKEY as AnyObject
            ]
        }
    }
    
    public var method: Moya.Method {
        switch self {
        default:
            return .get
        }
    }
    
    public var sampleData: Data {
        switch self {
            
        case .make:
            return stubbedResponse("Make")
            
        case .articleOfVehicle(_,_):
            return stubbedResponse("ArticleOfVehicle")
            
        case .dealershipsForVehicle(_,_):
            return stubbedResponse("NearbyDealerships")
            
        }
    }
    
    func stubbedResponse(_ filename: String) -> Data! {
        @objc class TestClass: NSObject { }
        
        let bundle = Bundle(for: TestClass.self)
        let path = bundle.path(forResource: filename, ofType: "json")
        return (try? Data(contentsOf: URL(fileURLWithPath: path!)))
    }
}
