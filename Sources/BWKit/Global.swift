//
//  Global.swift
//  BW Console
//
//  Created by Tyler Rolfe on 10/16/19.
//  Copyright © 2019 BW Blacksmith. All rights reserved.
//

import Foundation
import Firebase

public struct Global: Codable {
    public var featuredItem: DocumentReference?
    public var bwPlusSales: String?
    public var bwPlusPrice: Double?
    public var bwPlusPriceLabel: String?
    public var addons: [Addon]?
}

public class ProductDetails {
    public static var shared = ProductDetails()
    
    public var addons: [Addon]? = []
    public var bases: [Base]? = []
}
