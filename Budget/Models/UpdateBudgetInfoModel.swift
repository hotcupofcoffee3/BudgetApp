//
//  UpdateBudgetInfoModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



// *****
// MARK: - Update Period Balance
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



// *****
// MARK: - Update Unallocated
// *****

// MARK: - Updates the Unallocated Item Budgeted and Available for the specified Budget Item for a particular Period.

func updateUnallocatedWhenAddingItem(currentUnallocatedItem unallocated: BudgetItem, budgeted: Double, type: String) {
    
    unallocated.budgeted += (type == paycheckKey || type == depositKey) ? budgeted : -budgeted
    
    unallocated.available += (type == paycheckKey || type == depositKey) ? budgeted : -budgeted
    
    saveData()
    
}



// *****
// MARK: - Update Available for Future Items
// *****

// MARK: - Updates all future instances of a specific Budget Item for all Periods.

func updateAllSpecificBudgetItemAvailableForFuturePeriods(startID: Int, named: String, type: String) {
    
    guard let currentItem = loadSpecificBudgetItem(startID: startID, named: named, type: type) else { return }
    
    let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
    
    // If the period is NOT the last period in the array.
    if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
        
        for item in specificItems {
            
            // All future instances
            if item.periodStartID > currentItem.periodStartID {
                
                item.available += (type == categoryKey || type == withdrawalKey) ? currentItem.budgeted : 0
                
            }
            
        }
        
    }
    
    saveData()
    
}














