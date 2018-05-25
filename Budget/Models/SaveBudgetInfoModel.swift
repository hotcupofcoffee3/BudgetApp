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



// MARK: - Save a new category to saved categories

func createAndSaveNewCategory(named: String, withBudgeted budgeted: Double, dueDay: Int) {
    
    let categoryToSave = Category(context: context)
    
    categoryToSave.name = named
    categoryToSave.budgeted = budgeted
    categoryToSave.dueDay = Int64(dueDay)
    
    saveData()
    
}



// MARK: - Save a new transaction to saved transactions

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

    createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: startDateID, endDateID: endDateID)
    
    guard let currentUnallocatedItem = loadSpecificBudgetItem(startID: startDateID, named: unallocatedKey, type: categoryKey) else { return }
    
    let items = loadSpecificBudgetItems(startID: startDateID)
    
    currentUnallocatedItem.budgeted = calculateInitialUnallocatedForNewPeriod(startID: startDateID, throughItems: items)
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    if !(startDateID > currentDateAsPeriodID) {
        
        currentUnallocatedItem.available = currentUnallocatedItem.budgeted
        
    }
    
    budgetedTimeFrameToSave.unallocated = currentUnallocatedItem.budgeted

    budgetedTimeFrameToSave.balance = calculateInitialPeriodBalance(startDateID: startDateID, throughItems: items)

    saveData()
    
}



func calculateInitialUnallocatedForNewPeriod(startID: Int, throughItems items: [BudgetItem]) -> Double {
    
    var amount = Double()
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    for item in items {
        
        if item.name != unallocatedKey {
        
            // Future
            
            if startID > currentDateAsPeriodID {

                amount += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
                
            // Past and Present
                
            } else {
            
                amount += (item.type == paycheckKey) ? item.available : -item.available
                
            }
            
        }

    }
    
    return amount

}



func calculateInitialPeriodBalance(startDateID: Int, throughItems items: [BudgetItem]) -> Double {
    
    var balance = Double()
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    for item in items {
        
        // Future accounts for budgeted amounts, not available, because they have not been allocated yet.
        // The paychecks added to go 'Unallocated', and then get subtracted from there based on the 'budgeted' amount of the categories. So the balance of 'Unallocated' will reflect the total deposits less the budgeted amounts of the other categories. So, simply adding all 'budgeted' for 'categories' for the future will result in the correct balance.
        // This is just for the initial balance.
        
        if startDateID > currentDateAsPeriodID {
            
            if item.name != unallocatedKey {
                
                if item.type == paycheckKey {
                    
                    balance += item.budgeted
                    
                } else if item.type == categoryKey {
                    
                    balance -= item.budgeted
                    
                }
                
            }
            
        } else {
            
            // This is just for creating the INITIAL balance, NOT the running total, which uses a different formula
            
            if item.type == paycheckKey {
                
                balance += item.available
                
            } else if item.type == categoryKey {
                
                if item.name != unallocatedKey {
                    
                    balance -= item.available
                    
                }
                
            }
            
        }
        
    }
    
    return balance
    
}


// *****
// USE THIS TO CALCULATE THE RUNNING TOTAL, INSTEAD OF IT BEING INSIDE OF THE VC FOR THE BUDGET ITEMS
// *****

func updatePeriodBalance(period: Period, amount: Double) {
    
    period.balance = amount
    
    saveData()
    
}



// MARK: - Save a new budget item

func createAndSaveNewBudgetItem(periodStartID: Int, type: String, named: String, budgeted: Double, available: Double, category: String, year: Int, month: Int, day: Int) {
    
    let itemToSave = BudgetItem(context: context)
    
    itemToSave.periodStartID = Int64(periodStartID)
    itemToSave.type = type
    itemToSave.name = named
    itemToSave.budgeted = budgeted
    itemToSave.available = available
    itemToSave.category = category
    itemToSave.year = Int64(year)
    itemToSave.month = Int64(month)
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// MARK: - Save all Categories into newly created Budgeted Time Frame

func createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: Int, endDateID: Int) {
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        var available = Double()
        
        if !(startDateID > currentDateAsPeriodID) {
            
            available = category.budgeted
            
        }
        
        // The 'category' property is set to its own category name.
        // The 'year' and month' properties are set to 0, as they are not used.
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: available, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay))
        
    }
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        var available = Double()
        
        if !(startDateID > currentDateAsPeriodID) {
            
            available = paycheck.amount
            
        }
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: available, category: unallocatedKey, year: 0, month: 0, day: 0)
        
    }
    
    guard let unallocatedItem = loadSpecificBudgetItem(startID: startDateID, named: unallocatedKey, type: categoryKey) else { return }
    
    unallocatedItem.checked = false
    
    saveData()
    
}



// MARK: - Save a new paycheck

func createAndSaveNewPaycheck(named: String, withAmount amount: Double) {
    
    let paycheckToSave = Paycheck(context: context)
    
    paycheckToSave.name = named
    paycheckToSave.amount = amount
    
    addPaycheckAsBudgetedItemToPeriods(named: named, budgeted: amount)
    
    saveData()
    
}



// *************************************************************************************************



// TODO: - FILL OUT THESE FUNCTIONS



// *************************************************************************************************



func updatePeriodBalanceAndUnallocated(startID: Int, amount: Double) {
    
    
    
}



func updateUnallocatedItemsForPeriod(startID: Int, amount: Double) {
    
    
    
}



func addPaycheckAsBudgetedItemToPeriods(named: String, budgeted: Double) {
    
    var available = Double()
    
    // Create and save new budget items based on this.
    let periods = loadSavedBudgetedTimeFrames()
    
    let currentDateAsPeriodID = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
    
    for period in periods {
        
        if period.startDateID > currentDateAsPeriodID {
            
            available = 0
            
            period.balance += budgeted
            period.unallocated += budgeted
            
            guard let unallocatedItem = loadSpecificBudgetItem(startID: Int(period.startDateID), named: unallocatedKey, type: categoryKey) else { return }
            unallocatedItem.budgeted += budgeted
            
        } else if currentDateAsPeriodID > period.startDateID && currentDateAsPeriodID < period.endDateID {
            
            available = budgeted
            
        }
        
        createAndSaveNewBudgetItem(periodStartID: Int(period.startDateID), type: paycheckKey, named: named, budgeted: budgeted, available: available, category: unallocatedKey, year: 0, month: 0, day: 0)
        
    }
    
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









