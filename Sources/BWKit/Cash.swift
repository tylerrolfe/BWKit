//
//  Cash.swift
//  BW Console
//
//  Created by Tyler Rolfe on 11/16/19.
//  Copyright © 2019 BW Blacksmith. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

public struct Cash: Codable {
    public var date: Timestamp?
    public var active: Bool?
    public var cashCountedTotal: Double?
    public var cashRemoved: Double?
    public var cashLeftInDrawer: Double?
    public var user: String?
}

public struct Transaction: Codable {
    public var cashTendered: Double?
    public var cashReturned: Double?
    public var totalForOrder: Double?
    public var posOrderRef: DocumentReference?
}

extension DocumentReference: DocumentReferenceType {}
extension GeoPoint: GeoPointType {}
extension FieldValue: FieldValueType {}
extension Timestamp: TimestampType {}
