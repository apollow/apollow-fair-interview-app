//
//  Strings.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/28/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation

func NSLocalizedString(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

//MARK: Main Screens
extension String {
    static let Browse = NSLocalizedString("Browse")
    static let Car = NSLocalizedString("Car")
}

//MARK: Finding nearby dealerships Screen
extension String {
    static let NearbyDealerships = NSLocalizedString("Nearby Dealerships")
    static let Dealerships = NSLocalizedString("Dealerships")
    static let NoDealerships = NSLocalizedString("We couldn't find a dealership nearby with your car, you can set the zipcode above to hopefully find a dealership nearby")
    static let YouDontHaveGeolocationPermissions = NSLocalizedString("Sorry, this app does not have permissions for accessing the location, you can set the zipcode in the textfield above.")
    static let FindDealerships = NSLocalizedString("Find Dealerships with Zipcode")
    static let EnterZipCode = NSLocalizedString("Enter Zipcode")
}
