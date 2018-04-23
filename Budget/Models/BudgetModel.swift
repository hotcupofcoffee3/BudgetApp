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
    var title: String
    var year: Int
    var month: Int
    var day: Int
    var inTheAmountOf: Double
    var forCategory: String
    
    init (transactionID: Int, type: TransactionType, title: String, forCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
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

// ************************************************
// MARK: - Budget Class
// ************************************************

class Budget {

    var categories = [String: Category]()
    var transactions = [Transaction]()
    var sortedCategoryKeys = [String]()
    
    init() {
        self.categories[uncategorizedKey] = Category(name: uncategorizedKey, budgeted: 0.0)
    }
    
    
    
    // ************************************************
    // MARK: - Category functions
    // ************************************************
    
    
    
    // MARK: Allocate Funds
    

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
    
    
    
    // MARK: Remove Funds
    
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
    
    
    
    // MARK: Add Category
    
    func addCategory (named: String, withThisAmount: Double) {
        if categories[named] == nil {
            categories[named] = Category(name: named, budgeted: withThisAmount)
            
        }
        sortCategoriesByKey(withUncategorized: false)
        saveEverything()
    }
    
    
    
    // MARK: Delete Category
    
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
    
    
    
    // MARK: Sort Categories
    
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
    
    // MARK: Update Category
    
    func updateCategory(named oldCategoryName: String, updatedNewName newCategoryName: String, andNewBudgetedAmount newCategoryBudgeted: Double) {
        
        if newCategoryName == oldCategoryName {
                        
            guard let oldCategory = categories[oldCategoryName] else { return }
            
            oldCategory.budgeted = newCategoryBudgeted
            
        } else {
                    
            // New category created with new category name and budgeted
            categories[newCategoryName] = Category(name: newCategoryName, budgeted: newCategoryBudgeted)
            
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
        
        saveEverything()
        
    }
    
    
    
    
    
    // ************************************************
    //MARK: - Transaction functions
    // ************************************************
    
    
    
    // MARK: Convert Date into YYYYMMDD
    
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
    
    
    
    // MARK: Convert Date into ID
    
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
    
    
    
    // MARK: Add Transaction
    
    func addTransaction (type: TransactionType, title: String, forCategory thisCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
        
        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
        
        if type == .deposit {
            
            guard let uncategorized = categories[uncategorizedKey] else { return }
            uncategorized.available += inTheAmountOf
            
            let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
            
            transactions.append(Transaction(transactionID: formattedTransactionID, type: .deposit, title: title, forCategory: uncategorizedKey, inTheAmountOf: inTheAmountOf, year: year, month: month, day: day))
            
            sortTransactionsDescending()
            
            saveEverything()
            
        } else if type == .withdrawal {
            
            transactions.append(Transaction(transactionID: formattedTransactionID, type: .withdrawal, title: title, forCategory: thisCategory, inTheAmountOf: inTheAmountOf, year: year, month: month, day: day))
            
            guard let category = categories[thisCategory]  else { return }
            category.available -= inTheAmountOf
            
            sortTransactionsDescending()
            
            saveEverything()
            
        }
        
    }
    
    
    
    // MARK: Sort Transactions
    
    func sortTransactionsDescending() {
        
        transactions.sort(by: {$0.transactionID > $1.transactionID})
        
    }
    
    func sortTransactionsAscending() {
        
        transactions.sort(by: {$0.transactionID < $1.transactionID})

    }
    
    
    
    // MARK: Delete transaction
    
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
    
    
    
    // MARK: Update Transaction
    
    func updateTransaction(named updatedTransaction: Transaction, atIndex index: Int) {
        if transactions[index].type == .deposit {
            
            deleteTransaction(at: index)

            addTransaction(type: .deposit, title: updatedTransaction.title, forCategory: uncategorizedKey, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
        } else {
            
            deleteTransaction(at: index)

            addTransaction(type: .withdrawal, title: updatedTransaction.title, forCategory: updatedTransaction.forCategory, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
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






