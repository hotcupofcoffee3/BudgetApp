//
//  LoadSavedBudgetInfo.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation

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












