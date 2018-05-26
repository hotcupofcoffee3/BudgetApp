//
//  SaveBudgetInfo.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



// MARK: - Context created

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

// MARK: - Save everything

func saveData() {
    
    do {
        
        try context.save()
        
    } catch {
        
        print("Error saving data: \(error)")
        
    }
    
    budget.updateBalance()
    
}



// *****
// MARK: - Add Transaction to Saved Transactions
// *****

func createAndSaveNewTransaction(onHold: Bool, id: Int64, type: String, title: String, year: Int64, month: Int64, day: Int64, inTheAmountOf: Double, forCategory: String) {
    
    let transactionToSave = Transaction(context: context)
    
    transactionToSave.onHold = onHold
    transactionToSave.id = id
    transactionToSave.type = type
    transactionToSave.title = title
    transactionToSave.year = year
    transactionToSave.month = month
    transactionToSave.day = day
    transactionToSave.inTheAmountOf = inTheAmountOf
    transactionToSave.forCategory = forCategory
    
    saveData()
    
}



// *****
// MARK: - Add Paycheck and Category to Saved Paychecks and Saved Categories
// *****



// MARK: - Save a new paycheck to saved paychecks

func createAndSaveNewPaycheck(named: String, withAmount amount: Double) {
    
    let paycheckToSave = Paycheck(context: context)
    
    paycheckToSave.name = named
    paycheckToSave.amount = amount
    
    addPaycheckAsBudgetedItemToPeriods(named: named, amount: amount)
    
    saveData()
    
}



// MARK: - Save a new category to saved categories

func createAndSaveNewCategory(named: String, withBudgeted budgeted: Double, dueDay: Int) {
    
    let categoryToSave = Category(context: context)
    
    categoryToSave.name = named
    categoryToSave.budgeted = budgeted
    categoryToSave.dueDay = Int64(dueDay)
    
    addCategoryAsBudgetedItemToPeriods(named: named, withBudgeted: budgeted, dueDay: dueDay)
    
    saveData()
    
}



// *****
// MARK: - Add Budget Period and Budget Item
// *****


// MARK: - Save a new Budgeted Time Frame

func createAndSaveNewBudgetedTimeFrame(start: Date, end: Date) {
    
    let startDict = convertDateToInts(dateToConvert: start)
    let endDict = convertDateToInts(dateToConvert: end)
    
    let startDateID = convertDateToBudgetedTimeFrameID(timeFrame: start, isEnd: false)
    let endDateID = convertDateToBudgetedTimeFrameID(timeFrame: end, isEnd: true)
    
    let budgetedTimeFrameToSave = Period(context: context)
    
    if let startYear = startDict[yearKey], let startMonth = startDict[monthKey], let startDay = startDict[dayKey], let endYear = endDict[yearKey], let endMonth = endDict[monthKey], let endDay = endDict[dayKey] {
        
        budgetedTimeFrameToSave.startYear = Int64(startYear)
        budgetedTimeFrameToSave.startMonth = Int64(startMonth)
        budgetedTimeFrameToSave.startDay = Int64(startDay)
        budgetedTimeFrameToSave.endYear = Int64(endYear)
        budgetedTimeFrameToSave.endMonth = Int64(endMonth)
        budgetedTimeFrameToSave.endDay = Int64(endDay)
        
        budgetedTimeFrameToSave.startDateID = Int64(startDateID)
        budgetedTimeFrameToSave.endDateID = Int64(endDateID)
        
    }
    
    createUnallocatedBudgetItem(startID: startDateID)
    
    createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: startDateID, endDateID: endDateID)
    
    // Calculate balance
    // Set new period's balance to the calculated balance
    // Calculate unallocated
    // Set new period's unallocated to the calculated unallocated
    
    let items = loadSpecificBudgetItems(startID: startDateID)
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    guard let currentUnallocatedItem = loadUnallocatedItem(startID: startDateID) else { return }
    
    budgetedTimeFrameToSave.unallocated = currentUnallocatedItem.budgeted
    
    var startingPeriodBalance = Double()
    
    for item in items {
        
        if item.name != unallocatedKey {
            
            print(item.budgeted)
            
            if startDateID > currentDateAsPeriodID {
                
                startingPeriodBalance += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
                
            } else {
                
                startingPeriodBalance += (item.type == paycheckKey) ? item.available : -item.available
                
            }
            
        }
        
    }
    
    print(startingPeriodBalance)
    
    budgetedTimeFrameToSave.balance = startingPeriodBalance
    
    saveData()
    
}



// MARK: - Save a new budget item

func createAndSaveNewBudgetItem(periodStartID: Int, type: String, named: String, budgeted: Double, available: Double, category: String, year: Int, month: Int, day: Int, checked: Bool) {
    
    let itemToSave = BudgetItem(context: context)
    
    itemToSave.periodStartID = Int64(periodStartID)
    itemToSave.type = type
    itemToSave.name = named
    itemToSave.budgeted = budgeted
    itemToSave.available = available
    itemToSave.category = category
    itemToSave.year = Int64(year)
    itemToSave.month = Int64(month)
    itemToSave.checked = checked
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// *****
// MARK: - Add Paychecks and Categories to Present and Future Periods.
// *****



// New Paycheck: Adds a newly added Paycheck to present and future Periods.

func addPaycheckAsBudgetedItemToPeriods(named: String, amount: Double) {
    
    var available = Double()
    
    // Create and save new budget items based on this.
    let periods = loadSavedBudgetedTimeFrames()
    
    let currentDateAsPeriodID = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
    
    for period in periods {
        
        let startID = Int(period.startDateID)
        
        
        // If the period is not in the past, do it. After all, there is no need to add a paycheck to a past budget period.
        
        if !(period.endDateID < currentDateAsPeriodID) {
            
            // Future
            if startID > currentDateAsPeriodID {
                
                available = 0
                
                // Present
            } else if currentDateAsPeriodID > period.startDateID && currentDateAsPeriodID < period.endDateID {
                
                available = amount
                
            }
            
            createAndSaveNewBudgetItem(periodStartID: startID, type: paycheckKey, named: named, budgeted: amount, available: available, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
            
            guard let currentUnallocated = loadUnallocatedItem(startID: startID) else { return }
            
            updateUnallocatedItemBudgetedAndAvailable(currentUnallocatedItem: currentUnallocated, budgeted: amount, available: available, type: paycheckKey)
            
            updatePeriodBalance(startID: startID, amount: amount, type: paycheckKey)
            
            updatePeriodUnallocated(startID: startID, amount: amount, type: paycheckKey)
            
        }
        
    }
    
    saveData()
    
}



// New Category: Adds a newly added Category to present and future Periods.

func addCategoryAsBudgetedItemToPeriods(named: String, withBudgeted budgeted: Double, dueDay: Int) {
    
    if named != unallocatedKey {
        
        var available = Double()
        
        // Create and save new budget items based on this.
        let periods = loadSavedBudgetedTimeFrames()
        
        let currentDateAsPeriodID = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
        
        for period in periods {
            
            let startID = Int(period.startDateID)
            
            
            // If the period is not in the past, do it. After all, there is no need to add a paycheck to a past budget period.
            
            if !(period.endDateID < currentDateAsPeriodID) {
                
                // Future
                if startID > currentDateAsPeriodID {
                    
                    available = 0
                    
                    // Present
                } else if currentDateAsPeriodID > period.startDateID && currentDateAsPeriodID < period.endDateID {
                    
                    available = budgeted
                    
                }
                
                createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: named, budgeted: budgeted, available: available, category: categoryKey, year: 0, month: 0, day: dueDay, checked: true)
                
                guard let currentUnallocated = loadUnallocatedItem(startID: startID) else { return }
                
                updateUnallocatedItemBudgetedAndAvailable(currentUnallocatedItem: currentUnallocated, budgeted: budgeted, available: available, type: categoryKey)
                
                updatePeriodBalance(startID: startID, amount: budgeted, type: categoryKey)
                
                updatePeriodUnallocated(startID: startID, amount: budgeted, type: categoryKey)
                
            }
            
        }
        
        saveData()
        
    }
    
}



// *****
// MARK: - Add Paychecks and Categories to New Period.
// *****



// MARK: - New Period: Save all Categories and Paychecks into new Period (except Unallocated)

func createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: Int, endDateID: Int) {
    
    guard let currentUnallocatedItem = loadUnallocatedItem(startID: startDateID) else { return }
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    // Paychecks first (Because it makes more sense)
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        var available = Double()
        
        if startDateID > currentDateAsPeriodID {
            
            available = 0
            
        } else if startDateID < currentDateAsPeriodID {
            
            available = paycheck.amount
            
        }
        
        updateUnallocatedItemBudgetedAndAvailable(currentUnallocatedItem: currentUnallocatedItem, budgeted: paycheck.amount, available: available, type: paycheckKey)
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: available, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
        
    }
    
    
    // Categories next (Because there will already be money in there)
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        if category.name != unallocatedKey {
            
            var available = Double()
            
            // Future
            if startDateID > currentDateAsPeriodID {
                
                available = 0
                
            } else if startDateID < currentDateAsPeriodID {
                
                available = category.budgeted
                
            }
            
            updateUnallocatedItemBudgetedAndAvailable(currentUnallocatedItem: currentUnallocatedItem, budgeted: category.budgeted, available: available, type: categoryKey)
            
            createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: available, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay), checked: true)
            
        }
        
    }

    saveData()
    
}



// *****
// MARK: - Update Periods' Balance & Unallocated, and Unallocated Items
// *****



// MARK: - Updates the Period Balance for a particular Period already created.

func updatePeriodBalance(startID: Int, amount: Double, type: String) {
    
    guard let period = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
    
    period.balance += (type == paycheckKey || type == depositKey) ? amount : -amount
    
    saveData()
    
}



// MARK: - Updates the Period Unallocated amount for a particular Period already created when an amount is changed.

func updatePeriodUnallocated(startID: Int, amount: Double, type: String) {
    
    guard let period = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
    
    period.unallocated += (type == paycheckKey || type == depositKey) ? amount : -amount
    
    saveData()
    
}



// MARK: - Updates the Unallocated Item Budgeted and Available for the specified Budget Item for a particular Period.

func updateUnallocatedItemBudgetedAndAvailable(currentUnallocatedItem unallocated: BudgetItem, budgeted: Double, available: Double, type: String) {
    
    unallocated.budgeted += (type == paycheckKey || type == depositKey) ? budgeted : -budgeted
    
    unallocated.available += (type == paycheckKey || type == depositKey) ? available : -available
    
    saveData()
    
}





// MARK: - Create Current Budget Time Frame based on Month

func createCurrentTimeFrame(){
    
    let currentDate = Date()
    
    let dateDict = convertDateToInts(dateToConvert: currentDate)
    
    guard let currentMonth = dateDict[monthKey] else { return }
    guard let currentYear = dateDict[yearKey] else { return }
    
    let startDay = 1
    var endDay = Int()
    
    switch currentMonth {
        case 2: endDay = 28
        case 4, 6, 9, 11: endDay = 30
        default: endDay = 31
    }
    
    let startDate = convertComponentsToDate(year: currentYear, month: currentMonth, day: startDay)
    let endDate = convertComponentsToDate(year: currentYear, month: currentMonth, day: endDay)
    
    createAndSaveNewBudgetedTimeFrame(start: startDate, end: endDate)
    
}



// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    // 'Unallocated' always has a budgeted amount of 0.
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, dueDay: 0)
    
}



// MARK: - Create Unallocated Category

func createUnallocatedBudgetItem(startID: Int){
    
    // 'Unallocated' always has a budgeted amount of 0.
    createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: unallocatedKey, budgeted: 0.0, available: 0.0, category: categoryKey, year: 0, month: 0, day: 0, checked: false)
    
}














