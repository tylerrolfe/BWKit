//
//  POSOrder.swift
//  BW Console
//
//  Created by Tyler Rolfe on 11/6/19.
//  Copyright © 2019 BW Blacksmith. All rights reserved.
//

import Foundation
import Firebase

public struct POSOrder: Codable {
    public var reference: DocumentReference?
    public var status: POSStatus?
    public var items: [POSItem]?
    public var total: Double?
    public var tip: Double?
    public var ponyup: Bool?
    public var confirmed: Bool?
    public var name: String?
    public var notes: String?
    
    public func getPriceWithTax() -> Double {
        var total: Double = 0
        
        for item in items ?? [] {
            total += item.calculatePrice() * 1.07
        }
        
        return total
    }
    
    public func printReceipt() {
        let bw = generateQRCode(from: "https://www.bwblacksmith.com/about-us/")
        let barcode = generateBarcode(from: self.reference?.documentID ?? "")

        let thankYou = "Thank you for for choosing BW Blacksmith Coffee Company!".toData()
        let address = "419 FL-247, Lake City, FL 32025 ".toData()
        let info = "386.755.4075  | info@bwblacksmith.com".toData()
        
        var taxString = ""
        var totalString = ""
        var subtotalString = ""
        
        var tax: Double = 0
        var total: Double = 0
        var tipAmount: Double = 0
        var ponyAmount: Double = 0
        var subtotal: Double = 0 {
            didSet {
                total = 0
                tax = 0
                tax = subtotal * 0.07
                total = subtotal * 1.07
                tipAmount = (subtotal * (tip ?? 1.0))-subtotal
                if tip ?? 1.0 > 1.0 {
                    total += tipAmount
                }
                if ponyup ?? false == true {
                    let upper = ceil(total)
                    ponyAmount = upper - total
                    total += ponyAmount
                }
                
                taxString = "  Tax: \(convertDoubleToCurrency(amount: tax))"
                subtotalString = "Subtotal: \(convertDoubleToCurrency(amount: subtotal))"
                totalString = "Total: \(convertDoubleToCurrency(amount: total))"
            }
        }
       
        

        let builder = StarIoExt.createCommandBuilder(.none)
        builder?.beginDocument()
        builder?.appendBitmap(withAlignment: UIImage(named:
            "rec-logo"), diffusion: true, position: .center)
        builder?.appendLineFeed()
        builder?.appendAlignment(.center)
        builder?.appendData(withEmphasis: thankYou)
        builder?.appendLineFeed()
        builder?.appendData(withLineFeed: address)
        builder?.appendLineFeed()
        builder?.appendData(withLineFeed: info)
        builder?.appendAlignment(.left)
        builder?.appendLineFeed(1)
        for item in items ?? [] {
            subtotal += item.calculatePrice()
            let priceOfItem = convertDoubleToCurrency(amount: item.calculatePrice())
            let itemName = "\(item.name ?? ""): \(priceOfItem)"
            builder?.appendData(withEmphasis: itemName.toData())
            builder?.appendLineFeed()
            for addon in item.size?.addons ?? [] {
                if addon.count ?? 0 > 0 {
                    let name = addon.reference?.documentID.capitalized ?? ""
                    let count = String(Int(addon.count ?? 0))
                    let addonText = "  - \(name): \(count)"
                    builder?.append(addonText.toData())
                    builder?.appendLineFeed()
                }
            }
            builder?.appendLineFeed()
        }
        builder?.appendLineFeed()
        builder?.appendLineFeed()
        builder?.append(subtotalString.toData())
        builder?.appendLineFeed()
        builder?.append(taxString.toData())
        builder?.appendLineFeed()
        if tip ?? 1.0 > 1.0 {
            let tipString = convertDoubleToCurrency(amount: tipAmount)
            builder?.append("  Tip: \(tipString)".toData())
            builder?.appendLineFeed()
        }
        if ponyup ?? false == true {
            let diffString = convertDoubleToCurrency(amount: ponyAmount)
            builder?.append("  Pony Up: \(diffString)".toData())
            builder?.appendLineFeed()
        }
        builder?.appendData(withEmphasis: totalString.toData())
        builder?.appendLineFeed()
        builder?.appendBitmap(withAlignment: barcode!, diffusion: true, position: .center)
        builder?.appendAlignment(.center)
        builder?.appendLineFeed(2)
        builder?.append("BW Blacksmith helps families fighting cancer learn more:".toData())
        builder?.appendBitmap(withAlignment: bw!, diffusion: true, position: .center)
        builder?.appendLineFeed()
        builder?.append("Visit our website at www.bwblacksmith.com".toData())
        builder?.appendLineFeed()
        builder?.appendCutPaper(.fullCutWithFeed)
        for item in items ?? [] {
            let priceOfItem = convertDoubleToCurrency(amount: item.calculatePrice())
            let itemName = "\(item.name ?? ""): \(priceOfItem)"
            builder?.appendData(withEmphasis: itemName.toData())
            builder?.appendLineFeed()
            for addon in item.size?.addons ?? [] {
                if addon.count ?? 0 > 0 {
                    let name = addon.reference?.documentID.capitalized ?? ""
                    let count = String(Int(addon.count ?? 0))
                    let addonText = "  - \(name): \(count)"
                    builder?.append(addonText.toData())
                    builder?.appendLineFeed()
                }
            }
            builder?.appendCutPaper(.partialCutWithFeed)
        }
        builder?.endDocument()
        let commands = builder!.commands


        var someText = "Hello, world! \n I am here to let there be print!"
        var command: [UInt8] = Array(commands!)

        while true {
            var port : SMPort
            do {
                // Open port
                port = try SMPort.getPort(portName: "BT:BW1", portSettings: "", ioTimeoutMillis: 10000)
                defer {
                    // Close port
                }
                SMPort.release(port)
                var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()
                // Start to check the completion of printing
                try port.beginCheckedBlock(starPrinterStatus: &printerStatus, level: 2)
                if printerStatus.offline == SM_TRUESHARED {
                    break // The printer is offline.
                }
                var total: UInt32 = 0
                while total < UInt32(command.count) {
                    var written: UInt32 = 0
                    // Send print data
                    try port.write(writeBuffer: command, offset: total, size: UInt32(command.count) - total, numberOfBytesWritten: &written)
                    total += written
                }
                // Stop to check the completion of printing
                try port.endCheckedBlock(starPrinterStatus: &printerStatus, level: 2)
                if printerStatus.offline == SM_TRUESHARED {
                    break // The printer is offline.
                }
                // Success
                break
            }

            catch let error as NSError {
                print(error)
                break // Some error occurred.
            }
        }
    }
}
    
public struct POSItem: Codable {
    public var name: String?
    public var size: ItemSize?
    public var item: MenuItem?
    public var base: Base?
    public var categories: [ItemCategories]?
    
    public func calculatePrice() -> Double {
        if let size = self.size {
            var price = size.price ?? 0
            for liqbase in ProductDetails.shared.bases ?? [] {
                if liqbase.reference == base?.reference {
                    price += liqbase.price ?? 0
                }
            }
            for addon in size.addons ?? [] {    
                for sharedAddon in ProductDetails.shared.addons ?? [] {
                    if addon.reference == sharedAddon.reference {
                        price += (addon.count ?? 0) * (sharedAddon.cost ?? 0)
                        break
                    }
                }
            }
            if let minPrice = size.min {
                if price > minPrice {
                    return price
                } else {
                    return minPrice
                }
            } else {
                if price > 2.5 {
                    return price
                } else {
                    return 2.5
                }
            }
        } else {
            return 2.5
        }
    }
}

public enum POSStatus: String, Codable {
    case pending
    case processing
    case failed
    case success
    case complete
    case new
}
