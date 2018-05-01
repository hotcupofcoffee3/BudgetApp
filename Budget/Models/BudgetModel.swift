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
    var budgeted: Double
    var available = 0.00
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
    var balance = Double()
    
    init() {
        self.categories[unallocatedKey] = Category(name: unallocatedKey, budgeted: 0.0)
        guard let unallocated = self.categories[unallocatedKey] else { return }
        self.balance = unallocated.available
    }
    
    
    
    // MARK: - Update Balance
    
    func updateBalance() {
        
        var newBalance = 0.0
        
        for (_, detail) in categories {
            
            newBalance += detail.available
            
        }
        
        balance = newBalance
        
    }
    
    
    // ************************************************
    // MARK: - Category functions
    // ************************************************
    
    
    
    // MARK: Allocate Funds
    

    func allocateFundsToCategory (withThisAmount: Double, to thisCategory: String) {
        
        // It can't be, but this just makes it clearer
        if thisCategory != unallocatedKey {
            
            guard let currentCategory = categories[thisCategory] else { return }
                
            let amount = withThisAmount
                    
            // Adds funds to specified category
            currentCategory.available += amount
            
            // Takes funds from Uncategorized category
            guard let unallocated = categories[unallocatedKey] else { return }
            unallocated.available -= amount
            
        }
        
        saveEverything()
        
    }
    
    
    
    // MARK: Remove Funds
    
    func removeFundsFromCategory (withThisAmount: Double, from thisCategory: String) {
        
        if thisCategory != unallocatedKey {
            
            guard let currentCategory = categories[thisCategory] else { return }
                    
            // Adds funds to specified category
            currentCategory.available -= withThisAmount
            
            // Takes funds from Uncategorized category
            guard let unallocated = categories[unallocatedKey] else { return }
            unallocated.available += withThisAmount
            
        }
        
        saveEverything()
        
    }
    
    
    
    // MARK: Add Category
    
    func addCategory (named: String, withThisAmount amount: Double?) {
        
        if named != unallocatedKey {
            
            if categories[named] == nil {
                
                categories[named] = Category(name: named, budgeted: 0.0)
                
                if let amount = amount {
                    
                    guard let newCategory = categories[named] else { return }
                    guard let unallocated = categories[unallocatedKey] else { return }
                    newCategory.available += amount
                    unallocated.available -= amount
                    
                }
                
            }
            
            sortCategoriesByKey(withUnallocated: true)
            saveEverything()
            
        }
        
    }
    
    
    
    // MARK: Delete Category
    
    func deleteCategory (named: String) {
        
        if named != unallocatedKey {
            
            if transactions.count > 0 {
                
                for transaction in transactions {
                    
                    if transaction.forCategory == named {
                        
                        transaction.forCategory = unallocatedKey
                        
                    }
                    
                }
                
            }
            
            if let unallocated = categories[unallocatedKey], let deletedCategory = categories[named] {
                unallocated.available += deletedCategory.available
            }
            
            if named != unallocatedKey {
                categories[named] = nil
            }
            sortCategoriesByKey(withUnallocated: true)
            saveEverything()
            
        }
        
    }
    
    
    
    // MARK: Sort Categories
    
    func sortCategoriesByKey(withUnallocated: Bool) {
        
        sortedCategoryKeys = []
        
        if withUnallocated == true {
            
            for key in categories.keys {
                if key == unallocatedKey {
                    continue
                }
                sortedCategoryKeys.append(key)
            }
            sortedCategoryKeys.sort()
            sortedCategoryKeys = [unallocatedKey] + sortedCategoryKeys
            
        } else {
            
            for key in categories.keys {
                if key == unallocatedKey {
                    continue
                }
                sortedCategoryKeys.append(key)
            }
            sortedCategoryKeys.sort()
            
        }
        
    }
    
    // MARK: Update Category
    
    func updateCategory(named oldCategoryName: String, updatedNewName newCategoryName: String, andNewAmountAdded newCategoryAmount: Double) {
        
        guard let oldCategory = categories[oldCategoryName] else { return }
        
        
        // *** If 'newCategoryName' is a new category....
        if categories[newCategoryName] == nil {

            categories[newCategoryName] = Category(name: newCategoryName, budgeted: newCategoryAmount)
            
            // New category gets old category's available amount and the new amount entered.
            if let newCategory = categories[newCategoryName] {
                
                newCategory.available = oldCategory.available
                newCategory.budgeted = newCategoryAmount
                
            }
            
            // Old category removed
            categories[oldCategoryName] = nil
            
            // Transactions with old category name get set to new category's name
            for transaction in transactions {
                
                if transaction.forCategory == oldCategoryName {
                    
                    transaction.forCategory = newCategoryName
                    
                }
                        
            }
            
            
        // *** If 'newCategoryName' is the same as the old one...
        } else {
            
            oldCategory.budgeted += newCategoryAmount
            
        }
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
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
        
        let amount = inTheAmountOf
        
        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
        
        if type == .deposit {
            
            guard let unallocated = categories[unallocatedKey] else { return }
            unallocated.available += amount
            balance += amount
            
            let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)
            
            transactions.append(Transaction(transactionID: formattedTransactionID, type: .deposit, title: title, forCategory: unallocatedKey, inTheAmountOf: amount, year: year, month: month, day: day))
            
            sortTransactionsDescending()
            
            saveEverything()
            
        } else if type == .withdrawal {
            
            transactions.append(Transaction(transactionID: formattedTransactionID, type: .withdrawal, title: title, forCategory: thisCategory, inTheAmountOf: amount, year: year, month: month, day: day))
            
            guard let category = categories[thisCategory]  else { return }
            category.available -= amount
            balance -= amount
            
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
            
            guard let unallocated = categories[unallocatedKey] else { return }
            unallocated.available -= amount
            balance -= amount
            
        } else if transactions[index].type == .withdrawal {
            
            // Add amount back to category
            guard let categoryToPutBackTo = categories[category] else { return }
            categoryToPutBackTo.available += amount
            balance += amount
            
        }
        
        // Delete transaction from the index in transaction array
        transactions.remove(at: index)
        
        saveEverything()
    }
    
    
    
    // MARK: Update Transaction
    
    func updateTransaction(named updatedTransaction: Transaction, forOldTransactionAtIndex index: Int) {
        if transactions[index].type == .deposit {
            
            deleteTransaction(at: index)

            addTransaction(type: .deposit, title: updatedTransaction.title, forCategory: unallocatedKey, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
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
        balance = 0.0
        categories[unallocatedKey] = Category(name: unallocatedKey, budgeted: 0.0)
        
        UserDefaults.standard.set(nil, forKey: transactionKey)
        UserDefaults.standard.set(nil, forKey: categoryKey)
        
        loadCategories()
        loadTransactions()
        
    }
    
    
    
    
    
}

// Main Budget Model Declared
let budget = Budget()






