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
    
    budgetedTimeFrameToSave.unallocated = calculatePeriodUnallocated(startDateID: startDateID)
    
    saveData()
    
}



func calculateInitialUnallocatedAmountsForNewPeriod(startID: Int, amount: Double) {
    
    guard let unallocatedItem = loadSpecificBudgetItem(startID: startID, named: unallocatedKey, type: categoryKey) else { return }
    
    unallocatedItem.budgeted = amount
    unallocatedItem.available = amount
    
}



func calculatePeriodBalance(startDateID: Int) -> Double {
    
    var balance = Double()
    
    let items = loadSpecificBudgetItems(startID: Int(startDateID))
    
    for item in items {
        
        if item.type == paycheckKey || item.type == depositKey {
            
            balance += item.budgeted
            
        } else {
            
            balance += item.available
            
        }
        
    }
    
    return balance
    
}

func updatePeriodBalance(period: Period, amount: Double) {
    
    period.balance = amount
    
    saveData()
    
}


// ******************************************************************************************************
/*
 
 Have to create different functions for calculating the dates they are created.
 Also, set up so that the past periods have the same amount allocated as the present ones because, presumably, the past periods will have already passed (obviously), so the money will already have been allocated, and probably spent.
 The future periods need to be set up with only showing the 'budgeted' and still taken out of unallocated, as this is 'prospective', so it is counting AS IF it was already allocated.
 
 
 
 UNALLOCATED:
 
 Therefore, to calculate the 'unallocated' amount for setting up the time periods, they need to have the (income budgeted - expense budgeted), as, if it is past or present, then creation of the time frame will result in the available being the same as the budgeted, and in the future, the budgeted will be what counts as the available. So instead of making two different 'if' checks for the dates in relation to the present, we can make only one to be about the 'budgeted' amount for all items involved.
 
 ** Actually, I'll split them up and have the 'if' statements to make it more clear what is going on. So the past will be (income available - expense available)
 
 
 
 BALANCE:
 
 However, for the balance, for the past and present, it has to be (income - (item budgeted - item available)), and the future has to be (income - item budgeted).
 
 
 
 */
// ******************************************************************************************************


func calculatePeriodUnallocated(startDateID: Int) -> Double {
    
    var unallocated = Double()
    
    let items = loadSpecificBudgetItems(startID: Int(startDateID))
    
    for item in items {
        
        if item.type == categoryKey && item.name == unallocatedKey {
            
            continue
            
        } else {
            
            if item.type == paycheckKey || item.type == depositKey {
                
                unallocated += item.budgeted
                
            } else {
                
                unallocated -= item.budgeted
                
            }
            
        }
        
    }
    
    return unallocated
    
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
        
        if startDateID < currentDateAsPeriodID && endDateID > currentDateAsPeriodID {
            
            available = category.budgeted
            
        }
        
        // The 'category' property is set to its own category name.
        // The 'year' and month' properties are set to 0, as they are not used.
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: available, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay))
        
    }
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        var available = Double()
        
        if startDateID < currentDateAsPeriodID && endDateID > currentDateAsPeriodID {
            
            available = paycheck.amount
            
        }
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: available, category: unallocatedKey, year: 0, month: 0, day: 0)
        
    }
    
    saveData()
    
}



// MARK: - Save a new paycheck

func createAndSaveNewPaycheck(named: String, withAmount amount: Double) {
    
    let paycheckToSave = Paycheck(context: context)
    
    paycheckToSave.name = named
    paycheckToSave.amount = amount
    
    
    
    // Create and save new budget items based on this.
    let periods = loadSavedBudgetedTimeFrames()
    
    let currentDateIDForAddingPurposes = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
    
    for period in periods {
        
        if period.endDateID > currentDateIDForAddingPurposes {
            
            addPaycheckAsBudgetedItem(period: period, idForAdding: currentDateIDForAddingPurposes, named: named, budgeted: amount)
            
        }
        
    }
    
    
    
    saveData()
    
}

func addPaycheckAsBudgetedItem(period: Period, idForAdding: Int, named: String, budgeted: Double) {
    
    var available = Double()
    
    if idForAdding > period.endDateID {
        
        available = 0
        
    } else if idForAdding > period.startDateID && idForAdding < period.endDateID {
        
        available = budgeted
        
    }
    
    createAndSaveNewBudgetItem(periodStartID: Int(period.startDateID), type: paycheckKey, named: named, budgeted: budgeted, available: available, category: unallocatedKey, year: 0, month: 0, day: 0)
    
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
    
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, dueDay: 0)
    
}









