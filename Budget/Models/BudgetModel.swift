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


// ************************************************
// MARK: - Budget Class
// ************************************************

class Budget {

    var categories = [Category]()
    var transactions = [Transaction]()
    var sortedCategoryKeys = [String]()
    var balance = Double()

    // MARK: - Update Balance

    func updateBalance() {

        var newBalance = 0.0

        for category in categories {

            newBalance += category.available

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

            guard let currentCategory = loadSpecificCategory(named: thisCategory) else { return }

            let amount = withThisAmount

            // Adds funds to specified category
            currentCategory.available += amount

            // Takes funds from Uncategorized category
            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available -= amount

        }

        saveData()

    }



    // MARK: Remove Funds

    func removeFundsFromCategory (withThisAmount: Double, from thisCategory: String) {

        if thisCategory != unallocatedKey {

            guard let currentCategory = loadSpecificCategory(named: thisCategory) else { return }

            // Adds funds to specified category
            currentCategory.available -= withThisAmount

            // Takes funds from Uncategorized category
            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available += withThisAmount

        }

        saveData()

    }



    // MARK: Add Category

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

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            guard let deletedCategory = loadSpecificCategory(named: named) else { return }
            
            unallocated.available += deletedCategory.available

            if named != unallocatedKey {
                context.delete(deletedCategory)
            }
            
            loadSavedCategories()
            sortCategoriesByKey(withUnallocated: true)
            saveData()

        }

    }



    // MARK: Sort Categories

    func sortCategoriesByKey(withUnallocated: Bool) {

        sortedCategoryKeys = []

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

    }

    // MARK: Update Category

    func updateCategory(named oldCategoryName: String, updatedNewName newCategoryName: String, andNewAmountAdded newCategoryAmount: Double) {

        guard let categoryToUpdate = loadSpecificCategory(named: oldCategoryName) else { return }
        
        categoryToUpdate.name = newCategoryName
        categoryToUpdate.budgeted = newCategoryAmount
        
        if oldCategoryName != newCategoryName {
            
            // Transactions with old category name get set to new category's name
            for transaction in transactions {
                
                if transaction.forCategory == oldCategoryName {
                    
                    transaction.forCategory = newCategoryName
                    
                }
                
            }
            
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

        let amount = inTheAmountOf

        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)

        if type == .deposit {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available += amount
            balance += amount

            createAndSaveNewTransaction(id: Int64(formattedTransactionID), type: depositKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

        } else if type == .withdrawal {

            createAndSaveNewTransaction(id: Int64(formattedTransactionID), type: withdrawalKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

            guard let category = loadSpecificCategory(named: thisCategory)  else { return }
            category.available -= amount
            balance -= amount
            
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

        if transactions[index].type == depositKey {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available -= amount
            balance -= amount

        } else if transactions[index].type == withdrawalKey {

            // Add amount back to category
            guard let categoryToPutBackTo = loadSpecificCategory(named: categoryName!) else { return }
            categoryToPutBackTo.available += amount
            balance += amount

        }

        // Delete transaction from the index in transaction array
        context.delete(transactions[index])
        transactions.remove(at: index)

        saveData()
        
    }



    // MARK: Update Transaction

    func updateTransaction(named updatedTransaction: Transaction, forOldTransactionAtIndex index: Int) {
        if transactions[index].type == depositKey {

            context.delete(transactions[index])
            transactions.remove(at: index)

            createAndSaveNewTransaction(id: updatedTransaction.id, type: depositKey, title: updatedTransaction.title!, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day, inTheAmountOf: updatedTransaction.inTheAmountOf, forCategory: updatedTransaction.forCategory!)

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

        balance = 0.0
        
        for category in categories {
            
            context.delete(category)
            
        }
        for transaction in transactions {
            
            context.delete(transaction)
            
        }
        
        createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)

        loadSavedCategories()
        loadSavedTransactions(descending: true)

    }





}

// Main Budget Model Declared
let budget = Budget()






