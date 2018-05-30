//
//  PeriodModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



func addNewPeriod(start: Date, end: Date) {
    
    let startID = convertDateToBudgetedTimeFrameID(timeFrame: start, isEnd: false)
    let endID = convertDateToBudgetedTimeFrameID(timeFrame: end, isEnd: true)
    
    
    // Create new Period
    createAndSaveNewBudgetedTimeFrame(start: start, end: end)
    
    
    // Create Unallocated Item for new Period, with previous 'available' added
    createUnallocatedBudgetItem(startID: startID)
    
    
    // Create all Category and Paycheck Items for new Period, with previous 'available' added.
    // Unallocated is also updated in here
    createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: startID, endDateID: endID)
    
    
    // Update Unallocated for new Period after all Categories and Paychecks have been added.
    updateAvailableForAllSpecificBudgetItemsForFuturePeriodsPerItemCreation(startID: startID, named: unallocatedKey, type: categoryKey)
    
    
    // Update new Period's balance with balance of previous Period.
    guard let newlyCreatedPeriod = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
    
    newlyCreatedPeriod.balance = calculateNewPeriodStartingBalance(startID: startID)
    
    saveData()
    
}




// MARK: - Save a new Budgeted Time Frame

func createAndSaveNewBudgetedTimeFrame(start: Date, end: Date) {
    
    // Add date info to create Period
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

    saveData()
    
}



// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    // 'Unallocated' always has a budgeted amount of 0.
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, dueDay: 0)
    
}



// MARK: - New Period: Save all Categories and Paychecks into new Period (except Unallocated)

func createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: Int, endDateID: Int) {
    
    // Paychecks first (Because it makes more sense)
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: paycheck.amount, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
        
        updateUnallocatedItem(startID: startDateID, amountBudgeted: paycheck.amount, type: paycheckKey)
        
    }
    
    
    // Categories next (Because there will already be money in there)
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        if category.name != unallocatedKey {
            
            let available = calculateInitialCurrentItemAvailableFromPreviousPeriodItemAvailable(currentStartID: startDateID, named: category.name!, type: categoryKey, budgeted: category.budgeted)
            
            createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: available, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay), checked: true)
            
            updateUnallocatedItem(startID: startDateID, amountBudgeted: category.budgeted, type: categoryKey)
            
            updateAvailableForAllSpecificBudgetItemsForFuturePeriodsPerItemCreation(startID: startDateID, named: category.name!, type: categoryKey)
            
        }
        
    }
    
    saveData()
    
}



// *****
// MARK: - Loadables
// *****


// Load All Budgeted Time Frames

func loadSavedBudgetedTimeFrames() -> [Period] {
    
    var periods = [Period]()
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: startDateIDKey, ascending: true)]
    
    do {
        
        periods = try context.fetch(request)
        
    } catch {
        
        print("Error loading budgeted time frames: \(error)")
        
    }
    
    return periods
    
}

// Load and Sort Budgeted Time Frames

func loadAndSortBudgetedTimeFrames() -> [Period] {
    
    let periods = loadSavedBudgetedTimeFrames()
    
    var allPeriods = [Period]()
    
    var pastPeriods = [Period]()
    var presentPeriod: Period?
    var futurePeriods = [Period]()
    
    let currentDateAsPeriodID = convertDateToDateAddedForGeneralPurposes(dateAdded: Date())
    
    for period in periods {
        
        if period.endDateID < currentDateAsPeriodID {
            
            pastPeriods.append(period)
            
        } else if period.startDateID < currentDateAsPeriodID && period.endDateID > currentDateAsPeriodID {
            
            presentPeriod = period
            
        } else if period.startDateID > currentDateAsPeriodID {
            
            futurePeriods.append(period)
            
        }
        
    }
    
    if let presentPeriod = presentPeriod {
        allPeriods.append(presentPeriod)
    }
    
    allPeriods.append(contentsOf: futurePeriods)
    allPeriods.append(contentsOf: pastPeriods)
    
    return allPeriods
    
}



// Load Specific Budgeted Time Frame

func loadSpecificBudgetedTimeFrame(startID: Int) -> Period? {
    
    var period: Period?
    
    var matchingTimeFrameArray = [Period]()
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.predicate = NSPredicate(format: startDateIDMatchesKey, String(startID))
    
    do {
        
        matchingTimeFrameArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading selected budgeted time frames: \(error)")
        
    }
    
    if matchingTimeFrameArray.count > 1 {
        
        print("Error. There were \(matchingTimeFrameArray.count) entries that matched that start date.")
        period = nil
        
    } else if matchingTimeFrameArray.count == 0 {
        
        print("There was nothing in the array")
        period = nil
        
    } else if matchingTimeFrameArray.count == 1 {
        
        period = matchingTimeFrameArray[0]
        
    }
    
    return period
    
}


// MARK: - Load Previous Period

func loadPreviousPeriod(currentStartID: Int) -> Period? {
    
    let periods = loadSavedBudgetedTimeFrames()
    
    var previousPeriods = [Period]()
    
    var previousPeriod: Period?
    
    for period in periods {
        
        if period.endDateID < currentStartID {
            
            previousPeriods.append(period)
            
        }
        
    }
    
    if !previousPeriods.isEmpty {
        
        previousPeriod = previousPeriods[(previousPeriods.count - 1)]
        
    } else {
        
        previousPeriod = nil
        
    }
    
    
    return previousPeriod
    
}


// MARK: - Load Previous Period's Specified Budget Item

func loadSpecificBudgetItemFromPreviousPeriod(currentStartID: Int, named: String, type: String) -> BudgetItem? {
    
    var previousBudgetItem: BudgetItem?
    
    if let previousPeriod = loadPreviousPeriod(currentStartID: currentStartID) {
        
        if let previousItem = loadSpecificBudgetItem(startID: Int(previousPeriod.startDateID), named: named, type: type) {
            
            previousBudgetItem = previousItem
            
        }
        
    }
    
    return previousBudgetItem
    
}



// MARK: - Load Previous Period's Balance

func loadPreviousPeriodBalance(startID: Int) -> Double {
    
    let previousPeriod = loadPreviousPeriod(currentStartID: startID)
    
    let previousPeriodBalance = (previousPeriod != nil) ? previousPeriod!.balance : 0
    
    return previousPeriodBalance
    
}



// *****
// MARK: - Updates
// *****



// Mark: - Updates specific Periods' balance by adding together all of the categories and paychecks (without unallocated).

func updatePeriodBalance(startID: Int) {
    
    let items = loadSpecificBudgetItems(startID: startID)
    
    guard let period = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
    
    period.balance = 0
    
    for item in items {
        
        period.balance += (item.type == categoryKey || item.type == withdrawalKey) ? item.available : 0
        
    }
    
    saveData()
    
}



// Mark: - Updates all Periods' balances.

func updateAllPeriodsBalances() {
    
    let allPeriods = loadSavedBudgetedTimeFrames()
    
    for period in allPeriods {
        
        updatePeriodBalance(startID: Int(period.startDateID))
        
    }
    
    saveData()
    
}



// MARK: - Updates a Period's balance when adding an item.

func updatePeriodBalanceWhenAddingItem(startID: Int, amount: Double, type: String) {
    
    guard let period = loadSpecificBudgetedTimeFrame(startID: startID) else { return }
    
    period.balance += (type == paycheckKey || type == depositKey) ? amount : -amount
    
    saveData()
    
}



// MARK: - Load Sorted Period Categories

func loadPeriodCategories(startID: Int) -> [String] {
    
    var sortedPeriodCategories = [String]()
    
    let periodBudgetItems = loadSpecificBudgetItems(startID: startID)
    
    for item in periodBudgetItems {
        
        if item.name != unallocatedKey && (item.type == categoryKey || item.type == withdrawalKey) {
            
            sortedPeriodCategories.append(item.name!)
            
        }
        
    }
    
    sortedPeriodCategories.sort()
    
    sortedPeriodCategories = [unallocatedKey] + sortedPeriodCategories
    
    return sortedPeriodCategories
    
}













