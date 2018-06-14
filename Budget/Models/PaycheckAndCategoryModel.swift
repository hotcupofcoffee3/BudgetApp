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
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    // Create and save new budget items based on this.
    let periods = loadSavedBudgetedTimeFrames()
    
    for period in periods {
        
        let startID = Int(period.startDateID)
        let endID = Int(period.endDateID)
        
        // Add Paycheck to present and future Periods
        if !(endID < currentDateAsPeriodID) {
           
            createPaycheckBudgetItem(startID: startID, named: named, amount: amount)
            
            updateUnallocatedItem(startID: startID, type: paycheckKey)
            
            updatePeriodBalance(startID: startID)
            
        }
        
    }
    
    saveData()
    
}



// New Category: Adds a newly added Category to present and future Periods.

func addCategoryAsBudgetedItemToPeriods(named: String, withBudgeted budgeted: Double, dueDay: Int) {
    
    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
    
    if named != unallocatedKey {
        
        // Create and save new budget items based on this.
        let periods = loadSavedBudgetedTimeFrames()
        
        for period in periods {
            
            let startID = Int(period.startDateID)
            let endID = Int(period.endDateID)
            
            // Add Category to present and future Periods
            if !(endID < currentDateAsPeriodID) {
                
                createCategoryBudgetItem(startID: startID, named: named, budgeted: budgeted, dueDay: dueDay)
                
                updateUnallocatedItem(startID: startID, type: categoryKey)
                
                // ***** TODO: - Make a function like "updateUnallocatedItem()" that updates all categories for the future based on the previous item's available.
                
                updatePeriodBalance(startID: startID)
                
            }

        }
        
        
        
        saveData()
        
    }
    
}



// *****
// MARK: - Loadables
// *****

func loadSavedPaychecks() {
    
    let request: NSFetchRequest<Paycheck> = Paycheck.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: amountKey, ascending: false)]
    
    do {
        
        budget.paychecks = try context.fetch(request)
        
    } catch {
        
        print("Could not load paychecks.")
        
    }
    
}

// Load Specific Paycheck

func loadSpecificPaycheck(named: String) -> Paycheck? {
    
    var paycheck: Paycheck?
    
    var matchingPaycheck = [Paycheck]()
    
    let request: NSFetchRequest<Paycheck> = Paycheck.fetchRequest()
    
    let predicate = NSPredicate(format: nameMatchesKey, named)
    
    request.predicate = predicate
    
    do {
        
        matchingPaycheck = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    if matchingPaycheck.count > 1 {
        
        print("Error. There were \(matchingPaycheck.count) entries that matched that category name.")
        paycheck = nil
        
    } else if matchingPaycheck.count == 0 {
        
        print("There was no Specific Paycheck in the array")
        paycheck = nil
        
    } else if matchingPaycheck.count == 1 {
        
        paycheck = matchingPaycheck[0]
        
    }
    
    return paycheck
    
}



// Load All Categories

func loadSavedCategories() {
    
    let request: NSFetchRequest<Category> = Category.fetchRequest()
    
    do {
        
        budget.categories = try context.fetch(request)
        
    } catch {
        
        print("Error loading categories: \(error)")
        
    }
    
}


// Load Specific Category

func loadSpecificCategory(named: String) -> Category? {
    
    var category: Category?
    
    var matchingCategory = [Category]()
    
    let request: NSFetchRequest<Category> = Category.fetchRequest()
    
    let predicate = NSPredicate(format: nameMatchesKey, named)
    
    request.predicate = predicate
    
    do {
        
        matchingCategory = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    if matchingCategory.count > 1 {
        
        print("Error. There were \(matchingCategory.count) entries that matched that category name.")
        category = nil
        
    } else if matchingCategory.count == 0 {
        
        print("There was no Specific Category in the array")
        category = nil
        
    } else if matchingCategory.count == 1 {
        
        category = matchingCategory[0]
        
    }
    
    return category
    
}




// *****
// MARK: - Deletions
// *****



// MARK: - Delete Category Item

func deleteCategoryItem(forItem item: BudgetItem, andUnallocatedItem unallocated: BudgetItem) {
    
    // Add Category Item Budgeted to Unallocated Item Budgeted.
    unallocated.budgeted += item.budgeted
     
    // Add Category Item Available to Unallocated Item Available.
    unallocated.available += item.available
     
    // Change Category in Transactions to Unallocated.
    
    
    // Delete Category Item.
    context.delete(item)
    
    saveData()
    
}



// MARK: - Delete Paycheck Item

func deletePaycheckItem(forItem item: BudgetItem, andUnallocatedItem unallocated: BudgetItem) {
    
    // Remove Paycheck Item Budgeted from Unallocated Item Budgeted.
    unallocated.budgeted -= item.budgeted
    
    // Remove Paycheck Item Available to Unallocated Item Available.
    unallocated.available -= item.available
    
    // Change Category in Transactions to Unallocated.
    
    saveData()
    
}

















