//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Pedro Ruíz on 5/14/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import UIKit

protocol VendingMachineType {
	var selection: [VendingSelection] { get }
	var inventory: [VendingSelection: ItemType] { get set }
	var amountDeposited: Double { get set }
	
	init(inventory: [VendingSelection: ItemType])
	
	func vend(selection: VendingSelection, quantity: Double) throws
	func deposit(amount: Double)
	func itemForCurrentSelection(selection: VendingSelection) -> ItemType?
}

protocol ItemType {
	var price: Double { get }
	var quantity: Double { get set }
}

// ErrorTypes

enum InventoryError: ErrorType {
	case InvalidResource
	case ConversionError
	case InvalidKey
}

enum VendingMachineError: ErrorType {
	case InvalidSelection
	case OutOfStock
	case InsufficientFunds(required: Double)
}

// Helper Classes

class PlistConverter {
	class func dictionaryFromFile(resource: String, ofType type: String) throws -> [String : AnyObject] {
		
		// Get a path to the resource
		guard let path = NSBundle.mainBundle().pathForResource(resource, ofType: type) else {
			throw InventoryError.InvalidResource
		}
		
		// Extract dictionary and TypeCast it to the expected format
		guard let dictionary = NSDictionary(contentsOfFile: path), let castDictionary = dictionary as? [String : AnyObject] else {
		  throw InventoryError.ConversionError
		}
		
		return castDictionary
	}
}

class InventoryUnarchiver {
	class func vendingInventoryFromDictionary(dictionary: [String: AnyObject]) throws -> [VendingSelection : ItemType] {
		var inventory: [VendingSelection: ItemType] = [:]
		
		for (key, value) in dictionary {
			if let itemDict = value as? [String : Double], let price = itemDict["price"], let quantity = itemDict["quantity"] {
				let item = VendingItem(price: price, quantity: quantity)
				guard let key = VendingSelection(rawValue: key) else {
					throw InventoryError.InvalidKey
				}
				inventory.updateValue(item, forKey: key)
			}
		}
		return inventory
	}
}

// Concrete Type

enum VendingSelection: String {
	case Chips, Cookie, Sandwich
	case Wrap, CandyBar, PopTart, Gum
	case Water, FruitJuice, SportsDrink, Soda, DietSoda
	
	func icon() -> UIImage {
		if let image = UIImage(named: self.rawValue) {
			return image
		} else {
			return UIImage(named: "Default")!
		}
	}
}

struct VendingItem: ItemType {
	let price: Double
	var quantity: Double
}


// Reference Type
class VendingMachine: VendingMachineType {
	
	let selection: [VendingSelection] = [.Soda, .DietSoda, .Chips, .Cookie, .Sandwich, .Wrap, .CandyBar, .PopTart, .Water, .FruitJuice, .SportsDrink, .Gum]
	
	var inventory: [VendingSelection : ItemType]
	var amountDeposited: Double = 10.0
	
	required init(inventory: [VendingSelection : ItemType]) {
		self.inventory = inventory
	}
	
	func vend(selection: VendingSelection, quantity: Double) throws {
		guard var item = inventory[selection] else {
			throw VendingMachineError.InvalidSelection
		}
		
		guard item.quantity > 0 else {
			throw VendingMachineError.OutOfStock
		}
		
		// user can cancel the transaction if they want
		
		item.quantity -= quantity
		inventory.updateValue(item, forKey: selection)
		
		let totalPrice = item.price * quantity
		
		if amountDeposited >= totalPrice {
			amountDeposited -= totalPrice
		} else {
			let amountRequired = totalPrice - amountDeposited
			
			throw VendingMachineError.InsufficientFunds(required: amountRequired)
		}
		
	}
	
	func itemForCurrentSelection(selection: VendingSelection) -> ItemType? {
		return inventory[selection]
	}
	
	func deposit(amount: Double) {
		amountDeposited += amount
	}
	
}