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
let mainToBudgetSegueKey = "MainToBudgetSegue"
let mainToCategoriesSegueKey = "MainToCategoriesSegue"
let mainToTransactionsSegueKey = "MainToTransactionsSegue"

let mainToAddCategorySegueKey = "MainToAddCategorySegue"
let mainToAddTransactionSegueKey = "MainToAddTransactionSegue"
let mainToAddDepositSegueKey = "MainToAddDepositSegue"
let mainToMoveFundsSegueKey = "MainToMoveFundsSegue"


// Categories to others
let categoriesToAddCategorySegueKey = "CategoriesToAddCategorySegue"
let categoriesToAddTransactionSegueKey = "CategoriesToAddTransactionSegue"
let categoriesToAddDepositSegueKey = "CategoriesToAddDepositSegue"
let categoriesToMoveFundsSegueKey = "CategoriesToMoveFundsSegue"
let categoriesToTransactionsSegueKey = "CategoriesToTransactionsSegue"


// Transactions to others
let transactionsToAddCategorySegueKey = "TransactionsToAddCategorySegue"
let transactionsToAddTransactionSegueKey = "TransactionsToAddTransactionSegue"
let transactionsToAddDepositSegueKey = "TransactionsToAddDepositSegue"
let transactionsToMoveFundsSegueKey = "TransactionsToMoveFundsSegue"
let transactionsToCategoriesSegueKey = "TransactionsToCategoriesSegue"


// Date & Category Picker Segues
let addCategoryToDatePickerSegueKey = "AddCategoryToDatePickerSegue"
let addTransactionToDatePickerSegueKey = "AddTransactionToDatePickerSegue"
let addTransactionToCategoryPickerSegueKey = "AddTransactionToCategoryPickerSegue"
let moveFundsToCategoryPickerSegueKey = "MoveFundsToCategoryPickerSegue"
let editCategoryAvailableToCategoryPickerSegueKey = "EditCategoryAvailableToCategoryPickerSegue"
let editCategoryToDatePickerSegueKey = "EditCategoryToDatePickerSegue"
let changeTransactionDateToDatePickerSegueKey = "ChangeTransactionDateToDatePickerSegue"
let changeTransactionCategoryToCategoryPickerSegueKey = "ChangeTransactionCategoryToCategoryPickerSegue"


// Category Picker Segues


// Budget to others
let budgetToTransactionsSegueKey = "BudgetToTransactionsSegue"


// Edit Segues

let editTransactionSegueKey = "EditTransactionSegue"
let editTransactionTitleSegueKey = "EditTransactionTitleSegue"
let editTransactionAmountSegueKey = "EditTransactionAmountSegue"
let editTransactionDateSegueKey = "EditTransactionDateSegue"
let editTransactionCategorySegueKey = "EditTransactionCategorySegue"

let editCategorySegueKey = "EditCategorySegue"
let editCategoryNameSegueKey = "EditCategoryNameSegue"
let editCategoryBudgetedSegueKey = "EditCategoryBudgetedSegue"
let editCategoryAvailableSegueKey = "EditCategoryAvailableSegue"














