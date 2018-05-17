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



// MARK: - Save everything

func saveData() {
    
    do {
        
        try context.save()
        
    } catch {
        
        print("Error saving data: \(error)")
        
    }
    
    budget.updateBalance()
    
}



// MARK: - Save a new category to saved categories

func createAndSaveNewCategory(named: String, withBudgeted budgeted: Double, andAvailable available: Double) {
    
    let categoryToSave = Category(context: context)
    
    categoryToSave.name = named
    categoryToSave.budgeted = budgeted
    categoryToSave.available = available
    
    saveData()
    
}



// MARK: - Save a new transaction to saved transactions

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



// MARK: - Save a new Budgeted Time Frame

func createAndSaveNewBudgetedTimeFrame(start: Date, end: Date) {
    
    let startDict = convertDateToInts(dateToConvert: start)
    let endDict = convertDateToInts(dateToConvert: end)
    
    let startDateID = convertedDateToBudgetedTimeFrameID(timeFrame: start, isEnd: false)
    let endDateID = convertedDateToBudgetedTimeFrameID(timeFrame: end, isEnd: true)
    
    let budgetedTimeFrameToSave = Period(context: context)
    
    if let startYear = startDict[yearKey], let startMonth = startDict[monthKey], let startDay = startDict[dayKey], let endYear = endDict[yearKey], let endMonth = endDict[monthKey], let endDay = endDict[dayKey] {
        
        budgetedTimeFrameToSave.startYear = Int64(startYear)
        budgetedTimeFrameToSave.startMonth = Int64(startMonth)
        budgetedTimeFrameToSave.startDay = Int64(startDay)
        budgetedTimeFrameToSave.endYear = Int64(endYear)
        budgetedTimeFrameToSave.endMonth = Int64(endMonth)
        budgetedTimeFrameToSave.endDay = Int64(endDay)
        
        budgetedTimeFrameToSave.startDateID = Int64(startDateID)
        budgetedTimeFrameToSave.endDateID = Int64(endDateID)
        
    }
    
    saveData()
    
}



// MARK: - Save a new budget item

func createAndSaveNewBudgetItem(timeSpanID: Int, type: String, named: String, amount: Double, category: String, year: Int, month: Int, day: Int) {
    
    let itemToSave = BudgetItem(context: context)
    
    itemToSave.timeSpanID = Int64(timeSpanID)
    itemToSave.type = type
    itemToSave.name = named
    itemToSave.amount = amount
    itemToSave.category = category
    itemToSave.year = Int64(year)
    itemToSave.month = Int64(month)
    
    // The 'day' is the set due day, NOT the date from the 'timeSpanID'
    itemToSave.day = Int64(day)
    
    saveData()
    
}



// MARK: - Save all Categories into newly created Budgeted Time Frame

func createAndSaveNewSetOfBudgetItemsWithCategories(startDateID: Int) {
    
    loadSavedCategories()
    
    for category in budget.categories {
        
        if category.name == unallocatedKey {
            
            continue
            
        }
        
        // The 'type' is currently set to "category" until a property for having a 'paycheck' as a category (a depositable category) is added. Nothing is done with it right now, other than simply serving as a placeholder.
        // The 'category' property is set to its own category name.
        // The 'year' and month' properties are set to 0, as they are not used.
        createAndSaveNewBudgetItem(timeSpanID: startDateID, type: categoryKey, named: category.name!, amount: category.budgeted, category: category.name!, year: 0, month: 0, day: Int(category.dueDay))
        
    }
    
    
    
    saveData()
    
}




// MARK: - Save a new paycheck

func createAndSaveNewPaycheck(named: String, withAmount amount: Double) {
    
    let paycheckToSave = Paycheck(context: context)
    
    paycheckToSave.name = named
    paycheckToSave.amount = amount
    
    saveData()
    
}







// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, andAvailable: 0.0)
    
}









