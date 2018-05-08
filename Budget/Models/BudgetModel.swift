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

    func addTransaction (fullDate: Date, type: TransactionType, title: String, forCategory thisCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {

        let amount = inTheAmountOf

        let formattedTransactionID = convertedDateComponentsToTransactionID(year: year, month: month, day: day)

        if type == .deposit {

            guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
            unallocated.available += amount
            balance += amount

            createAndSaveNewTransaction(fullDate: fullDate, id: Int64(formattedTransactionID), type: depositKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

        } else if type == .withdrawal {

            createAndSaveNewTransaction(fullDate: fullDate, id: Int64(formattedTransactionID), type: withdrawalKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)

            guard let category = loadSpecificCategory(named: thisCategory)  else { return }
            category.available -= amount
            balance -= amount
            
        }
        
        sortTransactionsDescending()
        
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


    // *** Update Transaction

    func updateTransaction(named updatedTransaction: Transaction, forOldTransactionAtIndex index: Int) {
        if transactions[index].type == depositKey {

            context.delete(transactions[index])
            transactions.remove(at: index)

            createAndSaveNewTransaction(fullDate: updatedTransaction.fullDate!, id: updatedTransaction.id, type: depositKey, title: updatedTransaction.title!, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day, inTheAmountOf: updatedTransaction.inTheAmountOf, forCategory: updatedTransaction.forCategory!)

        } else {

            context.delete(transactions[index])
            transactions.remove(at: index)

            createAndSaveNewTransaction(fullDate: updatedTransaction.fullDate!, id: updatedTransaction.id, type: withdrawalKey, title: updatedTransaction.title!, year: updatedTransaction.year, month: updatedTransaction.month, day: updatedTransaction.day, inTheAmountOf: updatedTransaction.inTheAmountOf, forCategory: updatedTransaction.forCategory!)

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
        for timeFrame in budgetedTimeFrames {
            
            context.delete(timeFrame)
            
        }
        
        createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)

        loadSavedCategories()
        
        UserDefaults.standard.set(nil, forKey: categoryKey)
        UserDefaults.standard.set(nil, forKey: transactionKey)

    }





}

// Main Budget Model Declared
let budget = Budget()






