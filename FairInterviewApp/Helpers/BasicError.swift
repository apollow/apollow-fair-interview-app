//
//  BasicError.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/26/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation

class BasicError {
    public static func make(_ str : String)-> NSError {
        return NSError(domain: "BasicError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(str)"])
    }
}
