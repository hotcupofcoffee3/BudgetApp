//
//  KeyModel.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit

// Query Keys
let nameMatchesKey = "name MATCHES %@"
let idMatchesKey = "id MATCHES %@"
let categoryMatchesKey = "forCategory MATCHES %@"
let startDateIDMatchesKey = "startDateID MATCHES %@"
let idAsDateEarlierThanKey = "id <= %@"
let idAsDateLaterThanKey = "id >= %@"


// Class keys
let categoryKey = "Category"
let transactionKey = "Transaction"


// Category Keys
let nameKey = "name"
let budgetedKey = "budgeted"
let availableKey = "available"
let unallocatedKey = "Unallocated"


// Transaction Keys
let idKey = "id"
let typeKey = "type"
let depositKey = "deposit"
let withdrawalKey = "withdrawal"
let titleKey = "title"
let amountKey = "amount"
let inTheAmountOfKey = "inTheAmountOf"
let forCategoryKey = "forCategoryKey"
let yearKey = "year"
let monthKey = "month"
let dayKey = "day"


// Period Keys
let startDateIDKey = "startDateID"
let endDateIDKey = "endDateID"


// Color Keys
let successColor = UIColor.init(red: 100/255, green: 158/255, blue: 55/255, alpha: 1)
let tealColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 1)
let lightGreenColor = UIColor.init(red: 198/255, green: 221/255, blue: 129/255, alpha: 1)



// MARK: - Segue Keys

// Main to others
let mainToBudgetSegueKey = "mainToBudgetSegue"
let mainToCategoriesSegueKey = "mainToCategoriesSegue"
let mainToTransactionsSegueKey = "mainToTransactionsSegue"

let mainToAddCategorySegueKey = "mainToAddCategorySegue"
let mainToAddTransactionSegueKey = "mainToAddTransactionSegue"
let mainToAddDepositSegueKey = "mainToAddDepositSegue"
let mainToMoveFundsSegueKey = "mainToMoveFundsSegue"


// Categories to others
let categoriesToAddCategorySegueKey = "categoriesToAddCategorySegue"
let categoriesToAddTransactionSegueKey = "categoriesToAddTransactionSegue"
let categoriesToAddDepositSegueKey = "categoriesToAddDepositSegue"
let categoriesToMoveFundsSegueKey = "categoriesToMoveFundsSegue"
let categoriesToTransactionsSegueKey = "categoriesToTransactionsSegue"


// Transactions to others
let transactionsToAddCategorySegueKey = "transactionsToAddCategorySegue"
let transactionsToAddTransactionSegueKey = "transactionsToAddTransactionSegue"
let transactionsToAddDepositSegueKey = "transactionsToAddDepositSegue"
let transactionsToMoveFundsSegueKey = "transactionsToMoveFundsSegue"
let transactionsToCategoriesSegueKey = "transactionsToCategoriesSegue"


// Budget to others
let budgetToAddBudgetSegueKey = "budgetToAddBudgetSegue"
let budgetToCategoriesSegueKey = "budgetToCategoriesSegue"
let budgetToTimeFrameItemsSegueKey = "budgetToTimeFrameItemsSegue"
let budgetItemsToSelectItemsSegueKey = "budgetItemsToSelectItemsSegue"


// Date Picker Segues
let addCategoryToDatePickerSegueKey = "addCategoryToDatePickerSegue"
let addTransactionToDatePickerSegueKey = "addTransactionToDatePickerSegue"
let editCategoryToDatePickerSegueKey = "editCategoryToDatePickerSegue"
let changeTransactionDateToDatePickerSegueKey = "changeTransactionDateToDatePickerSegue"
let addBudgetToDatePickerSegueKey = "addBudgetToDatePickerSegue"


// Category Picker Segues
let addTransactionToCategoryPickerSegueKey = "addTransactionToCategoryPickerSegue"
let moveFundsToCategoryPickerSegueKey = "aoveFundsToCategoryPickerSegue"
let editCategoryAvailableToCategoryPickerSegueKey = "editCategoryAvailableToCategoryPickerSegue"
let changeTransactionCategoryToCategoryPickerSegueKey = "changeTransactionCategoryToCategoryPickerSegue"


// Edit Segues

let editTransactionSegueKey = "editTransactionSegue"
let editTransactionTitleSegueKey = "editTransactionTitleSegue"
let editTransactionAmountSegueKey = "editTransactionAmountSegue"
let editTransactionDateSegueKey = "editTransactionDateSegue"
let editTransactionCategorySegueKey = "editTransactionCategorySegue"

let editCategorySegueKey = "editCategorySegue"
let editCategoryNameSegueKey = "editCategoryNameSegue"
let editCategoryBudgetedSegueKey = "editCategoryBudgetedSegue"
let editCategoryAvailableSegueKey = "editCategoryAvailableSegue"














