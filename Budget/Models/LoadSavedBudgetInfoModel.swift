//
//  LoadSavedBudgetInfo.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData


// *****
// MARK: - Categories
// *****


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
        
        print("There was nothing in the array")
        category = nil
        
    } else if matchingCategory.count == 1 {
        
        category = matchingCategory[0]
        
    }
    
    return category
    
}



// *****
// MARK: - Transactions
// *****


// Load All Transactions

func loadSavedTransactions(descending: Bool) {
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: !descending)]
    
    do {
        
        budget.transactions = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
}


// Load Specific Transaction

func loadSpecificTransaction(idSubmitted: Int) -> Transaction? {
    
    var transaction: Transaction?
    
    var matchingTransactionArray = [Transaction]()
    
    let id = Int64(idSubmitted)
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    request.predicate = NSPredicate(format: idMatchesKey, String(id))
    
    do {
        
        matchingTransactionArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    if matchingTransactionArray.count > 1 {
        
        print("Error. There were \(matchingTransactionArray.count) entries that matched that id.")
        transaction = nil
        
    } else if matchingTransactionArray.count == 0 {
        
        print("There was nothing in the array")
        transaction = nil
        
    } else if matchingTransactionArray.count == 1 {
        
        transaction = matchingTransactionArray[0]
        
    }
    
    return transaction
    
}



// Load Transactions By Category

func loadTransactionsByCategory(selectedCategory: String) -> [Transaction] {
    
    var transactionsWithSelectedCategory = [Transaction]()
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    request.predicate = NSPredicate(format: categoryMatchesKey, selectedCategory)
    
    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: false)]
    
    do {
        
        transactionsWithSelectedCategory = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    return transactionsWithSelectedCategory
    
}



// Load Transactions By Date

func loadTransactionsByDate(selectedStartDate: Int, selectedEndDate: Int) -> [Transaction] {
    
    var transactionsInDateRange = [Transaction]()
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    // Start Date format is "YYYYMMDD00000", to include the same day's transactions
    let startDate = NSPredicate(format: idAsDateLaterThanKey, String(selectedStartDate))

    // End Date format is "YYYYMMDD10000", to include the same day's transactions.
    // This is the Start date with 10,000 added to it, so that it will still include up to 10,000 transactions, as their id's will be less than this 'date' format, as long as there are less than 10,000 transactions made in a single day.
    let endDate = NSPredicate(format: idAsDateEarlierThanKey, String(selectedEndDate))

    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDate, endDate])

    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: false)]
    
    do {
        
        transactionsInDateRange = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions in date range: \(error)")
        
    }
    
    return transactionsInDateRange
    
}



// *****
// MARK: - Budgeted Time Frames
// *****


// Load All Budgeted Time Frames

func loadSavedBudgetedTimeFrames() {
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: startDateIDKey, ascending: true)]
    
    do {
        
        budget.budgetedTimeFrames = try context.fetch(request)
        
    } catch {
        
        print("Error loading budgeted time frames: \(error)")
        
    }
    
}


// Load Specific Budgeted Time Frame

func loadSpecificBudgetedTimeFrame(startID: Int) -> Period? {
    
    var period: Period?
    
    var matchingTimeFrameArray = [Period]()
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.predicate = NSPredicate(format: startDateIDMatchesKey, String(startID))
    
    do {
        
        matchingTimeFrameArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading selected budgeted time frames: \(error)")
        
    }
    
    if matchingTimeFrameArray.count > 1 {
        
        print("Error. There were \(matchingTimeFrameArray.count) entries that matched that start date.")
        period = nil
        
    } else if matchingTimeFrameArray.count == 0 {
        
        print("There was nothing in the array")
        period = nil
        
    } else if matchingTimeFrameArray.count == 1 {
        
        period = matchingTimeFrameArray[0]
        
    }
    
    return period
    
}



// *****
// MARK: - Budget Items
// *****

// Load Specific Budget Items Based on StartID

func loadSpecificBudgetItems(startID: Int) {
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    request.predicate = NSPredicate(format: timeSpanIDMatchesKey, String(startID))
    
    request.sortDescriptors = [NSSortDescriptor(key: dayKey, ascending: true), NSSortDescriptor(key: nameKey, ascending: true)]
    
    do {
        
        budget.budgetItems = try context.fetch(request)
        
    } catch {
        
        print("Error loading selected budget items: \(error)")
        
    }
    
}


// Load All Budget Items Based on StartID (Just to make sure it's all working properly.

func loadAllBudgetItems() {
    
    let request: NSFetchRequest<BudgetItem> = BudgetItem.fetchRequest()
    
    do {
        
        budget.budgetItems = try context.fetch(request)
        
    } catch {
        
        print("Fuck you; you suck: \(error)")
        
    }
    
    print(budget.budgetItems.count)
    
}






// *****
// MARK: - Paychecks
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
        
        print("There was nothing in the array")
        paycheck = nil
        
    } else if matchingPaycheck.count == 1 {
        
        paycheck = matchingPaycheck[0]
        
    }
    
    return paycheck
    
}





























