//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by Pedro Ruíz on 5/14/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation

protocol VendingMachineType {
	var selection: [VendingSelection] { get }
	var inventory: [VendingSelection: ItemType] { get set }
	
	init(inventory: [VendingSelection: ItemType])
	
	func vend(selection: VendingSelection, quantity: Double) throws
	func deposit(amount: Double)
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
		
	}
	
	func deposit(amount: Double) {
		
	}
	
}