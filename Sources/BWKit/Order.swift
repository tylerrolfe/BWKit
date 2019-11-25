//
//  Order.swift
//  BW Console
//
//  Created by Tyler Rolfe on 10/16/19.
//  Copyright © 2019 BW Blacksmith. All rights reserved.
//

import Foundation
import CodableFirebase
import Firebase

public struct Order: Codable {
    public var name: String?
    public var reference: DocumentReference?
    public var user: String?
    public var items: [OrderItem]?
    public var pickUpStyle: PickUpOption?
    public var status: OrderStatus?
    public var vehicleType: VehicleType?
    public var vehicleColor: String?
    public var pickUpLocation: String?
    public var timestamp: Timestamp?
    public var chargeId: String?
    public var chargeReference: DocumentReference?
    public var total: Double?
    public var receipt: String?
    public var productionStart: Timestamp?
    public var productionComplete: Timestamp?
    public var notes: String?
    
    public func pickUpInfo() -> String {
        switch pickUpStyle {
        case .curbSide: return "Pickup: Curb Side- \(vehicleColor?.capitalized) \(vehicleType?.rawValue.capitalized)"
        case .driveThrough: return "Pickup: Drive Through"
        case .inStore: return "Pickup: In Store"
        case .table: return "Pickup: Table \(pickUpLocation ?? "")"
        case .none:
            return "Pickup: Contact Customer"
        }
    }
    
    public func isOnTime() -> Bool {
        let pickUpTime = timestamp?.dateValue() ?? Date()
        let currentTime = Date()
        
        return currentTime < pickUpTime
    }
    
    public func pickUpTime() -> String {
        let date = timestamp?.dateValue()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, h:mm a"
        return dateFormatter.string(from: date ?? Date())
    }
    
    public func drinkCategoryCount() -> (cold: Int, hot: Int, specialty: Int, icecream: Int, food: Int, fruit: Int) {
        var cold = 0
        var hot = 0
        var specialty = 0
        var icecream = 0
        var food = 0
        var fruit = 0
        for item in items ?? [] {
            for category in item.categories ?? [] {
                switch category {
                case .cold: cold += 1
                case .hot: hot += 1
                case .specialty: specialty += 1
                case .icecream: icecream += 1
                case .food: food += 1
                case .fruit: fruit += 1
                }
            }
        }
        return (cold, hot, specialty, icecream, food, fruit)
    }
}

public enum VehicleType: String, Codable {
    case van, car, truck, motorcycle, suv
}

public struct OrderItem: Codable {
    public var name: String
    public var bwplus: Bool
    public var addons: [Addon]?
    public var notes: String?
    public var productionTime: Int?
    public var categories: [ItemCategories]?
    public var complete: Bool? = false
    public var size: ItemSize?
    public var base: Base?
}

public enum PickUpOption: String, Codable {
    case driveThrough, inStore, curbSide, table
}

public enum OrderStatus: String, Codable {
    case new, processing, pickup, complete
}
