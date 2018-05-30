//
//  TransactionModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// *****
// MARK: - Add Transaction to Saved Transactions
// *****

func createAndSaveNewTransaction(onHold: Bool, id: Int64, type: String, title: String, year: Int64, month: Int64, day: Int64, inTheAmountOf: Double, forCategory: String) {
    
    let transactionToSave = Transaction(context: context)
    
    transactionToSave.onHold = onHold
    transactionToSave.id = id
    transactionToSave.type = type
    transactionToSave.title = title
    transactionToSave.year = year
    transactionToSave.month = month
    transactionToSave.day = day
    transactionToSave.inTheAmountOf = inTheAmountOf
    transactionToSave.forCategory = forCategory
    
    saveData()
    
}



// *****
// MARK: - Loadables
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
