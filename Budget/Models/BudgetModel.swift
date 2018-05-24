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
    var budgetItems = [BudgetItem]()
    var transactions = [Transaction]()
    var paychecks = [Paycheck]()
    
    
    var sortedCategoryKeys = [String]()
    var balance = Double()
    var mostRecentidFromAddedTransaction = Int()

    // *** Update Balance

    func updateBalance() {

//        var newBalance = 0.0

        // TODO: - FIX BALANCE TO ONLY BE FOR CURRENT BUDGETED TIME PERIOD.

//        balance = newBalance

    }
    
    
    
    // *****
    // MARK: - Category Functions
    // *****
    
    func addCategory(named: String, withBudgeted amount: Double, withDueDay dueDay: Int) {
        
        if named != unallocatedKey {
            
            for category in categories {
                
                if category.name == named {
                    
                    return
                    
                }
                
            }
            
            createAndSaveNewCategory(named: named, withBudgeted: amount, dueDay: dueDay)
            
            
            // Create and save new budget items based on this.
            let periods = loadSavedBudgetedTimeFrames()
            
            let currentDateIDForAddingPurposes = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
            
            for period in periods {
                
                if period.endDateID > currentDateIDForAddingPurposes {
                    
                    addCategoryAsBudgetedItem(period: period, idForAdding: currentDateIDForAddingPurposes, named: named, budgeted: amount, dueDay: dueDay)
                    
                }
                
            }
            
            saveData()
            
        }

    }
    
    
    func addCategoryAsBudgetedItem(period: Period, idForAdding: Int, named: String, budgeted: Double, dueDay: Int) {
        
        if named != unallocatedKey {
            
            var available = Double()
            
            if idForAdding > period.endDateID {
                
                available = 0
                
            } else if idForAdding > period.startDateID && idForAdding < period.endDateID {
                
                available = budgeted
                
            }
            
            createAndSaveNewBudgetItem(periodStartID: Int(period.startDateID), type: categoryKey, named: named, budgeted: budgeted, available: available, category: categoryKey, year: 0, month: 0, day: dueDay)
            
        }
        
    }
    
    
    
    // *** Delete Category
    
    func deleteCategory (named: String) {
        
        if named != unallocatedKey {
            
            // Delete budget items based on this.
            
            guard let categoryToDelete = loadSpecificCategory(named: named) else { return }
            
            let currentDateIDForDeletingPurposes = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
            
            let periods = loadSavedBudgetedTimeFrames()
            
            for period in periods {
                
                // If the end date is greater than today's date; in other words, the category being deleted for the current budget time frame and the future ones, but not the past ones, as the 'endDateID' would be less (in the past) than the current date.
                if period.endDateID > currentDateIDForDeletingPurposes {
                    
                    let items = loadSpecificBudgetItems(startID: Int(period.startDateID))
                    
                    for item in items {
                        
                        if categoryToDelete.name == item.name && item.type == categoryKey {
                            
                            context.delete(item)
                            
                        }
                        
                    }
                    
                }
                
            }
            
            if transactions.count > 0 {
                
                for transaction in transactions {
                    
                    if transaction.forCategory == named {
                        
                        transaction.forCategory = unallocatedKey
                        
                    }
                    
                }
                
            }
            
            guard let deletedCategory = loadSpecificCategory(named: named) else { return }
            
            context.delete(deletedCategory)
            
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
    
    func updateCategory(named oldCategoryName: String, updatedNewName newCategoryName: String, andNewAmountBudgeted newCategoryBudgetedAmount: Double) {
        
        guard let categoryToUpdate = loadSpecificCategory(named: oldCategoryName) else { return }
        
        // Update budget items based on updating Category
        updateBudgetItemsPerCategoryOrPaycheckUpdate(oldName: oldCategoryName, newName: newCategoryName, oldAmount: categoryToUpdate.budgeted, newAmount: newCategoryBudgetedAmount)
        
        categoryToUpdate.name = newCategoryName
        categoryToUpdate.budgeted = newCategoryBudgetedAmount
        
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
    
    
    
    // *****
    // MARK: - Budgeted Time Frame Functions
    // *****
    
    func addTimeFrame(start: Date, end: Date) {
        
        createAndSaveNewBudgetedTimeFrame(start: start, end: end)
        
        saveData()
        
    }
    
    func deleteTimeFrame(period: Period) {
        
        let items = loadSpecificBudgetItems(startID: Int(period.startDateID))
        
        for item in items {
            
            context.delete(item)
            
        }
        
        context.delete(period)
        
        saveData()
        
    }
    
    func updateStartDate(currentStartID: Int, newStartDate: Date) {
        
        let newStartID = convertDateToBudgetedTimeFrameID(timeFrame: newStartDate, isEnd: false)
        
        let items = loadSpecificBudgetItems(startID: currentStartID)
        for item in items {
            item.periodStartID = Int64(newStartID)
        }
        
        
        let newStartDict = convertDateToInts(dateToConvert: newStartDate)
        
        guard let newYear = newStartDict[yearKey] else { return }
        guard let newMonth = newStartDict[monthKey] else { return }
        guard let newDay = newStartDict[dayKey] else { return }
        
        guard let currentTimeFrame = loadSpecificBudgetedTimeFrame(startID: currentStartID) else { return }
        
        currentTimeFrame.startDateID = Int64(newStartID)
        currentTimeFrame.startYear = Int64(newYear)
        currentTimeFrame.startMonth = Int64(newMonth)
        currentTimeFrame.startDay = Int64(newDay)
        
        saveData()
        
    }
    
    func updateEndDate(currentStartID: Int, newEndDate: Date) {
        
        let newEndID = convertDateToBudgetedTimeFrameID(timeFrame: newEndDate, isEnd: true)
        
        let newEndDict = convertDateToInts(dateToConvert: newEndDate)
        
        guard let newYear = newEndDict[yearKey] else { return }
        guard let newMonth = newEndDict[monthKey] else { return }
        guard let newDay = newEndDict[dayKey] else { return }
        
        guard let currentTimeFrame = loadSpecificBudgetedTimeFrame(startID: currentStartID) else { return }
        
        currentTimeFrame.endDateID = Int64(newEndID)
        currentTimeFrame.endYear = Int64(newYear)
        currentTimeFrame.endMonth = Int64(newMonth)
        currentTimeFrame.endDay = Int64(newDay)
        
        saveData()
        
    }
    
    func updateBalanceForSpecificTimeFrame(withStartID id: Int) {
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: id) else { return }
        
        var balance = Double()
        
        let items = loadSpecificBudgetItems(startID: id)
        
        for item in items {
            
            if item.type == paycheckKey || item.type == depositKey {
                
                balance += item.available
                
            } else {
                
                balance -= item.available
                
            }
            
        }
        
        period.balance = balance
        
        saveData()
        
    }
    
    func updateUnallocatedForSpecificTimeFrame(withStartID id: Int) {
        
        guard let period = loadSpecificBudgetedTimeFrame(startID: id) else { return }
        
        var unallocated = period.balance
        
        let items = loadSpecificBudgetItems(startID: id)
        
        for item in items {
            
            unallocated -= item.budgeted
            
        }
        
        period.unallocated = unallocated
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Budget Items Functions
    // *****
    
    func updateBudgetItemName(name: String, forItem item: BudgetItem) {
        
        let budgetItem = item
        budgetItem.name = name
        
        saveData()
        
    }
    
    func updateBudgetItemCategory(category: String, forItem item: BudgetItem) {
        
        let budgetItem = item
        budgetItem.category = category
        
        saveData()
        
    }
    
    func updateBudgetItemAmount(amount: Double, forItem item: BudgetItem) {
        
        let budgetItem = item
        budgetItem.budgeted = amount
        
        saveData()
        
    }
    
    func updateBudgetItemDueDate(dueDate: Date?, forItem item: BudgetItem) {
        
        let budgetItem = item
        
        if let dueDate = dueDate {
            
            let dateDict = convertDateToInts(dateToConvert: dueDate)
            
            guard let dueDay = dateDict[dayKey] else { return }
            
            budgetItem.day = Int64(dueDay)
            
        } else {
            
            budgetItem.day = 0
            
        }
        
        
        saveData()
        
    }
    
    func deleteBudgetItem(itemToDelete: BudgetItem) {
        
        context.delete(itemToDelete)
        
        saveData()
        
    }
    
    // *** Update Budget Item from Category or Paycheck Updates
    
    func updateBudgetItemsPerCategoryOrPaycheckUpdate(oldName: String, newName: String, oldAmount: Double, newAmount: Double) {
        
        // Update budget items based on updating Category
        loadSavedBudgetItems()
        
        if budgetItems.count > 0 {
            
            for item in budgetItems {
                
                if item.name == oldName {
                    
                    item.name = newName
                    
                }
                
                if item.budgeted == oldAmount {
                    
                    item.budgeted = newAmount
                    
                }
                
            }
            
        }
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Transaction Functions
    // *****
    
    func addTransaction (onHold: Bool, type: TransactionType, title: String, forCategory thisCategory: String, inTheAmountOf: Double, year: Int, month: Int, day: Int) {
        
        let amount = inTheAmountOf
        
        let formattedTransactionID = convertDateComponentsToTransactionID(year: year, month: month, day: day)
        
        if type == .deposit {
           
            createAndSaveNewTransaction(onHold: onHold, id: Int64(formattedTransactionID), type: depositKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)
            
        } else if type == .withdrawal {
            
            createAndSaveNewTransaction(onHold: onHold, id: Int64(formattedTransactionID), type: withdrawalKey, title: title, year: Int64(year), month: Int64(month), day: Int64(day), inTheAmountOf: amount, forCategory: thisCategory)
           
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
    
    func deleteTransaction (withID id: Int) {
        
        guard let transactionToDelete = loadSpecificTransaction(idSubmitted: id) else { return }
        
        guard let index = transactions.index(of: transactionToDelete) else { return }
        
        // Delete transaction from the index in transaction array
        context.delete(transactionToDelete)
        transactions.remove(at: index)
        
        updateBalance()
        
        saveData()
        
    }
    
  
    
    func updateTransactionTitle(title newTitle: String, withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
        
        currentTransaction.title = newTitle
        
        saveData()
        
    }
    
   
    
    func updateTransactionAmount(amount newAmount: Double, withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
       
        if currentTransaction.type == depositKey {
            
//            category.available -= currentTransaction.inTheAmountOf
//            category.available += newAmount
            
        } else {
            
//            category.available += currentTransaction.inTheAmountOf
//            category.available -= newAmount
            
        }
        
        currentTransaction.inTheAmountOf = newAmount
        
        
        saveData()
        
    }
    
    
    
    func updateTransactionDate(newDate: Date, withID id: Int) {
        
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
        
        deleteTransaction(withID: id)
        
        addTransaction(onHold: onHold, type: type, title: title, forCategory: category, inTheAmountOf: amount, year: year, month: month, day: day)
        
        saveData()
        
    }
    
    
    
    func updateTransactionCategory(category newCategoryName: String, withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
    
        if currentTransaction.type == withdrawalKey {
            
           
            
        }
        
        currentTransaction.forCategory = newCategoryName
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Paycheck Functions
    // *****
    
    func updatePaycheckName(newName: String, forPaycheck paycheck: Paycheck) {
        
        let paycheck = paycheck
        
        updateBudgetItemsPerCategoryOrPaycheckUpdate(oldName: paycheck.name!, newName: newName, oldAmount: paycheck.amount, newAmount: paycheck.amount)
        
        paycheck.name = newName
        
        saveData()
        
    }
    
    func updatePaycheckAmount(newAmount: Double, forPaycheck paycheck: Paycheck) {
        
        let paycheck = paycheck
        
        updateBudgetItemsPerCategoryOrPaycheckUpdate(oldName: paycheck.name!, newName: paycheck.name!, oldAmount: paycheck.amount, newAmount: newAmount)
        
        paycheck.amount = newAmount
        
        saveData()
        
    }
    
    func deletePaycheck(paycheck: Paycheck) {
        
        // Delete budget items based on this.
        
        loadSavedBudgetItems()
        
        for item in budgetItems {
            
            if paycheck.name == item.name && item.type == paycheckKey {
                
                context.delete(item)
                
            }
            
        }
        
        context.delete(paycheck)
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Adding to ledger functions
    // *****
    
    func addPaycheckToLedger(paycheckItem: BudgetItem?, withDate date: Date) {
        
        if let item = paycheckItem {
            
            var dateDict = convertDateToInts(dateToConvert: date)
           
            guard let year = dateDict[yearKey] else { return }
            guard let month = dateDict[monthKey] else { return }
            guard let day = dateDict[dayKey] else { return }
            
            addTransaction(onHold: false, type: .deposit, title: item.name!, forCategory: unallocatedKey, inTheAmountOf: item.budgeted, year: year, month: month, day: day)
            
            item.checked = true
            item.addedToLedger = true
            
        }

    }
    
    func addCategoryToLedger(categoryItem: BudgetItem?) {
        
        if let item = categoryItem {
        
            item.checked = true
            item.addedToLedger = true
            
        }
        
    }
    
    func addOtherBudgetItemToLedger(otherItem: BudgetItem?, withDate date: Date) {
        
        if let item = otherItem {
            
            var dateDict = convertDateToInts(dateToConvert: date)
            
            guard let year = dateDict[yearKey] else { return }
            guard let month = dateDict[monthKey] else { return }
            guard let day = dateDict[dayKey] else { return }
            
            let typeToSubmit: TransactionType = (item.type == depositKey) ? .deposit : .withdrawal
           
            addTransaction(onHold: false, type: typeToSubmit, title: item.name!, forCategory: item.category!, inTheAmountOf: item.budgeted, year: year, month: month, day: day)
            
            item.checked = true
            item.addedToLedger = true
            
        }
        
    }
    
    func addBudgetItemToLedger(budgetItem: BudgetItem?, withDate date: Date) {
        
        if let item = budgetItem {
            
            if item.type == paycheckKey {
                
                addPaycheckToLedger(paycheckItem: item, withDate: date)
                
            } else if item.type == categoryKey {
                
                addCategoryToLedger(categoryItem: item)
                
            } else {
                
                
                
            }
            
            saveData()
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Shift Funds Function
    // *****
    
    func shiftFunds (withThisAmount amount: Double, from fromCategory: String, to toCategory: String) {
        
        if fromCategory == unallocatedKey {
            
            
            
        }
        
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
        
        loadSavedCategories()
        loadSavedTransactions(descending: true)
        let periods = loadSavedBudgetedTimeFrames()
        loadSavedPaychecks()
        loadSavedBudgetItems()

        balance = 0.0
        
        for category in categories {
            
            context.delete(category)
            
        }
        for transaction in transactions {
            
            context.delete(transaction)
            
        }
        for paycheck in paychecks {
            
            context.delete(paycheck)
            
        }
        for period in periods {
            
            context.delete(period)
            
        }
        for budgetItem in budgetItems {
            
            context.delete(budgetItem)
            
        }
       
        createUnallocatedCategory()
        createCurrentTimeFrame()
        
//        UserDefaults.standard.set(nil, forKey: categoryKey)
//        UserDefaults.standard.set(nil, forKey: transactionKey)

    }





}

// Main Budget Model Declared
let budget = Budget()






