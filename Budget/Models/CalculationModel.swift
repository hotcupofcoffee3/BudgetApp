//
//  CalculationModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData



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
        
        balanceOfItems += (item.type == categoryKey) ? item.budgeted : 0
        
    }
    
    return balanceOfItems
    
}



// MARK: - Calculate Period Balance from ONLY Categories and Paychecks (excluding Unallocated)
// Also serves to calculate isolated 'Unallocated' amount.

func calculatePaycheckMinusCategoryAmounts(startID: Int) -> Double {
    
    let items = loadSpecificBudgetItems(startID: startID)
    
    var balanceOfItems = Double()
    
    if !items.isEmpty {
        
        for item in items {
            
            if item.name != unallocatedKey {
                
                balanceOfItems += (item.type == paycheckKey || item.type == depositKey) ? item.budgeted : -item.budgeted
                
            }
            
        }
        
    }
    

    return balanceOfItems
    
}



// MARK: - Calculate new Period's Budget Item with Budget Item of previous Period.

func calculateInitialItemAvailableFromPreviousPeriod(currentStartID: Int, named: String, type: String, budgeted: Double) -> Double {
    
    // Start off with the budgeted amount, as that is the default 'available' that is added.
    var available = budgeted
    
    if let previousPeriod = loadPreviousPeriod(currentStartID: currentStartID) {
        
        if let previousItem = loadSpecificBudgetItem(startID: Int(previousPeriod.startDateID), named: named, type: type) {
            
            available += previousItem.available
            
        }
        
    }
    
    return available
    
}














