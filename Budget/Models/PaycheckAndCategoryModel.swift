//
//  PaycheckAndCategoryModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



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



// New Paycheck: Adds a newly added Paycheck to present and future Periods.

func addPaycheckAsBudgetedItemToPeriods(named: String, amount: Double) {
    
    // Create and save new budget items based on this.
    let periods = loadSavedBudgetedTimeFrames()
    
    for period in periods {
        
        let startID = Int(period.startDateID)
        
        createAndSaveNewBudgetItem(periodStartID: startID, type: paycheckKey, named: named, budgeted: amount, available: amount, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
        
        
        
        // BELOW: - Update all Periods' balances AFTER the Period created with the new Period's calculated balance.
        
        // BELOW: - Update all Periods' budget items AFTER the Period created with the new Period's calculated budget items.
        
        
        
        guard let currentUnallocated = loadUnallocatedItem(startID: startID) else { return }
        
        updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocated, budgeted: amount, available: amount, type: paycheckKey)
        
        updatePeriodBalanceWhenAddingItem(startID: startID, amount: amount, type: paycheckKey)
        
    }
    
    saveData()
    
}



// New Category: Adds a newly added Category to present and future Periods.

func addCategoryAsBudgetedItemToPeriods(named: String, withBudgeted budgeted: Double, dueDay: Int) {
    
    if named != unallocatedKey {
        
        // Create and save new budget items based on this.
        let periods = loadSavedBudgetedTimeFrames()
        
        for period in periods {
            
            let startID = Int(period.startDateID)
            
            createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: named, budgeted: budgeted, available: budgeted, category: categoryKey, year: 0, month: 0, day: dueDay, checked: true)
            
            
            // BELOW: - Update all Periods' balances AFTER the Period created with the new Period's calculated balance.
            
            // BELOW: - Update all Periods' budget items AFTER the Period created with the new Period's calculated budget items.
            
            
            
            guard let currentUnallocated = loadUnallocatedItem(startID: startID) else { return }
            
            updateUnallocatedWhenAddingItem(currentUnallocatedItem: currentUnallocated, budgeted: budgeted, available: budgeted, type: categoryKey)
            
            updatePeriodBalanceWhenAddingItem(startID: startID, amount: budgeted, type: categoryKey)
            
        }
        
        saveData()
        
    }
    
}
















