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
                            year : Int, type : String,
                            size : String? = "190x97") -> String {
        return "https://a.tcimg.net/v/model_images/v1/\(year)/\(make)/\(model)/all/\(size!)/\(type)"
    }
}
