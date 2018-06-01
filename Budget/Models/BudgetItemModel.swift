//
//  BudgetItemModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - Save a new unallocated item

func createAndSaveNewUnallocatedItem(periodStartID: Int, budgeted: Double, available: Double, year: Int, month: Int, day: Int) {
    
    let itemToSave = BudgetItem(context: context)
    
    itemToSave.periodStartID = Int64(periodStartID)
    itemToSave.type = categoryKey
    itemToSave.name = unallocatedKey
    itemToSave.budgeted = budgeted
    itemToSave.available = available
    itemToSave.category = categoryKey
    itemToSave.year = Int64(year)
    itemToSave.month = Int64(month)
    itemToSave.checked = true
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// MARK: - Save a new budget item

func createAndSaveNewBudgetItem(periodStartID: Int, type: String, named: String, budgeted: Double, available: Double, category: String, year: Int, month: Int, day: Int, checked: Bool) {
    
    let itemToSave = BudgetItem(context: context)
    
    itemToSave.periodStartID = Int64(periodStartID)
    itemToSave.type = type
    itemToSave.name = named
    itemToSave.budgeted = budgeted
    itemToSave.available = available
    itemToSave.category = category
    itemToSave.year = Int64(year)
    itemToSave.month = Int64(month)
    itemToSave.checked = checked
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// *****
// MARK: - Loadables
// *****



// Load Specific Budget Items Based on StartID

func loadSpecificBudgetItems(startID: Int) -> [BudgetItem] {
    
    var budgetItemArray = [BudgetItem]()
    
    var unallocatedArray = [BudgetItem]()
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    let startIDPredicate = NSPredicate(format: periodStartIDMatchesKey, String(startID))
    
    let withoutUnallocatedPredicate = NSPredicate(format: nameDoesNotMatchKey, unallocatedKey)
    
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startIDPredicate, withoutUnallocatedPredicate])
    
    let sortByDay: NSSortDescriptor = NSSortDescriptor(key: dayKey, ascending: true)
    
    let sortByName: NSSortDescriptor = NSSortDescriptor(key: nameKey, ascending: true)
    
    request.sortDescriptors = [sortByDay, sortByName]
    
    do {
        
        budgetItemArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading selected budget items: \(error)")
        
    }
    
    if let unallocated = loadSpecificBudgetItem(startID: startID, named: unallocatedKey, type: categoryKey) {
        
        unallocatedArray.append(unallocated)
        
    }
    
    budgetItemArray = unallocatedArray + budgetItemArray
    
    return budgetItemArray
    
}



// Load Specific Budget Item Based on StartID, Name, and Type

func loadSpecificBudgetItem(startID: Int, named: String, type: String) -> BudgetItem? {
    
    var item: BudgetItem?
    
    var matchingItemArray = [BudgetItem]()
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    let startIDPredicate = NSPredicate(format: periodStartIDMatchesKey, String(startID))
    
    let namedPredicate = NSPredicate(format: nameMatchesKey, named)
    
    let typePredicate = NSPredicate(format: typeMatchesKey, type)

    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namedPredicate, startIDPredicate, typePredicate])
   
    do {
//        print("Fart4")
        matchingItemArray = try context.fetch(request)
//        print("Fart5")
        
    } catch {
        
        print("Error loading selected budget item: \(error)")
        
    }
    
    if matchingItemArray.count > 1 {
        
        print("Error. There were \(matchingItemArray.count) entries that matched that start date.")
        item = nil
        
    } else if matchingItemArray.count == 0 {
        
        print("There was nothing in the array")
        item = nil
        
    } else if matchingItemArray.count == 1 {
        
        item = matchingItemArray[0]
        
    }
    
    return item
    
}



// Load Specific Budget Items Across Periods

func loadAllSpecificBudgetItemsAcrossPeriods(named: String, type: String) -> [BudgetItem] {
    
    var specificBudgetItemArray = [BudgetItem]()
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    let namePredicate = NSPredicate(format: nameMatchesKey, named)
    
    let typePredicate = NSPredicate(format: typeMatchesKey, type)
    
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, typePredicate])
    
    let sortAscending: NSSortDescriptor = NSSortDescriptor(key: periodStartIDKey, ascending: true)
    
    request.sortDescriptors = [sortAscending]
    
    do {
        
        specificBudgetItemArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading selected budget items: \(error)")
        
    }
    
    return specificBudgetItemArray
    
}



// Load Unallocated Item

func loadUnallocatedItem(startID: Int) -> BudgetItem? {
    
    var unallocated: BudgetItem?
    
    if let unallocatedItem = loadSpecificBudgetItem(startID: startID, named: unallocatedKey, type: categoryKey) {
        
        unallocated = unallocatedItem
        
    }
    
    return unallocated
    
}



// Load All Budget Items Based on StartID (Just to make sure it's all working properly.

func loadSavedBudgetItems() {
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    do {
        
        budget.budgetItems = try context.fetch(request)
        
    } catch {
        
        print("Fuck you; you suck: \(error)")
        
    }
    
}



// *****
// MARK: - Updates
// *****

// Update Budget Item Per Checkage

func updateItemAndBalancePerCheckage(startID: Int, named: String, type: String) {
    
    print(startID)
    print(named)
    print(type)
    
//    guard let itemChecked = loadSpecificBudgetItem(startID: startID, named: named, type: type) else { return }
//    
//    // Either positive or negative to be added to the running total, depending on how the item.
//    var amountToChangeBy = Double()
//    
//    // If it was checked, but isn't anymore
//    if !itemChecked.checked {
//
//        // Amount taken away if a paycheck, added back if it was a withdrawal
//        amountToChangeBy = (itemChecked.type == paycheckKey || itemChecked.type == depositKey) ? -itemChecked.budgeted : itemChecked.budgeted
//
//        // If it wasn't checked, but now it is.
//    } else {
//
//        // Amount added if a paycheck, taken away if it was a withdrawal
//        amountToChangeBy = (itemChecked.type == paycheckKey || itemChecked.type == depositKey) ? itemChecked.budgeted : -itemChecked.budgeted
//
//    }
//
//    let startID = Int(itemChecked.periodStartID)
//    print("Anus45")
//
//    // Update current item's available if the budgeted amount is not being considered.
//    itemChecked.available += amountToChangeBy
//
//    let isNewlyChecked = itemChecked.checked
//
//    
//     // Updates current Unallocated
//    updateUnallocatedItem(startID: startID, amountBudgeted: abs(amountToChangeBy), type: type)
//   
//     // Update all future items of this Category or Paycheck to reflect the fact that this one is not being allocated the budgeted funds.
//    updateAvailableForAllSpecificBudgetItemsForFuturePeriodsPerCheckage(startID: startID, named: named, type: type, isNewlyChecked: isNewlyChecked)
//    
//    // Update all period balances to reflect this new change.
//    updateAllPeriodsBalances()
    
    saveData()
    
}

// MARK: - Updates the Unallocated Item Budgeted and Available for the specified Budget Item for a particular Period.

func updateUnallocatedItem(startID: Int, amountBudgeted: Double, type: String) {
    
    guard let unallocated = loadUnallocatedItem(startID: startID) else { return }
  
    unallocated.budgeted += (type == paycheckKey) ? amountBudgeted : -amountBudgeted
    
    unallocated.available += (type == paycheckKey) ? amountBudgeted : -amountBudgeted
    
    saveData()
    
}

// MARK: - Updates the Unallocated Item Budgeted and Available for the specified Budget Item for a particular Period.

func updateUnallocatedItemWithAddedCategoriesAndPaychecks(startID: Int) {
   
    guard let unallocated = loadUnallocatedItem(startID: startID) else { return }
    
    let newPeriodItems = loadSpecificBudgetItems(startID: startID)
    
    for item in newPeriodItems {
        
        if item.name != unallocatedKey {
            
            unallocated.budgeted += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
            
            unallocated.available += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Updates all future instances of a specific Budget Item for all Periods with New Period Create.

func updateAvailableForAllBudgetItemsForFuturePeriodsPerCreation(startID: Int) {
    
    let currentItems = loadSpecificBudgetItems(startID: startID)
    
    for currentItem in currentItems {
        
        let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
        
        // If the period is NOT the last period in the array.
        if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
            
            for item in specificItems {
                
                // All future instances
                if item.periodStartID > currentItem.periodStartID {
                    
                    item.available += (currentItem.type == categoryKey || currentItem.type == withdrawalKey) ? currentItem.budgeted : 0
                    
                }
                
            }
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Updates all future instances of a specific Budget Item for all Periods.

func updateAvailableForAllSpecificABudgetItemForFuturePeriodsPerCreation(startID: Int, named: String, type: String) {
    
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



// MARK: - Updates all future instances of a specific Budget Item for all Periods.

func updateAvailableForAllSpecificBudgetItemsForFuturePeriodsPerCheckage(startID: Int, named: String, type: String, isNewlyChecked: Bool) {
    
    guard let currentItem = loadSpecificBudgetItem(startID: startID, named: named, type: type) else { return }
    
    let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
    
    // If the period is NOT the last period in the array.
    if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
        
        for item in specificItems {
            
            // All future instances
            if item.periodStartID > currentItem.periodStartID {
                
                let amount = isNewlyChecked ? currentItem.budgeted : -currentItem.budgeted
                
                item.available += amount
                
                updateUnallocatedItem(startID: Int(item.periodStartID), amountBudgeted: amount, type: type)
                
            }
            
        }
        
    }
    
    saveData()
    
}






















