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














