//
//  Article.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/27/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import SwiftyJSON

class Article {
    static func fromJSON(_ data:Data) -> [String] {
        let json = JSON(data: data)
        var list = [String]()
        
        guard let articles = json.array else {
            return []
        }
        
        for a in articles {
            list.append(a["link"].stringValue)
        }
        
        return list
    }
}
