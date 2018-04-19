//
//  BudgetModel.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//


import Foundation

enum TransactionType {
    case withdrawal
    case deposit
}

class Category {
    var name: String
    var available = 0.00
    var budgeted: Double
    init(name: String, budgeted: Double) {
        self.name = name
        self.budgeted = budgeted
    }
}

class Transaction {
    var transactionID: Int
    var type: TransactionType
    var year: Int
    var month: Int
    var day: Int
    var title: String
    var inTheAmountOf: Double
    var forCategory: String
    
    init (transactionID: Int, type: TransactionType, title: String, forCategory: String = uncategorizedKey, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
        self.type = type
        self.title = title
        self.forCategory = forCategory
        self.inTheAmountOf = inTheAmountOf
        
        self.year = year
        self.month = month
        self.day = day
        
        // Placeholder until functions get written
        self.transactionID = transactionID
    }

}

class Budget {

    var categories = [String: Category]()
    var transactions = [Transaction]()
    var sortedCategoryKeys = [String]()
    
    init() {
        self.categories[uncategorizedKey] = Category(name: uncategorizedKey, budgeted: 0.0)
    }
    
    
    
    
    // Category functions

    func allocateFundsToCategory (withThisAmount: Double, to thisCategory: String) {
        
        // It can't be, but this just makes it clearer
        if thisCategory != uncategorizedKey {
            
            guard let currentCategory = categories[thisCategory] else { return }
                
            let amount = withThisAmount
                    
            // Adds funds to specified category
            currentCategory.available += amount
            
            // Takes funds from Uncategorized category
            guard let uncategorized = categories[uncategorizedKey] else { return }
            uncategorized.available -= amount
            
        }
        
        saveEverything()
        
    }
    
    func removeFundsFromCategory (withThisAmount: Double?, from thisCategory: String) {
        
        if thisCategory != uncategorizedKey {
            
            guard let currentCategory = categories[thisCategory] else { return }
                
            if withThisAmount == nil {
                
                // Adds funds to specified category
                currentCategory.available -= currentCategory.budgeted
                
                // Takes funds from general Uncategorized category
                guard let uncategorized = categories[uncategorizedKey] else { return }
                uncategorized.available += currentCategory.budgeted
                
            } else {
                guard let amount = withThisAmount else { return }
                    
                // Adds funds to specified category
                currentCategory.available -= amount
                
                // Takes funds from Uncategorized category
                guard let uncategorized = categories[uncategorizedKey] else { return }
                uncategorized.available += amount
                
            }
            
        }
        
        saveEverything()
        
    }
    
    func addCategory (named: String, withThisAmount: Double) {
        if categories[named] == nil {
            categories[named] = Category(name: named, budgeted: withThisAmount)
            
        }
        sortCategoriesByKey(withUncategorized: false)
        saveEverything()
    }
    
    func deleteCategory (named: String) {
        
        // Cannot delete "Uncategorized" because it doesn't show up in any place, so it will always be the default in the background.
        
        if transactions.count > 0 {
            
            for transaction in transactions {
                
                if transaction.forCategory == named {
                    
                    transaction.forCategory = uncategorizedKey
                    
                }
                
            }
            
        }
        
        if let uncategorized = categories[uncategorizedKey], let deletedCategory = categories[named] {
            uncategorized.available += deletedCategory.available
        }
        
        if named != uncategorizedKey {
            categories[named] = nil
        }
        sortCategoriesByKey(withUncategorized: false)
        saveEverything()
    }
    
    func sortCategoriesByKey (withUncategorized: Bool) {
        
        // Empties sorted Category Key array
        sortedCategoryKeys = []
        
        if withUncategorized == true {
            
            for key in categories.keys {
                if key == uncategorizedKey {
                    continue
                }
                sortedCategoryKeys.append(key)
            }
            sortedCategoryKeys.sort()
            sortedCategoryKeys = [uncategorizedKey] + sortedCategoryKeys
            
        } else {
            
            for key in categories.keys {
                if key == uncategorizedKey {
                    continue
                }
                sortedCategoryKeys.append(key)
            }
            sortedCategoryKeys.sort()
            
        }
        
    }
    
    func updateCategory(named oldCategoryName: String, updatedWith newCategory: Category) {
        
        if categories[oldCategoryName] != nil {
            
            let newCategoryName = newCategory.name
            
            // If same category name, then only the budgeted amount gets changed
            if newCategoryName == oldCategoryName {
                
                guard let oldCategory = categories[oldCategoryName] else { return }
                
                oldCategory.budgeted = newCategory.budgeted
                
            // If name changed, everything gets changed
            } else {
                
                // New category created with new category name and budgeted
                categories[newCategoryName] = newCategory
                
                // New category gets old category's available amount
                if let nuevoCategory = categories[newCategoryName], let viejoCategory = categories[oldCategoryName] {
                    
                    nuevoCategory.available = viejoCategory.available
                    
                }
                
                // Old category removed
                categories[oldCategoryName] = nil
                
                // Transactions with old category name get set to new category's name
                for transaction in transactions {
                    
                    if transaction.forCategory == oldCategoryName {
                        
                        transaction.forCategory = newCategoryName
                        
                    }
                    
                }
                
            }
            
        }
        
        saveEverything()
        
    }
    
    
    //MARK: Transaction functions
    
    func convertDateInfoToYYYYMMDD(year: Int, month: Int, day: Int) -> Int {
        
        var convertedDateString = String()
        var convertedDateInt = Int()
        
        let yearAsString = "\(year)"
        var monthAsString = ""
        var dayAsString = ""
        
        if month < 10 {
            monthAsString = "0\(month)"
        } else {
            monthAsString = "\(month)"
        }
        
        if day < 10 {
            dayAsString = "0\(day)"
        } else {
            dayAsString = "\(day)"
        }
        
        convertedDateString = yearAsString + monthAsString + dayAsString
        
        if let convertedDate = Int(convertedDateString) {
            
            convertedDateInt = convertedDate
            
        }
        
        return convertedDateInt
        
    }
    
    func convertedDateComponentsToTransactionID(year: Int, month: Int, day: Int) -> Int {
        
        var formattedID = Int()
        
        var convertedID = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
        
        // Multiplied by 100000, then 1 added, to make it have the same format as the other IDs
        convertedID *= 100000
        convertedID += 1
        
        // Sorts them in ascending order to run through correctly.
        sortTransactionsAscending()
       
        for transaction in transactions {
            if convertedID == transaction.transactionID {
                convertedID += 1
            }
        }
        
        formattedID = convertedID

        // Sorts them with most recent first.
        sortTransactionsDescending()
        
        return formattedID
        
    }
    
    func depositTransaction (title: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
        
        guard let uncategorized = categories[uncategorizedKey] else { return }
        uncategorized.available += inTheAmountOf
        
        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
        
        transactions.append(Transaction(transactionID: formattedTransactionID, type: .deposit, title: title, inTheAmountOf: inTheAmountOf, year: year, month: month, day: day))
        
        sortTransactionsDescending()
        
        saveEverything()
    }
    
    func withdrawalTransaction (title: String, from thisCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
        
        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
        
        transactions.append(Transaction(transactionID: formattedTransactionID, type: .withdrawal, title: title, forCategory: thisCategory, inTheAmountOf: inTheAmountOf, year: year, month: month, day: day))
        
        guard let category = categories[thisCategory]  else { return }
        category.available -= inTheAmountOf
        
        sortTransactionsDescending()
        
        saveEverything()
    }
    
    func sortTransactionsDescending() {
        
        transactions.sort(by: {$0.transactionID > $1.transactionID})
        
        for transaction in transactions {
            print(transaction.transactionID)
        }
        
    }
    
    func sortTransactionsAscending() {
        
        transactions.sort(by: {$0.transactionID < $1.transactionID})
        
        for transaction in transactions {
            print(transaction.transactionID)
        }
        
    }
    
    func deleteTransaction (at index: Int) {
        let category = transactions[index].forCategory
        let amount = transactions[index].inTheAmountOf
        
        if transactions[index].type == .deposit {
            
            guard let uncategorized = categories[uncategorizedKey] else { return }
            uncategorized.available -= transactions[index].inTheAmountOf
            
        } else if transactions[index].type == .withdrawal {
            
            // Add amount back to category
            guard let categoryToPutBackTo = categories[category] else { return }
            categoryToPutBackTo.available += amount
            
        }
        
        // Delete transaction from the index in transaction array
        transactions.remove(at: index)
        
        saveEverything()
    }
    
    func updateTransaction(named updatedTransaction: Transaction, atIndex index: Int) {
        if transactions[index].type == .deposit {
            
            deleteTransaction(at: index)
            depositTransaction(title: updatedTransaction.title, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
        } else {
            
            deleteTransaction(at: index)
            withdrawalTransaction(title: updatedTransaction.title, from: updatedTransaction.forCategory, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
        }
        
    }
    
    //////////////////////////////
    //////////////////////////////
    //                          //
    // DELETE EVERYTHING SO FAR //
    //                          //
    //////////////////////////////
    //////////////////////////////
    
    
    func deleteEVERYTHING(){
        
        categories = [:]
        transactions = []
        categories[uncategorizedKey] = Category(name: uncategorizedKey, budgeted: 0.0)
        
        UserDefaults.standard.set(nil, forKey: transactionKey)
        UserDefaults.standard.set(nil, forKey: categoryKey)
        
        loadCategories()
        loadTransactions()
        
    }
    
    
    
    
    
}

// Main Budget Model Declared
let budget = Budget()






