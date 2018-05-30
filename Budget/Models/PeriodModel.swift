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
    updateAllSpecificBudgetItemAvailableForFuturePeriods(startID: startID, named: unallocatedKey, type: categoryKey)
    
    
    // Calculate new Period's balance with balance of previous Period.
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



// MARK: - New Period: Save all Categories and Paychecks into new Period (except Unallocated)

func createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: Int, endDateID: Int) {
    
    guard let currentUnallocatedItem = loadUnallocatedItem(startID: startDateID) else { return }
    
    // Paychecks first (Because it makes more sense)
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: paycheck.amount, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
        
        updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocatedItem, budgeted: paycheck.amount, type: paycheckKey)
        
    }
    
    
    // Categories next (Because there will already be money in there)
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        if category.name != unallocatedKey {
            
            let available = calculateInitialCurrentItemAvailableFromPreviousPeriodItemAvailable(currentStartID: startDateID, named: category.name!, type: categoryKey, budgeted: category.budgeted)
            
            createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: available, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay), checked: true)
            
            updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocatedItem, budgeted: category.budgeted, type: categoryKey)
            
            updateAllSpecificBudgetItemAvailableForFuturePeriods(startID: startDateID, named: category.name!, type: categoryKey)
            
        }
        
    }
    
    saveData()
    
}













