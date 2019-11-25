//
//  Item.swift
//  BW Console
//
//  Created by Tyler Rolfe on 10/16/19.
//  Copyright © 2019 BW Blacksmith. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

public struct MenuItem: Codable {
    public var reference: DocumentReference?
    public var available: Bool? = false
    public var base: Base?
    public var bwplus: Bool?
    public var categories: [ItemCategories]?
    public var productionTime: Int?
    public var addons: [Addon]?
    public var description: String?
    public var featured: String?
    public var meta: String?
    public var name: String?
    public var new: Bool?
    public var nutrition: [Nutrition]?
    public var price: Double?
    public var sizes: [ItemSize]?
    public var thumbnail: String?
    public var selectedSize: [String: Double]?
    public var productionStatus: String? = "new"
    
    public func featuredUrl() -> URL? {
        return URL(string: featured ?? "")
    }
    
    public func thumbnailUrl() -> URL? {
        return URL(string: thumbnail ?? "")
    }
    
    public func calculateBasePrice(size: ItemSize) -> Double {
        var price = 0.0
        for defaultAddon in size.addons ?? [] {
            for addon in ProductDetails.shared.addons ?? [] {
                if defaultAddon.reference == addon.reference {
                    price += addon.cost ?? 0.0
                }
            }
        }
        if price > 2.5 {
            return price
        } else {
            return 2.5
        }
    }
}

public struct Base: Codable, Hashable {
    public var name: String?
    public var count: Double?
    public var reference: DocumentReference?
    public var price: Double?
    public var categories: [ItemCategories]?
}
    
public struct ItemSize: Codable, Equatable {
    static func == (lhs: ItemSize, rhs: ItemSize) -> Bool {
        return lhs.name == rhs.name
    }
    
    public var name: String?
    public var size: Double?
    public var addons: [ItemAddon]?
    public var price: Double?
    public var min: Double?
    public var unit: String?
}

public struct Addon: Codable, Hashable {
    public var reference: DocumentReference?
    public var categories: [ItemCategories]?
    public var category: AddonCategory?
    public var cost: Double?
    public var name: String?
    public var type: AddonType?
    public var count: Double?
    public var max: Double?
    public var unit: String?
}

public struct ItemAddon: Codable {
    public var reference: DocumentReference?
    public var count: Double?
    public var cost: Double?
    public var name: String?
}

public enum ItemCategories: String, Codable {
    case cold, hot, specialty, icecream, food, fruit
}

public enum AddonType: String, Codable {
    case flavor, topping, liquid
}

public enum AddonCategory: String, Codable {
    case sweetener
    case flavor
    case espresso
    case creamer
    case base
    case topping
    case mixin
    case condiments
    case fruits
    case toppings
    case addons
    case flavors
}

public struct Nutrition: Codable {
    public var label: String?
    public var value: Double?
}

