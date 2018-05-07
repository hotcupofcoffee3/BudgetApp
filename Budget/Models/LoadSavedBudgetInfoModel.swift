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



// MARK: - Load All Categories

func loadSavedCategories() {
    
    let request: NSFetchRequest<Category> = Category.fetchRequest()
    
    do {
        
        budget.categories = try context.fetch(request)
        
    } catch {
        
        print("Error loading categories: \(error)")
        
    }
    
}



// MARK: - Load All Transactions

func loadSavedTransactions(descending: Bool) {
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: !descending)]
    
    do {
        
        budget.transactions = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
}



// MARK: - Load All BudgetedTimeFrames

func loadSavedBudgetedTimeFrames() {
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: startKey, ascending: false)]
    
    do {
        
        budget.budgetedTimeFrames = try context.fetch(request)
        
    } catch {
        
        print("Error loading budgeted time frames: \(error)")
        
    }
    
}



// MARK: - Load Specific Category

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



// MARK: - Load Specific Transaction

func loadSpecificTransaction(idSubmitted: Int) -> Transaction? {
    
    var transaction: Transaction?
    
    var matchingTransactionArray = [Transaction]()
    
    let id = Int64(idSubmitted)
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    request.predicate = NSPredicate(format: idMatchesKey, id)
    
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



// MARK: - Load Transactions By Category

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



// MARK: - Load Transactions By Date

func loadTransactionsByDate(selectedStartDate: Date, selectedEndDate: Date) -> [Transaction] {
    
    var transactionsInDateRange = [Transaction]()
    
    let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
    
    let startDate = NSPredicate(format: dateLaterThanKey, selectedStartDate as CVarArg)

    let endDate = NSPredicate(format: dateEarlierThanKey, selectedEndDate as CVarArg)

    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [startDate, endDate])
    
    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: false)]
    
    do {
        
        transactionsInDateRange = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions in date range: \(error)")
        
    }
    
    return transactionsInDateRange
    
}



// MARK: - Load Specific Budgeted Time Frame

func loadSpecificBudgetedTimeFrame(start: Date) -> Period? {
    
    var period: Period?
    
    var matchingTimeFrameArray = [Period]()
    
    let request: NSFetchRequest<Period> = Period.fetchRequest()
    
    request.predicate = NSPredicate(format: startMatchesKey, start as CVarArg)
    
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

















