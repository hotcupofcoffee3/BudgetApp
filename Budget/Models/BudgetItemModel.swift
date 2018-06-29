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
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// MARK: - Update Budget Item Per Adding a Transaction

func updateBudgetItemPerAddingTransaction(item: BudgetItem, amount: Double, type: String) {
    
    if type == depositKey {
        
        item.available += amount
        
    } else {
        
        item.available -= amount
        
    }
    
    saveData()
    
}



func updateFutureUnallocatedItems(startID: Int, amount: Double, type: String) {
    
    let unallocatedItems = loadAllSpecificBudgetItemsAcrossPeriods(named: unallocatedKey, type: categoryKey)
    
    for item in unallocatedItems {
        
        // Only Periods AFTER the one that the Budget Item was added to.
        if item.periodStartID > startID {
            
            item.available += (type == withdrawalKey) ? -amount : amount
            
        }
        
    }
    
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
    
    if !budgetItemArray.isEmpty {
        
        if let unallocated = loadSpecificBudgetItem(startID: startID, named: unallocatedKey, type: categoryKey) {
            
            unallocatedArray.append(unallocated)
            
        }
        
    }
    
    budgetItemArray = unallocatedArray + budgetItemArray
    
    return budgetItemArray
    
}



// Load Period within which a Transaction exists

func loadPeriodIDsWithinWhichATransactionExists(transactionID: Int) -> (start: Int, end: Int) {
    
    var startID = Int()
    
    var endID = Int()
    
    let periods = loadSavedBudgetedTimeFrames()
    
    for period in periods {
        
        if transactionID > period.startDateID && transactionID < period.endDateID {
            
            startID = Int(period.startDateID)
            
            endID = Int(period.endDateID)
            
        }
        
    }
    
    return (startID, endID)
    
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
        
        matchingItemArray = try context.fetch(request)
        
        
    } catch {
        
        print("Error loading selected budget item: \(error)")
        
    }
    
    if matchingItemArray.count > 1 {
        
        print("Error. There were \(matchingItemArray.count) entries that matched that start date.")
        item = nil
        
    } else if matchingItemArray.count == 0 {
        
        print("There was no Specific Budget Item in the array")
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



// MARK: - Updates the Unallocated Item Budgeted and Available for a particular Period.

func updateUnallocatedItem(startID: Int, type: String) {
    
    guard let unallocated = loadUnallocatedItem(startID: startID) else { return }
    
    // Current Paychecks minus Categories amount
    let currentAmountOfPaychecksMinusCategories = calculatePaycheckMinusCategoryAmounts(startID: startID)
    
    // Previous Unallocated Item to be used for the previous 'Available'
    if let previousUnallocatedItem = loadSpecificBudgetItemFromPreviousPeriod(currentStartID: startID, named: unallocatedKey, type: categoryKey) {
        
        // Both the Previous 'Available' and the current amounts 'Available' AFTER the new Item has been added.
        unallocated.available = previousUnallocatedItem.available + currentAmountOfPaychecksMinusCategories
        
    } else {
        
        // Only changes the available of Unallocated for the specific item being added, instead of calculating everything from scratch, as there is no previous to add to calculate, so the total only changes based by the 'amountBudgeted'.
        unallocated.available = currentAmountOfPaychecksMinusCategories
        
    }
    
    unallocated.budgeted = currentAmountOfPaychecksMinusCategories
   
    saveData()
    
}



// MARK: - Updates the Unallocated Item Budgeted and Available for the specified Budget Item for a new Period.

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



// MARK: - Updates the Unallocated For Deleting a Paycheck.

func updateUnallocatedItemWithDeletingAPaycheck(paycheckItem: BudgetItem, unallocatedItem: BudgetItem) {
    
    let startID = Int(paycheckItem.periodStartID)
    
    let allPeriodItems = loadSpecificBudgetItems(startID: startID)
    
    if let previousUnallocated = loadSpecificBudgetItemFromPreviousPeriod(currentStartID: startID, named: unallocatedKey, type: categoryKey) {
        
        unallocatedItem.available = previousUnallocated.available
        
    } else {
        
        unallocatedItem.available = 0.0
        
    }
    
    unallocatedItem.budgeted = 0.0
    
    for item in allPeriodItems {
        
        if item.name != unallocatedKey && !(item.name == paycheckItem.name && item.type == paycheckKey){
            
            unallocatedItem.budgeted += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
            
            unallocatedItem.available += (item.type == paycheckKey) ? item.budgeted : -item.budgeted
            
        }
        
    }
   
    saveData()
    
}



// MARK: - Delete Budget Item From Core Data

func deleteBudgetItemFromCoreData(item: BudgetItem) {
    
    context.delete(item)
    
    saveData()
    
}



// MARK: - Update Future Unallocated Per Deletion of a Specific Period's Budget Item.

func updateFutureUnallocatedPerBudgetItemDeletion(amount: Double, type: String) {
    
    let futurePeriods = loadFutureTimeFrames()
    
    if !futurePeriods.isEmpty {
        
        for period in futurePeriods {
            
            guard let unallocated = loadUnallocatedItem(startID: Int(period.startDateID)) else { return }
            
            unallocated.available += (type == withdrawalKey) ? amount : -amount
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Update Current Category from which the Budget Item came.

func updateUnallocatedItemWhenAddingBudgetItem(startID: Int, type: String, amount: Double) {
    
    guard let unallocatedItem = loadSpecificBudgetItem(startID: startID, named: unallocatedKey, type: categoryKey) else { return }
    
    unallocatedItem.available += (type == withdrawalKey) ? -amount : amount
    unallocatedItem.budgeted += (type == withdrawalKey) ? -amount : amount

    saveData()
    
}



// MARK: - Deletion of a Budget Item (a specific one created for a specific Period).

func deleteBudgetItem(item: BudgetItem) {
    
    let amount = item.available
    guard let type = item.type else { return }
    
    // Update Unallocted Item based on type.
    // The negative amount is added, so it does the opposite of when the Budget Item was added.
    updateUnallocatedItemWhenAddingBudgetItem(startID: Int(item.periodStartID), type: type, amount: -amount)
    
    updateFutureUnallocatedPerBudgetItemDeletion(amount: amount, type: type)
    
    deleteBudgetItemFromCoreData(item: item)
    
    updateAllPeriodsBalances()
   
    //    - Delete Transaction corresponding to Budget Item.
    
}



// MARK: - Updates all future instances of all Budget Items for all Future Periods (except Unallocated).

func updateAvailableForAllBudgetItemsForFuturePeriods(startID: Int) {
    
    // All Current Budget Items
    let currentItems = loadSpecificBudgetItems(startID: startID)
    
    for currentItem in currentItems {
        
        // All specific items based on each Budget Item in the current Period.
        let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
        
        // If the period is NOT the last period in the array.
        if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
            
            // For each specific budget item of a particular kind...
            for item in specificItems {
                
                if item.name != unallocatedKey {
                    
                    // All future instances
                    if item.periodStartID > currentItem.periodStartID {
                        
                        // Add the current item's 'budgeted' amount to the future item's 'available' amount for categories, otherwise add 0 for Paychecks (They don't accumulate amounts).
                        item.available += (currentItem.type == categoryKey) ? currentItem.budgeted : 0
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Updates all future Budget Items per Deletion.

func updateAvailableForAllFutureBudgetItemsPerPeriodDeletion(startID: Int) {
    
    // All Current Budget Items
    let currentItems = loadSpecificBudgetItems(startID: startID)
    
    for currentItem in currentItems {
        
        // All specific items based on each Budget Item in the current Period.
        let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
        
        // If the period is NOT the last period in the array.
        if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
            
            // For each specific budget item of a particular kind...
            for item in specificItems {
                
                if item.name != unallocatedKey {
                    
                    // All future instances
                    if item.periodStartID > currentItem.periodStartID {
                        
                        // Add the current item's 'budgeted' amount to the future item's 'available' amount for categories, otherwise add 0 for Paychecks (They don't accumulate amounts).
                        item.available -= (currentItem.type == categoryKey) ? currentItem.budgeted : 0
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    saveData()
    
}



// MARK: - Updates all future instances of a specific Budget Item for all Future Periods upon CREATION of a Period or Budget Item.

func updateAvailableForASpecificBudgetItemForFuturePeriods(startID: Int, named: String, type: String, amountFromTransaction: Double?, transactionType: String?, isAddingTransaction: Bool) {
    
    guard let currentItem = loadSpecificBudgetItem(startID: startID, named: named, type: type) else { return }
    
    let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
    
    // If the period is NOT the last period in the array.
    if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
        
        for item in specificItems {
            
            // All future instances
            if item.periodStartID > currentItem.periodStartID {
                
                // If the amount from the transaction is set, then it is a transaction being added, and not a Period or Budget Item being added.
                if amountFromTransaction != nil {
                    
                    guard let amount = amountFromTransaction else { return }
                    
                    if isAddingTransaction {
                        
                        item.available += (transactionType == withdrawalKey) ? -amount : amount
                        
                    } else {
                        
                        item.available += (transactionType == withdrawalKey) ? amount: -amount
                        
                    }

                // If no transaction amount set, then a Period or Budget Item is being added, so no transaction checking is needed.
                } else {
                    
                    item.available += (type == categoryKey || type == withdrawalKey) ? currentItem.budgeted : 0
                    //                print(item.name!)
                    //                print(item.periodStartID)
                    //                print(item.available)
                    
                }

            }
            
        }
        
    }
    
    
    
    saveData()
    
}



// MARK: - Updates all future instances of a specific Budget Item for all Future Periods Per Deletion.

func updateAvailableForASpecificBudgetItemForFuturePeriodsPerDeletion(startID: Int, named: String, type: String) {
    
    guard let currentItem = loadSpecificBudgetItem(startID: startID, named: named, type: type) else { return }
    
    let specificItems = loadAllSpecificBudgetItemsAcrossPeriods(named: currentItem.name!, type: currentItem.type!)
    
    // If the period is NOT the last period in the array.
    if !(currentItem.periodStartID == specificItems[specificItems.count - 1].periodStartID) {
        
        for item in specificItems {
            
            // All future instances
            if item.periodStartID > currentItem.periodStartID {
                
                item.available -= (type == categoryKey || type == withdrawalKey) ? currentItem.budgeted : 0
                
            }
            
        }
        
    }
    
    saveData()
    
}























