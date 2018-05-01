//
//  ConversionModel.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

// Convert Saved Array Categories to Local Dictionary Categories





















// Category Conversions

func convertCategories(from usedCategories: [String: Category]) -> [String: [String: Double]] {

    var convertedCategories = [String: [String: Double]]()
    
    for (category, amount) in usedCategories {
        convertedCategories[category] = [String: Double]()
        convertedCategories[category] = [availableKey: amount.available, budgetedKey: amount.budgeted]
    }
    
    return convertedCategories
}

func convertCategories(from savedCategories: [String: [String: Double]]) -> [String: Category] {
    
    var convertedCategories = [String: Category]()
    
    for (category, amountType) in savedCategories {
        
        if let available = amountType[availableKey], let budgeted = amountType[budgetedKey] {
            
                convertedCategories[category] = Category(name: category, budgeted: budgeted)
            
            if let convertedCategory = convertedCategories[category] {
                
                convertedCategory.available = available
                
            }
            
        }
    }
    
    return convertedCategories
}





// Transaction Conversions

func convertTransactions(from usedTransactions: [Transaction]) -> [String: [String: String]] {
    
    var convertedTransactions = [String: [String: String]]()
    
    for transaction in usedTransactions {
        
        var typeOfTransaction = ""
        
        if transaction.type == depositKey {
            typeOfTransaction = depositKey
        } else {
            typeOfTransaction = withdrawalKey
        }
        
        convertedTransactions[String(transaction.transactionID)] = [
            typeKey: typeOfTransaction,
            yearKey: String(transaction.year),
            monthKey: String(transaction.month),
            dayKey: String(transaction.day),
            titleKey: transaction.title,
            amountKey: String(transaction.inTheAmountOf),
            categoryKey: transaction.forCategory
        ]
        
    }
    
    return convertedTransactions
}

func convertTransactions(from savedTransactions: [String: [String: String]]) -> [Transaction] {
    
    var convertedTransactions = [Transaction]()
    
    var transactionID = Int()
    var type = String()
    var year = Int()
    var month = Int()
    var day = Int()
    var title = String()
    var amount = Double()
    var category = String()
    
    for (id, details) in savedTransactions {
        
        if let convertedID = Int(id) {
            transactionID = convertedID
        }
        
        for (key, value) in details {
            
            if key == typeKey {
                if value == depositKey {
                    type = depositKey
                } else {
                    type = withdrawalKey
                }
                
            } else if key == yearKey {
                if let yearAsInt = Int(value) {
                    year = yearAsInt
                }
                
            } else if key == monthKey {
                if let monthAsInt = Int(value) {
                    month = monthAsInt
                }
                
            } else if key == dayKey {
                if let dayAsInt = Int(value) {
                    day = dayAsInt
                }
                
            } else if key == titleKey {
                title = value
                
            } else if key == amountKey {
                if let amountAsDouble = Double(value) {
                    amount = amountAsDouble
                }
                
            } else if key == categoryKey {
                category = value
            }
            
        }
        
        convertedTransactions.append(Transaction(transactionID: transactionID, type: type, title: title, forCategory: category, inTheAmountOf: amount, year: year, month: month, day: day))
        
    }
    
    return convertedTransactions
}













