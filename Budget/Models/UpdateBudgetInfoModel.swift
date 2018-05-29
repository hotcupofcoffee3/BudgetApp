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
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    for item in items {
        
        if item.name != unallocatedKey {
            
            if startID > currentDateAsPeriodID {
                
                period.balance += (item.type == depositKey || item.type == paycheckKey) ? item.budgeted : -item.budgeted
                
            } else {
                
                period.balance += (item.type == depositKey || item.type == paycheckKey) ? item.available : -item.available
                
            }
            
        }
        
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

func updateUnallocatedWhenAddingItem(currentUnallocatedItem unallocated: BudgetItem, budgeted: Double, available: Double, type: String) {
    
    unallocated.budgeted += (type == paycheckKey || type == depositKey) ? budgeted : -budgeted
    
    unallocated.available += (type == paycheckKey || type == depositKey) ? available : -available
    
    saveData()
    
}



// *****
// MARK: - Update Available for Future Items
// *****

// MARK: - Updates all future instances of a specific Budget Item for all Periods.

func updateAllSpecificBudgetItemAvailableForFuturePeriods(currentItem: BudgetItem) {
    
    guard let name = currentItem.name else { return }
    guard let type = currentItem.type else { return }
    
    let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: name, type: type)
    
    // If the period is NOT the last period in the array.
    if !(currentItem.periodStartID > specificItems[specificItems.count - 2].periodStartID) {
        
        for item in specificItems {
            
            if item.periodStartID > currentItem.periodStartID {
                
                if item != currentItem {
                    
                    item.available += (type == paycheckKey || type == depositKey) ? currentItem.available : -currentItem.available
                    
                }
                
            }
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Updates the 'Available' amount for all instances of a specific Budget Item for all future Periods.

func updateAllBudgetItemsAvailableForFuturePeriods(currentStartID: Int) {
    
    let periods = loadSavedBudgetedTimeFrames()
    
    // If the current period is NOT the last period in the array.
    if !(currentStartID > periods[periods.count - 2].startDateID) {
        
        let currentItems = loadSpecificBudgetItems(startID: currentStartID)
        
        for item in currentItems {
            
            updateAllSpecificBudgetItemAvailableForFuturePeriods(currentItem: item)
            
        }
        
    }
    
    saveData()
    
}















