//
//  APIRequests.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation

class APIUrls {
    
    static func GETCARIMAGE(make: String, model: String,
                            year : Int, trim : String,
                            size : String? = "190x97") -> String {
        return "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/\(size!)/\(trim)"
    }
    
    static func GETCARIMAGE(car : Car, size : String? = "190x97") -> String {
        return GETCARIMAGE(make: car.make, model: car.model, year: car.year, trim: car.trim, size: size!)
    }
}
