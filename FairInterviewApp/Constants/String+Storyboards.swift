//
//  String+Storyboards.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/29/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation

enum SegueIdentifier : String {
    case ImagePageSegue = "imagePageSegue"
}

enum StoryboardNames : String {
    case Main = "Main"
}

enum ViewControllerStoryboardIdentifier : String {
    case Browse = "RootViewController"
    case CarDetail = "CarDetailViewController"
    case CarDealership = "CarDealershipDetailViewController"
    case ImagePageViewController = "ImagePageViewController"
    case ImageContentViewController = "ImageContentPageViewController"
}
