//
//  KeyModel.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import Foundation
import UIKit

let budgetedKey = "Budgeted"
let availableKey = "Available"
let categoryKey = "Category"
let transactionKey = "Transaction"
let uncategorizedKey = "Uncategorized"

let doubleFormatKey = "%0.2f"

let titleKey = "Title"
let yearKey = "Year"
let monthKey = "Month"
let dayKey = "Day"
let amountKey = "Amount"

var typeKey = "Type"
let depositKey = "Deposit"
let withdrawalKey = "Withdrawal"

// Other universal variables
let successColor = UIColor.init(red: 100/255, green: 158/255, blue: 55/255, alpha: 1)

// Main to others
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

// Transactions to others
let transactionsToAddCategorySegueKey = "TransactionsToAddCategorySegue"
let transactionsToAddTransactionSegueKey = "TransactionsToAddTransactionSegue"
let transactionsToAddDepositSegueKey = "TransactionsToAddDepositSegue"
let transactionsToMoveFundsSegueKey = "TransactionsToMoveFundsSegue"

// Edit Segues

let editCategorySegueKey = "EditCategorySegue"
let editTransactionSegueKey = "EditTransactionSegue"














