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
    
    
    
    // Calculate new Period's balance with balance of previous Period.
    
    let previousPeriodBalance = loadPreviousPeriodBalance(startID: startDateID)
    
    let balanceOfItems = calculateNewPeriodStartingBalance(startID: startDateID)
    
    budgetedTimeFrameToSave.balance = previousPeriodBalance + balanceOfItems
    
    
    // Calculate new Period's budget items (including unallocated) with budget items of previous Period.
    
    calculateCurrentItemsWithPreviousPeriodItems(currentStartID: startDateID)
    
    // BELOW: - Update all Periods' balances AFTER the Period created with the new Period's calculated balance.
    
    // BELOW: - Update all Periods' budget items AFTER the Period created with the new Period's calculated budget items.
    
    
    
    saveData()
    
}



// MARK: - New Period: Save all Categories and Paychecks into new Period (except Unallocated)

func createAndSaveNewSetOfBudgetItemsWithCategoriesAndPaychecks(startDateID: Int, endDateID: Int) {
    
    guard let currentUnallocatedItem = loadUnallocatedItem(startID: startDateID) else { return }
    
    // Paychecks first (Because it makes more sense)
    
    loadSavedPaychecks()
    
    for paycheck in budget.paychecks {
        
        updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocatedItem, budgeted: paycheck.amount, available: paycheck.amount, type: paycheckKey)
        
        createAndSaveNewBudgetItem(periodStartID: startDateID, type: paycheckKey, named: paycheck.name!, budgeted: paycheck.amount, available: paycheck.amount, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
        
    }
    
    
    // Categories next (Because there will already be money in there)
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        if category.name != unallocatedKey {
            
            updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocatedItem, budgeted: category.budgeted, available: category.budgeted, type: categoryKey)
            
            createAndSaveNewBudgetItem(periodStartID: startDateID, type: categoryKey, named: category.name!, budgeted: category.budgeted, available: category.budgeted, category: categoryKey, year: 0, month: 0, day: Int(category.dueDay), checked: true)
            
        }
        
    }
    
    saveData()
    
}













