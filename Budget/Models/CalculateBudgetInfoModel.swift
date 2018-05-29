//
//  CalculateBudgetInfoModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



// *****
// *** Creating a new Period
// *****

// A. Add date info to create Period
// B. Add all Paychecks and Categories
    // In here, calculate the current and future amounts
// C. Calculate Period balance.

// 1. -> (For Loop): Calculate current items' available based on budgeted amount and ONLY THE MOST PREVIOUS available.

// 2. -> (For Loop): Update all future items' available based on current available.

// 3. -> Calculate current unallocated (previous period's unallocated + (paychecks' budgeted - categories' budgeted)).

// 4. -> (For Loop): Calculate all future unallocated based on the current available.

// 5. -> Calculate balance (All Categories' available, including 'Unallocated').



// *****
// *** Creating a new Paycheck
// *****

// A. Add info to create Item
// B. Add to every Period
    // Within here, update unallocated and balances.

// 6. -> Add new item to current and all future Periods.

// 7 (+). -> Update current and future unallocated.

// 8. -> Update current and future Period balances.



// *****
// *** Creating a new Category
// *****

// A. Add info to create Item
// B. Add to every Period
    // Within here, update unallocated and balances.

// 6. -> Add new item to current and all future Periods.

// 7 (-). -> Update current and future unallocated.

// 8. -> Update current and future Period balances.



// *****
// *** Creating a new Budget Item
// *****

// A. Add info to create Item
    // Within here, update unallocated and balances.

// 9. -> Add new item to current Period.

// 10 (-). -> Update current unallocated.

// 11. -> Update current Period balance.



// *****
// *** Checking/Unchecking (only on future ones, and only on 'Edit' screen).
// *****

// A. Toggle Check status
    // Within here, make calculations.

// 7 (-). -> Update current unallocated.

// 8. -> Update current Period balances.



// *****
// *** Shifting Funds
// *****

// A. Load items
// B. Shift funds
    // Within here, make calculations.

// 7 (-). -> Update current and future unallocated.

// 10. -> Update current and future Item's available (but doesn't show on future ones, as only the 'budgeted' shows).














// MARK: - Calculate New Period's Balance

func calculateNewPeriodStartingBalance(startID: Int) -> Double {
    
    let items = loadSpecificBudgetItems(startID: startID)
    
    var balanceOfItems = Double()
    
    for item in items {
        
        if item.name != unallocatedKey {
            
            balanceOfItems += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
            
        }
        
    }
    
    return balanceOfItems
    
}


// MARK: - Calculate new Period's budget items (including unallocated) with budget items of previous Period.

func calculateCurrentItemsWithPreviousPeriodItems(currentStartID: Int) {
    
    let currentItems = loadSpecificBudgetItems(startID: currentStartID)
    
    if let previousPeriod = loadPreviousPeriod(currentStartID: currentStartID) {
        
        let previousItems = loadSpecificBudgetItems(startID: Int(previousPeriod.startDateID))
        
        for previousItem in previousItems {
            
            for currentItem in currentItems {
                
                if previousItem.name == currentItem.name && previousItem.type == currentItem.type {
                    
                    currentItem.available += previousItem.available
                    
                }
                
            }
            
        }
        
    }
    
    saveData()
    
}
