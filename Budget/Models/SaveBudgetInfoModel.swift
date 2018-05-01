//
//  SaveBudgetInfo.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

func saveData() {
    
    do {
        
        try context.save()
        
    } catch {
        
        print("Error saving data: \(error)")
        
    }
    
}



// MARK: - Saves a new category to saved categories
func saveNewCategory(named: String, withBudgeted budgeted: Double, andAvailable available: Double) {
    
    let categoryToSave = CategorySaved(context: context)
    
    categoryToSave.name = named
    categoryToSave.budgeted = budgeted
    categoryToSave.available = available
    
    saveData()
    
}



// MARK: - Saves a new transaction to saved transactions

func saveNewTransaction(id: Int, type: String, title: String, year: Int, month: Int, day: Int, inTheAmountOf: Double, forCategory: String) {
    
    let transactionToSave = TransactionSaved(context: context)
    
    transactionToSave.id = Int64(id)
    transactionToSave.type = type
    transactionToSave.title = title
    transactionToSave.year = Int64(year)
    transactionToSave.month = Int64(month)
    transactionToSave.day = Int64(day)
    transactionToSave.inTheAmountOf = inTheAmountOf
    transactionToSave.forCategory = forCategory
    
    saveData()
    
}



// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    saveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)
    
}



// MARK: - Update Saved Category

func updateSavedCategory(named: String, withBudgeted budgeted: Double, andAvailable available: Double) {
    
    
    
}



// MARK: - Update Saved Transaction

func updateSavedTransaction(id: Int, type: String, title: String, year: Int, month: Int, day: Int, inTheAmountOf: Double, forCategory: String) {
    
    
    
}



// MARK: - Delete Saved Category

func deleteSavedCategory(named: String) {
    
    
    
}



// MARK: - Delete Saved Transaction

func deleteSavedTransaction(withID id: Int) {
    
//    let id = Int64(id)
    
//    context.delete(<#T##object: NSManagedObject##NSManagedObject#>)
    
}












func saveCategories() {
    
    let convertedCategories = convertCategories(from: budget.categories)
    
    UserDefaults.standard.set(convertedCategories, forKey: categoryKey)
    
}

func saveTransactions() {
    
    let convertedTransactions = convertTransactions(from: budget.transactions)
    
    UserDefaults.standard.set(convertedTransactions, forKey: transactionKey)
    
}


func saveEverything() {
    saveTransactions()
    saveCategories()
}














