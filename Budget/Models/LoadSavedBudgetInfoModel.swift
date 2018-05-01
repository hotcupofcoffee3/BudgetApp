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


// MARK: - Load from CoreData

var categoryArray = [CategorySaved]()
var transactionArray = [TransactionSaved]()



// MARK: - Load All Categories

func loadSavedCategories() {
    
    let request: NSFetchRequest<CategorySaved> = CategorySaved.fetchRequest()
    
    do {
        
        categoryArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading categories: \(error)")
        
    }
    
}


// MARK: - Load All Transactions

func loadSavedTransactions() {
    
    let request: NSFetchRequest<TransactionSaved> = TransactionSaved.fetchRequest()
    
    request.sortDescriptors = [NSSortDescriptor(key: idKey, ascending: false)]
    
    do {
        
        transactionArray = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
}



// MARK: - Load Specific Category

func loadSpecificCategory(named: String) -> String? {
    
    var categoryName: String?
    
    var matchingCategory = [CategorySaved]()
    
    let request: NSFetchRequest<CategorySaved> = CategorySaved.fetchRequest()
    
    let predicate = NSPredicate(format: nameMatchesKey, named)
    
    request.predicate = predicate
    
    do {
        
        matchingCategory = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    if matchingCategory.count > 1 {
        
        print("Error. There were \(matchingCategory.count) entries that matched that category name.")
        categoryName = nil
        
    } else if matchingCategory.count == 0 {
        
        print("There was nothing in the array")
        categoryName = nil
        
    } else if matchingCategory.count == 1 {
        
        categoryName = matchingCategory[0].name
        
    }
    
    return categoryName
    
}



// MARK: - Load Specific Transaction

func loadSpecificTransaction(idSubmitted: Int) -> Int? {
    
    var convertedTransactionId: Int?
    
    var matchingTransaction = [TransactionSaved]()
    
    let id = Int64(idSubmitted)
    
    let request: NSFetchRequest<TransactionSaved> = TransactionSaved.fetchRequest()
    
    let predicate = NSPredicate(format: idMatchesKey, id)
    
    request.predicate = predicate
    
    do {
        
        matchingTransaction = try context.fetch(request)
        
    } catch {
        
        print("Error loading transactions: \(error)")
        
    }
    
    if matchingTransaction.count > 1 {
        
        print("Error. There were \(matchingTransaction.count) entries that matched that id.")
        convertedTransactionId = nil
        
    } else if matchingTransaction.count == 0 {
        
        print("There was nothing in the array")
        convertedTransactionId = nil
        
    } else if matchingTransaction.count == 1 {
        
        let transactionId = matchingTransaction[0].id
        
        convertedTransactionId = Int(transactionId)
        
    }
    
    return convertedTransactionId
    
}


















func loadCategories() {
    
//    UserDefaults.standard.set(nil, forKey: categoryKey)
    
    let savedObject = UserDefaults.standard.object(forKey: categoryKey)
    
    if savedObject == nil {
        let defaultCategory = [unallocatedKey: Category(name: unallocatedKey, budgeted: 0.0)]
        let convertedCategories = convertCategories(from: defaultCategory)
        UserDefaults.standard.set(convertedCategories, forKey: categoryKey)
    } else {
        guard let savedCategories = savedObject as? [String: [String: Double]] else { return }
        budget.categories = convertCategories(from: savedCategories)
    }
    
    budget.updateBalance()
    
}

func loadTransactions() {
    
//    UserDefaults.standard.set(nil, forKey: transactionKey)
    
    let savedObject = UserDefaults.standard.object(forKey: transactionKey)
    
    if savedObject == nil {
        UserDefaults.standard.set([String: [String: String]](), forKey: transactionKey)
    } else {
        guard let savedTransactions = savedObject as? [String: [String: String]] else { return }
        budget.transactions = convertTransactions(from: savedTransactions)
    }
    
    budget.sortTransactionsDescending()
    
}












