//
//  SaveModel.swift
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
    
}

// MARK: - Create Current Budget Time Frame based on Month

func createCurrentTimeFrame(){
    
    let currentDate = Date()
    
    let dateDict = convertDateToInts(dateToConvert: currentDate)
    
    guard let currentMonth = dateDict[monthKey] else { return }
    guard let currentYear = dateDict[yearKey] else { return }
    
    let startDay = 1
    var endDay = Int()
    
    switch currentMonth {
    case 2: endDay = 28
    case 4, 6, 9, 11: endDay = 30
    default: endDay = 31
    }
    
    let startDate = convertComponentsToDate(year: currentYear, month: currentMonth, day: startDay)
    let endDate = convertComponentsToDate(year: currentYear, month: currentMonth, day: endDay)
    addNewPeriod(start: startDate, end: endDate)
    
    
}



// MARK: - Create Unallocated Item

func createUnallocatedBudgetItem(startID: Int){
    
    // Initial Available
    // Available is calculated the difference between the Paychecks & Categories available, and from previous 'unallocated'.
    var available = Double()
   
    if let previousUnallocatedItem = loadSpecificBudgetItemFromPreviousPeriod(currentStartID: startID, named: unallocatedKey, type: categoryKey) {
        
        // Available from previous, if there was one.
        available += previousUnallocatedItem.available
        
        
    }
    
    // Budgeted is calculated after the Categories and Paychecks have been created.
    createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: unallocatedKey, budgeted: 0.0, available: available, category: categoryKey, year: 0, month: 0, day: 0, checked: true)
    
}

// MARK: - Create Category Item

func createCategoryBudgetItem(startID: Int, named: String, budgeted: Double, dueDay: Int){
    
    // Initial Available
    // Available is calculated the budgeted, and from previous available.
    var available = budgeted
    
    if let previousCategoryItem = loadSpecificBudgetItemFromPreviousPeriod(currentStartID: startID, named: named, type: categoryKey) {
        
        // Available from previous, if there was one.
        available += previousCategoryItem.available
//        print("Available from Previous Category: \(available)")
        
    }

    createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: named, budgeted: budgeted, available: available, category: categoryKey, year: 0, month: 0, day: dueDay, checked: true)
    
}


// MARK: - Create Paycheck Item

func createPaycheckBudgetItem(startID: Int, named: String, amount: Double){
    
    createAndSaveNewBudgetItem(periodStartID: startID, type: paycheckKey, named: named, budgeted: amount, available: amount, category: paycheckKey, year: 0, month: 0, day: 0, checked: true)
    
}


