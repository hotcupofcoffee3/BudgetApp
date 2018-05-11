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

class Budget {

    var categories = [Category]()
    var transactions = [Transaction]()
    var budgetedTimeFrames = [Period]()
    var sortedCategoryKeys = [String]()
    var balance = Double()
    var mostRecentidFromAddedTransaction = Int()

    // *** Update Balance

    func updateBalance() {

        var newBalance = 0.0

        for category in categories {

            newBalance += category.available

        }

        balance = newBalance

    }
    
    
    
    // *****
    // MARK: - Budgeted Time Frame functions
    // *****

    
    // *** Add Time Frame
    
    func addTimeFrame (start: Date, end: Date) {
        
        createAndSaveNewBudgetedTimeFrame(start: start, end: end)
    
        saveData()
        
    }
    
    
    // *****
    // MARK: - Category functions
    // *****

    
    // *** Add Category

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


    // *** Delete Category

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


    // *** Sort Categories

    func sortCategoriesByKey(withUnallocated: Bool) {
        
        loadSavedCategories()

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

    
    // *** Update Category

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

    
    // *** Shift Funds
    
    func shiftFunds (withThisAmount amount: Double, from fromCategory: String, to toCategory: String) {
        
        guard let fromCategory = loadSpecificCategory(named: fromCategory) else { return }
        guard let toCategory = loadSpecificCategory(named: toCategory) else { return }
        
        toCategory.available += amount
        fromCategory.available -= amount
        
        saveData()
        
    }



    // *****
    // MARK: - Transaction functions
    // *****


    


    // *** Add Transaction

    func addTransaction (onHold: Bool, type: TransactionType, title: String, forCategory thisCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {

        let amount = inTheAmountOf

        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)

        if type == .deposit {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            
            if onHold == false {
                
                unallocated.available += amount
                
            }

            createAndSaveNewTransaction(onHold: onHold, id: Int64(formattedTransactionID), type: depositKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

        } else if type == .withdrawal {

            createAndSaveNewTransaction(onHold: onHold, id: Int64(formattedTransactionID), type: withdrawalKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

            guard let category = loadSpecificCategory(named: thisCategory)  else { return }
            
            if onHold == false {
                
                category.available -= amount
                
            }
            
        }
        
        sortTransactionsDescending()
        
        mostRecentidFromAddedTransaction = formattedTransactionID
        
        updateBalance()
        
        saveData()

    }


    // *** Sort Transactions

    func sortTransactionsDescending() {
        
        loadSavedTransactions(descending: true)

    }

    func sortTransactionsAscending() {
        
        loadSavedTransactions(descending: false)

    }



    // *** Delete transaction

    func deleteTransaction (at index: Int) {
        let categoryName = transactions[index].forCategory
        let amount = transactions[index].inTheAmountOf

        if transactions[index].type == depositKey {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            
            if transactions[index].onHold == false {
                
                unallocated.available -= amount
                
            }

        } else if transactions[index].type == withdrawalKey {

            // Add amount back to category
            guard let categoryToPutBackTo = loadSpecificCategory(named: categoryName!) else { return }
            
            if transactions[index].onHold == false {
                
                categoryToPutBackTo.available += amount
                
            }

        }

        // Delete transaction from the index in transaction array
        context.delete(transactions[index])
        transactions.remove(at: index)

        updateBalance()
        
        saveData()
        
    }


    // *** Update Transaction Functions

    // Title
    func updateTransactionTitle(title newTitle: String, withID id: Int) {
    
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }

        currentTransaction.title = newTitle
        
        saveData()

    }
    
    // Amount
    func updateTransactionAmount(amount newAmount: Double, withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
        
        guard let transactionCategory = currentTransaction.forCategory else { return }
        guard let category = loadSpecificCategory(named: transactionCategory) else { return }
        
        if currentTransaction.type == depositKey {
            
            category.available -= currentTransaction.inTheAmountOf
            category.available += newAmount
            
        } else {
            
            category.available += currentTransaction.inTheAmountOf
            category.available -= newAmount
            
        }
        
        currentTransaction.inTheAmountOf = newAmount
        
        
        saveData()
        
    }
    
    // Date
    func updateTransactionDate(newDate: Date, withID id: Int, atIndex index: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
        
        let dateDict = convertDateToInts(dateToConvert: newDate)
        
        var type: TransactionType
        
        if currentTransaction.type == depositKey {
            type = .deposit
        } else {
            type = .withdrawal
        }
        
        let onHold = currentTransaction.onHold
        let title = currentTransaction.title!
        let year = dateDict[yearKey]!
        let month = dateDict[monthKey]!
        let day = dateDict[dayKey]!
        let amount = currentTransaction.inTheAmountOf
        let category = currentTransaction.forCategory!
        
        deleteTransaction(at: index)
        
        addTransaction(onHold: onHold, type: type, title: title, forCategory: category, inTheAmountOf: amount, year: year, month: month, day: day)
        
        saveData()
        
    }
    
    // Category
    func updateTransactionCategory(category newCategoryName: String, withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
        guard let oldTransactionCategoryName = currentTransaction.forCategory else { return }
        
        guard let oldCategory = loadSpecificCategory(named: oldTransactionCategoryName) else { return }
        guard let newCategory = loadSpecificCategory(named: newCategoryName) else { return }
        
        if currentTransaction.type == withdrawalKey {
            
            oldCategory.available += currentTransaction.inTheAmountOf
            newCategory.available -= currentTransaction.inTheAmountOf
            
        }
        
        currentTransaction.forCategory = newCategoryName
        
        saveData()
        
    }
    
    func updateBalanceAndAvailableForOnHold(forTransaction transaction: Transaction) {
        
        guard let category = loadSpecificCategory(named: transaction.forCategory!) else { return }
        
        if transaction.onHold == true {
            
            category.available += transaction.inTheAmountOf
            updateBalance()
            
        } else if transaction.onHold == false {
            
            category.available -= transaction.inTheAmountOf
            updateBalance()
            
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

        balance = 0.0
        
        for category in categories {
            
            context.delete(category)
            
        }
        for transaction in transactions {
            
            context.delete(transaction)
            
        }
        for timeFrame in budgetedTimeFrames {
            
            context.delete(timeFrame)
            
        }
        
        createUnallocatedCategory()

        createAndSaveNewBudgetedTimeFrame(start: Date.distantPast, end: Date())

        loadSavedCategories()
        loadSavedBudgetedTimeFrames(descending: true)
        
        UserDefaults.standard.set(nil, forKey: categoryKey)
        UserDefaults.standard.set(nil, forKey: transactionKey)

    }





}

// Main Budget Model Declared
let budget = Budget()






