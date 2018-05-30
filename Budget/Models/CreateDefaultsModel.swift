//
//  CreateDefaultsModel.swift
//  Budget
//
//  Created by Adam Moore on 5/29/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit
import CoreData

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



// MARK: - Create Unallocated Category

func createUnallocatedCategory(){
    
    // 'Unallocated' always has a budgeted amount of 0.
    createAndSaveNewCategory(named: unallocatedKey, withBudgeted: 0.0, dueDay: 0)
    
}



// MARK: - Create Unallocated Category

func createUnallocatedBudgetItem(startID: Int){
    
    var available = Double()
    
    if let previousUnallocatedItem = loadSpecificBudgetItemFromPreviousPeriod(currentStartID: startID, named: unallocatedKey, type: categoryKey) {
        
        available = previousUnallocatedItem.available
        
    }
    
    // Budgeted is calculated from the Paychecks and Categories.
    // Available is calculated from previous 'unallocated', and the difference between the Paychecks & Categories available.
    createAndSaveNewBudgetItem(periodStartID: startID, type: categoryKey, named: unallocatedKey, budgeted: 0.0, available: available, category: categoryKey, year: 0, month: 0, day: 0, checked: false)
    
}








