//
//  BudgetModel.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//


import Foundation
import UIKit
import CoreData



enum TransactionType {
    case withdrawal
    case deposit
}

<<<<<<< HEAD
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
=======
>>>>>>> switchToCoreData

// ************************************************
// MARK: - Budget Class
// ************************************************

class Budget {

    var categories = [Category]()
    var transactions = [Transaction]()
    var sortedCategoryKeys = [String]()
<<<<<<< HEAD
    
    init() {
        self.categories[uncategorizedKey] = Category(name: uncategorizedKey, budgeted: 0.0)
    }
    
    
    
=======
    var balance = Double()

    // MARK: - Update Balance

    func updateBalance() {

        var newBalance = 0.0

        for category in categories {

            newBalance += category.available

        }

        balance = newBalance

    }


>>>>>>> switchToCoreData
    // ************************************************
    // MARK: - Category functions
    // ************************************************



    // MARK: Allocate Funds


    func allocateFundsToCategory (withThisAmount: Double, to thisCategory: String) {

        // It can't be, but this just makes it clearer
<<<<<<< HEAD
        if thisCategory != uncategorizedKey {
            
            guard let currentCategory = categories[thisCategory] else { return }
                
=======
        if thisCategory != unallocatedKey {

            guard let currentCategory = loadSpecificCategory(named: thisCategory) else { return }

>>>>>>> switchToCoreData
            let amount = withThisAmount

            // Adds funds to specified category
            currentCategory.available += amount

            // Takes funds from Uncategorized category
<<<<<<< HEAD
            guard let uncategorized = categories[uncategorizedKey] else { return }
            uncategorized.available -= amount
            
=======
            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available -= amount

>>>>>>> switchToCoreData
        }

        saveData()

    }



    // MARK: Remove Funds
<<<<<<< HEAD
    
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
            
=======

    func removeFundsFromCategory (withThisAmount: Double, from thisCategory: String) {

        if thisCategory != unallocatedKey {

            guard let currentCategory = loadSpecificCategory(named: thisCategory) else { return }

            // Adds funds to specified category
            currentCategory.available -= withThisAmount

            // Takes funds from Uncategorized category
            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available += withThisAmount

>>>>>>> switchToCoreData
        }

        saveData()

    }



    // MARK: Add Category
<<<<<<< HEAD
    
    func addCategory (named: String, withThisAmount: Double) {
        if categories[named] == nil {
            categories[named] = Category(name: named, budgeted: withThisAmount)
            
        }
        sortCategoriesByKey(withUncategorized: false)
        saveEverything()
=======

    func addCategory (named: String, withBudgeted amount: Double) {

        if named != unallocatedKey {
            
            for category in categories {
                
                if category.name == named {
                    
                    return
                    
                }
                
            }

            createAndSaveNewCategory(named: named, withBudgeted: amount, andAvailable: 0.0)

            sortCategoriesByKey(withUnallocated: true)
            saveData()

        }

>>>>>>> switchToCoreData
    }



    // MARK: Delete Category

    func deleteCategory (named: String) {
<<<<<<< HEAD
        
        // Cannot delete "Uncategorized" because it doesn't show up in any place, so it will always be the default in the background.
        
        if transactions.count > 0 {
            
            for transaction in transactions {
                
                if transaction.forCategory == named {
                    
                    transaction.forCategory = uncategorizedKey
                    
=======

        if named != unallocatedKey {

            if transactions.count > 0 {

                for transaction in transactions {

                    if transaction.forCategory == named {

                        transaction.forCategory = unallocatedKey

                    }

>>>>>>> switchToCoreData
                }

            }

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            guard let deletedCategory = loadSpecificCategory(named: named) else { return }
            
<<<<<<< HEAD
        }
        
        if let uncategorized = categories[uncategorizedKey], let deletedCategory = categories[named] {
            uncategorized.available += deletedCategory.available
        }
        
        if named != uncategorizedKey {
            categories[named] = nil
        }
        sortCategoriesByKey(withUncategorized: false)
        saveEverything()
=======
            unallocated.available += deletedCategory.available

            if named != unallocatedKey {
                context.delete(deletedCategory)
            }
            
            loadSavedCategories()
            sortCategoriesByKey(withUnallocated: true)
            saveData()

        }

>>>>>>> switchToCoreData
    }



    // MARK: Sort Categories
<<<<<<< HEAD
    
    func sortCategoriesByKey (withUncategorized: Bool) {
=======

    func sortCategoriesByKey(withUnallocated: Bool) {
>>>>>>> switchToCoreData
        
        loadSavedCategories()

        sortedCategoryKeys = []
<<<<<<< HEAD
        
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
        
=======

        if withUnallocated == true {

            for category in categories {
                if category.name == unallocatedKey {
                    continue
                }
                sortedCategoryKeys.append(category.name!)
            }
            sortedCategoryKeys.sort()
            sortedCategoryKeys = [unallocatedKey] + sortedCategoryKeys

        } else if withUnallocated == false {

            for category in categories {
                if category.name == unallocatedKey {
                    continue
                }
                sortedCategoryKeys.append(category.name!)
            }
            sortedCategoryKeys.sort()

        }

>>>>>>> switchToCoreData
    }

    // MARK: Update Category
<<<<<<< HEAD
    
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
=======

    func updateCategory(named oldCategoryName: String, updatedNewName newCategoryName: String, andNewAmountAdded newCategoryAmount: Double) {

        guard let categoryToUpdate = loadSpecificCategory(named: oldCategoryName) else { return }
        
        categoryToUpdate.name = newCategoryName
        categoryToUpdate.budgeted = newCategoryAmount
        
        if oldCategoryName != newCategoryName {
>>>>>>> switchToCoreData
            
            // Transactions with old category name get set to new category's name
            for transaction in transactions {
                
                if transaction.forCategory == oldCategoryName {
                    
                    transaction.forCategory = newCategoryName
                    
                }
                
            }
<<<<<<< HEAD
                    
=======
            
>>>>>>> switchToCoreData
        }

        budget.sortCategoriesByKey(withUnallocated: true)

        saveData()

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
            if convertedID == transaction.id {
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
<<<<<<< HEAD
        
=======

        let amount = inTheAmountOf

>>>>>>> switchToCoreData
        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)

        if type == .deposit {
<<<<<<< HEAD
            
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
=======

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available += amount
            balance += amount

            createAndSaveNewTransaction(id: Int64(formattedTransactionID), type: depositKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

        } else if type == .withdrawal {

            createAndSaveNewTransaction(id: Int64(formattedTransactionID), type: withdrawalKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

            guard let category = loadSpecificCategory(named: thisCategory)  else { return }
            category.available -= amount
            balance -= amount
>>>>>>> switchToCoreData
            
        }
        
        sortTransactionsDescending()
        
        saveData()

    }



    // MARK: Sort Transactions

    func sortTransactionsDescending() {
        
        loadSavedTransactions(descending: true)

    }

    func sortTransactionsAscending() {
        
        loadSavedTransactions(descending: false)

    }



    // MARK: Delete transaction

    func deleteTransaction (at index: Int) {
        let categoryName = transactions[index].forCategory
        let amount = transactions[index].inTheAmountOf
<<<<<<< HEAD
        
        if transactions[index].type == .deposit {
            
            guard let uncategorized = categories[uncategorizedKey] else { return }
            uncategorized.available -= transactions[index].inTheAmountOf
            
        } else if transactions[index].type == .withdrawal {
            
=======

        if transactions[index].type == depositKey {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available -= amount
            balance -= amount

        } else if transactions[index].type == withdrawalKey {

>>>>>>> switchToCoreData
            // Add amount back to category
            guard let categoryToPutBackTo = loadSpecificCategory(named: categoryName!) else { return }
            categoryToPutBackTo.available += amount
<<<<<<< HEAD
            
=======
            balance += amount

>>>>>>> switchToCoreData
        }

        // Delete transaction from the index in transaction array
        context.delete(transactions[index])
        transactions.remove(at: index)

        saveData()
        
    }



    // MARK: Update Transaction

<<<<<<< HEAD
            addTransaction(type: .deposit, title: updatedTransaction.title, forCategory: uncategorizedKey, inTheAmountOf: updatedTransaction.inTheAmountOf, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day)
            
=======
    func updateTransaction(named updatedTransaction: Transaction, forOldTransactionAtIndex index: Int) {
        if transactions[index].type == depositKey {

            context.delete(transactions[index])
            transactions.remove(at: index)

            createAndSaveNewTransaction(id: updatedTransaction.id, type: depositKey, title: updatedTransaction.title!, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day, inTheAmountOf: updatedTransaction.inTheAmountOf, forCategory: updatedTransaction.forCategory!)

>>>>>>> switchToCoreData
        } else {

            context.delete(transactions[index])
            transactions.remove(at: index)

            createAndSaveNewTransaction(id: updatedTransaction.id, type: withdrawalKey, title: updatedTransaction.title!, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day, inTheAmountOf: updatedTransaction.inTheAmountOf, forCategory: updatedTransaction.forCategory!)

        }
        
        loadSavedTransactions(descending: true)
        
        saveData()

    }




    //////////////////////////////
    //////////////////////////////
    //                          //
    // DELETE EVERYTHING SO FAR //
    //                          //
    //////////////////////////////
    //////////////////////////////


    func deleteEVERYTHING(){
<<<<<<< HEAD
        
        categories = [:]
        transactions = []
        categories[uncategorizedKey] = Category(name: uncategorizedKey, budgeted: 0.0)
=======

        balance = 0.0
>>>>>>> switchToCoreData
        
        for category in categories {
            
            context.delete(category)
            
        }
        for transaction in transactions {
            
            context.delete(transaction)
            
        }
        
        createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)

        loadSavedCategories()
        loadSavedTransactions(descending: true)
        
        UserDefaults.standard.set(nil, forKey: categoryKey)
        UserDefaults.standard.set(nil, forKey: transactionKey)

    }





}

// Main Budget Model Declared
let budget = Budget()






