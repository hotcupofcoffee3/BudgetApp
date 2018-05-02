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



// MARK: - Context created
let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext



// MARK: - Saves everything
func saveData() {
    
    do {
        
        try context.save()
        
    } catch {
        
        print("Error saving data: \(error)")
        
    }
    
    budget.updateBalance()
    
}



// MARK: - Saves a new category to saved categories
func createAndSaveNewCategory(named: String, withBudgeted budgeted: Double, andAvailable available: Double) {
    
    let categoryToSave = Category(context: context)
    
    categoryToSave.name = named
    categoryToSave.budgeted = budgeted
    categoryToSave.available = available
    
    saveData()
    
}



// MARK: - Saves a new transaction to saved transactions

func createAndSaveNewTransaction(id: Int64, type: String, title: String, year: Int64, month: Int64, day: Int64, inTheAmountOf: Double, forCategory: String) {
    
    let transactionToSave = Transaction(context: context)
    
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



// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)
    
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







