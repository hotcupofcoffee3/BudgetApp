//
//  SaveBudgetInfo.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

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
