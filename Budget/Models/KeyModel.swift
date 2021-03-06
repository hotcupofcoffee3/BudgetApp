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
let nameDoesNotMatchKey = "!name MATCHES %@"
let typeMatchesKey = "type MATCHES %@"
let idMatchesKey = "id MATCHES %@"
let categoryMatchesKey = "forCategory MATCHES %@"
let startDateIDMatchesKey = "startDateID MATCHES %@"
let idAsDateEarlierThanKey = "id <= %@"
let idAsDateLaterThanKey = "id >= %@"
let periodStartIDMatchesKey = "periodStartID MATCHES %@"
let periodStartIDKey = "periodStartID"


// Class keys
let categoryKey = "Category"
let transactionKey = "Transaction"
let paycheckKey = "Paycheck"
let depositKey = "Deposit"
let withdrawalKey = "Withdrawal"


// Category Keys
let nameKey = "name"
let budgetedKey = "budgeted"
let availableKey = "available"
let unallocatedKey = "Unallocated"


// Transaction Keys
let idKey = "id"
let typeKey = "type"
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


// Startup Keys
let isSetUpKey = "isSetUp"


// Budget Item Keys
let categoryTypeKey = "category"


// Color Keys
let successColor = UIColor.init(red: 100/255, green: 158/255, blue: 55/255, alpha: 1)
let tealColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 1)
let lightGreenColor = UIColor.init(red: 198/255, green: 221/255, blue: 129/255, alpha: 1)
let fadedLightGreenColor = UIColor.init(red: 198/255, green: 221/255, blue: 129/255, alpha: 0.7)
let fadedWhiteColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)



// MARK: - Segue Keys

// Opening to others

let openingToMainSegueKey = "openingToMainSegue"
let openingToWelcomeSegueKey = "openingToWelcomeSegue"


// Welcome to others
let welcomeToAddPeriodSegueKey = "welcomeToAddPeriodSegue"


// Main to others
let mainToBudgetSegueKey = "mainToBudgetSegue"
let mainToPaycheckSegueKey = "mainToPaycheckSegue"
let mainToCategoriesSegueKey = "mainToCategoriesSegue"


// Budget to others
let budgetToAddOrEditBudgetSegueKey = "budgetToAddOrEditBudgetSegue"
let budgetToBudgetItemsSegueKey = "budgetToBudgetItemsSegue"


// Budget Items to others
let budgetItemsToAddOrEditBudgetItemSegueKey = "budgetItemsToAddOrEditBudgetItemSegue"
let addOrEditBudgetItemToDatePickerSegueKey = "addOrEditBudgetItemToDatePickerSegue"
let budgetItemsToTransactionsSegueKey = "budgetItemsToTransactionsSegue"


// Paycheck to others
let paychecksToAddOrEditPaycheckSegueKey = "paychecksToAddOrEditPaycheckSegue"
let addOrEditPaycheckToDatePickerSegueKey = "addOrEditPaycheckToDatePickerSegue"


// Categories to others
let categoriesToAddOrEditCategorySegueKey = "categoriesToAddOrEditCategorySegue"
let categoriesToAddOrEditTransactionSegueKey = "categoriesToAddOrEditTransactionSegue"
let categoriesToTransactionsSegueKey = "categoriesToTransactionsSegue"


// Transactions to others
let transactionsToAddOrEditCategorySegueKey = "transactionsToAddOrEditCategorySegue"
let transactionsToAddOrEditTransactionSegueKey = "transactionsToAddOrEditTransactionSegue"
let transactionsToMoveFundsSegueKey = "transactionsToMoveFundsSegue"
let transactionsToCategoriesSegueKey = "transactionsToCategoriesSegue"


// Date Picker Segues
let addOrEditCategoryToDatePickerSegueKey = "addOrEditCategoryToDatePickerSegue"
let addOrEditTransactionToDatePickerSegueKey = "addOrEditTransactionToDatePickerSegue"
let addOrEditBudgetToDatePickerSegueKey = "addOrEditBudgetToDatePickerSegue"


// Category Picker Segues
let moveFundsToCategoryPickerSegueKey = "moveFundsToCategoryPickerSegue"
let addOrEditTransactionToCategoryPickerSegueKey = "addOrEditTransactionToCategoryPickerSegue"
let addOrEditCategoryToCategoryPickerSegueKey = "addOrEditCategoryToCategoryPickerSegue"


// Paycheck Picker Segues
let addOrEditTransactionToPaycheckPickerSegueKey = "addOrEditTransactionToPaycheckPickerSegue"














