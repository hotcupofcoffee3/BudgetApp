//
//  AddOrEditBudgetItemViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/15/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditBudgetItemViewController: UIViewController, UITextFieldDelegate, ChooseDate, ChooseCategory {

    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isNewBudgetItem = true
    
    var editableBudgetItem: BudgetItem?
    
    var editableBudgetItemName = String()
    
    var editableBudgetItemBudgeted = Double()
    
    var editableBudgetItemDueDay = Int()
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var typeOfItem: TransactionType = .withdrawal
    
    var ledgerDate = Date()
    
    var isSettingLedgerDate = false
    
    var isSettingDueDate = false
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var typeSegment: UISegmentedControl!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var dueDateView: UIView!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var addToLedgerView: UIView!
    
    @IBOutlet weak var addToLedgerSwitch: UISwitch!
    
    @IBOutlet weak var ledgerDateLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitBudgetItemButton: UIButton!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    func toggleCategoryLabelInfo(forItem: BudgetItem?) {
        
        if let item = forItem {
            
            if item.type == categoryKey {
                
                categoryLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                categoryLabel.text = categoryKey
                
            } else if item.type == paycheckKey {
                
                categoryLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                categoryLabel.text = unallocatedKey
                
            } else {
                
                categoryLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                
                if item.type != categoryKey && item.type != paycheckKey {
                    
                    categoryLabel.text = item.category!
                    
                }
                
            }
            
        }

    }
    
    func toggleTypeSegmentInfo(forItem: BudgetItem?) {
        
        if let item = forItem {
            
            if item.type == categoryKey || item.type == paycheckKey {
                
                typeSegment.isEnabled = false
                
            } else {
                
                typeSegment.selectedSegmentIndex = (item.type == withdrawalKey) ? 0 : 1
                
            }
            
        }
        
    }
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeType(_ sender: UISegmentedControl) {
        
        // TODO: Add code for locking 'Category' for 'Unallocated' if it is 'Income'
        
        
    }
    
    
    
    @IBAction func dueDateToggleSwitch(_ sender: UISwitch) {
        
        if dueDateSwitch.isOn == true {
            
            date = Date()
            
            performSegue(withIdentifier: addOrEditBudgetItemToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
            date = Date.distantPast

        }
        
    }
    
    @IBAction func addToLedgerToggleSwitch(_ sender: UISwitch) {
        
        if typeSegment.selectedSegmentIndex == 0 {
            
            typeOfItem = .withdrawal
            
        } else {
            
            typeOfItem = .deposit
            
        }
        
    }
    
    
    @IBAction func submitBudgetItem(_ sender: UIButton) {
        
        if isNewBudgetItem {
            
            submitAddBudgetItemForReview()
            
        } else {
            
            submitEditItemsForReview()
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Submissions
    // *****
    
    // ************************************************************************************************
    // ************************************************************************************************
    /*
     
     Add Or Edit Section
     
     */
    // ************************************************************************************************
    // ************************************************************************************************
    
    
    
    // **************************************
    // ***** Add Budget Item
    // **************************************
    
    // *** Submit Add Budget Item For Review
    
    func submitAddBudgetItemForReview() {
        
        guard let currentItem = editableBudgetItem else { return }
        guard let name = nameTextField.text else { return }
        guard let amount = amountTextField.text else { return }
        guard let category = categoryLabel.text else { return }
        
        var dueDate: Date?
        if dateLabel.text != "" {
            
            dueDate = date
            
        }
        
        if name == "" || amount == "" {
            
            failureWithWarning(label: warningLabel, message: "You provide both a name and an amount.")
            
            
        } else if name == unallocatedKey {
            
            failureWithWarning(label: warningLabel, message: "You can't use 'Unallocated'; that's reserved for the default category.")
            
        } else {
            
            if let amount = Double(amount) {
                
                guard let categoryBeingWithdrawnFrom = loadSpecificCategory(named: category) else { return }
                
                if (categoryBeingWithdrawnFrom.budgeted - amount) < 0 && currentItem.type == withdrawalKey {
                    
                    failureWithWarning(label: warningLabel, message: "You don't have enough funds budgeted in this category.")
                    
                } else if amount <= 0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                    
                } else {
                    
                    addBudgetItemSubmission(newItemName: name, with: amount, toCategory: category, withDueDate: dueDate)
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
            }
            
        }
        
    }
    
    
    
    // *** Add Budget Item Submission
    
    func addBudgetItemSubmission(newItemName name: String, with amount: Double, toCategory categoryName: String, withDueDate: Date?) {
        
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        var year = Int()
        var month = Int()
        var day = Int()
        
        if let dueDateSet = withDueDate {
            
            let dueDateDict = convertDateToInts(dateToConvert: dueDateSet)
            
            guard let setYear = dueDateDict[yearKey] else { return }
            guard let setMonth = dueDateDict[monthKey] else { return }
            guard let setDay = dueDateDict[dayKey] else { return }
            
            year = setYear
            month = setMonth
            day = setDay
            
        }
        
        let type = (typeOfItem == .withdrawal) ? withdrawalKey : depositKey
        
        createAndSaveNewBudgetItem(timeSpanID: selectedBudgetTimeFrameStartID, type: type, named: name, amount: amount, category: categoryName, year: year, month: month, day: day)
        
        // TODO: Add function to add a transaction to the ledger based on the info here.
        // TODO: Also change 'createAndSaveNewBudgetItem' to include the 'addedToLedger' and 'checked' items, so that they can be manually set here.
        // TODO: Also change the function for updating and added a Paycheck, Category, and Other Item in the 'BudgetModel' so that they can take all of the 'BudgetItem' properties to be manually set.
        
        saveData()
        
        warningLabel.textColor = successColor
        warningLabel.text = "\"\(name)\" with an amount of \(convertedAmountToDollars(amount: amount)) has been added."
        
        successHaptic()
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        
    }
    
    
    
    
    
    
    // **************************************
    // ***** Edit Budget Item
    // **************************************
    
    
    
    // *** Submit Edit Items For Review
    
    func submitEditItemsForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
    }
    
    // *** Edit Name Check
    
    func submitEditNameForReview() {
        
        if let newBudgetItemName = nameTextField.text {
            
            // *** Is the new category name equal to "Unallocated"?
            if newBudgetItemName == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // *** Go to Budgeted Amount Check
                
                submitEditCategoryForReview()
                
            }
            
        }
        
    }
    
    
    
    // ***** Edit Category
    
    func submitEditCategoryForReview() {
        
        guard let currentBudgetItem = editableBudgetItem else { return }
        
        guard let newSelectedCategoryName = categoryLabel.text else { return }
        
        if currentBudgetItem.type != paycheckKey {
            
            guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
            
            if currentBudgetItem.amount > newCategoryItself.budgeted && currentBudgetItem.type == withdrawalKey {
                
                failureWithWarning(label: warningLabel, message: "There are not enough funds budgeted in that category for this.")
                
                
            } else {
                
                submitEditAmountForReview()
                
            }
            
        } else {
            
            submitEditAmountForReview()
            
        }
        
    }
    
    
    
    // *** Edit Budgeted Check
    
    func submitEditAmountForReview() {
        
        guard let currentItem = editableBudgetItem else { return }
        
        if let newAmount = amountTextField.text {
            
            var newAmountDouble = Double()
            
            // *** Is the field empty?
            if newAmount == ""  {
                
                failureWithWarning(label: warningLabel, message: "You can't leave the budgeted amount empty.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newAmount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number.")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // Sets 'newAmountDouble' to the number entered in the 'amountTextField'.
                if let newAmountDoubleConfirmed = Double(newAmount) {
                
                    newAmountDouble = newAmountDoubleConfirmed
                
                }
                
                guard let categoryName = categoryLabel.text else { return }
                guard let currentCategory = loadSpecificCategory(named: categoryName) else { return }
                  
                    
                // *** Was the amount entered less than 0?
                if newAmountDouble < 0.0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a positive amount")
                    
                    
                } else if newAmountDouble > (currentCategory.available + currentItem.amount) && typeOfItem == .withdrawal {
                    
                    failureWithWarning(label: warningLabel, message: "There are not enough funds available to allocate the budgeted amount at this time.")
                    
                    
                    // *** SUCCESS!
                } else {
                    
                    // ***** Go to Allocation Check
                    
                    editSubmission()
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // *** Show Alert To Confirm Edits
    
    func editSubmission() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentBudgetItem = editableBudgetItem else { return }
        
        // Name
        guard let newName = nameTextField.text else { return }
        var changeName = false
        if newName != currentBudgetItem.name {
            changeName = true
        }
        
        
        // Category
        guard let newCategory = categoryLabel.text else { return }
        var changeCategory = false
        if newCategory != currentBudgetItem.category {
            changeCategory = true
        }
        
        
        // Amount
        guard let newAmount = Double(amountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentBudgetItem.amount {
            changeAmount = true
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        let currentDate = convertDayToCurrentDate(day: Int(currentBudgetItem.day))
        
        // The 4th possibility, 'nil -> nil', does not change anything.
        // If current set date does not match the newly set date.
        // Accounts for 2 of the 4 possibilities: nil -> set, oldSet -> newSet
        if dateLabel.text != "" && newDate != currentDate {
            
            changeDate = true
          
            
        // Accounts for 1 of the 4 possibilities: set -> nil
        } else if dateLabel.text == "" && currentBudgetItem.day > 0 {
            
            changeDate = true
            
        }
        
        
        // Final confirmation, checking to see if there is even anything to change.
        if !changeName && !changeCategory && !changeAmount && !changeDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            if changeName {
                budget.updateBudgetItemName(name: newName, forItem: currentBudgetItem)
            }
            if changeCategory {
                budget.updateBudgetItemCategory(category: newCategory, forItem: currentBudgetItem)
            }
            if changeAmount {
                budget.updateBudgetItemAmount(amount: newAmount, forItem: currentBudgetItem)
            }
            if changeDate {
                
                // Only 4 options possible: nil -> nil, nil -> set, set -> nil, oldSet -> newSet.
                // No need to check 'nil -> nil', as that wouldn't change anything.
                // So, the other three are accounted for.
                
                if currentBudgetItem.day > 0 {
                    
                    // There was a date, and it was changed.
                    if dueDateSwitch.isOn {
                        
                        budget.updateBudgetItemDueDate(dueDate: newDate, forItem: currentBudgetItem)
                        
                    // There was a date, and it was removed.
                    } else {
                        
                        budget.updateBudgetItemDueDate(dueDate: nil, forItem: currentBudgetItem)
                        
                    }
                    
                } else {
                    
                    // There was no date, and it was set.
                    if dueDateSwitch.isOn {
                        
                        budget.updateBudgetItemDueDate(dueDate: newDate, forItem: currentBudgetItem)
                        
                    }
                    
                }
                
            }
            successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        if isSettingDueDate {
            
            self.date = date
            
            var dateDict = convertDateToInts(dateToConvert: date)
            
            if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
                
                dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
                
                dateLabel.text = "\(month)/\(day)/\(year)"
                
            }
            
            isSettingDueDate = false
            
        } else {
            
            self.ledgerDate = date
            
            var dateDict = convertDateToInts(dateToConvert: date)
            
            if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
                
                dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
                
                ledgerDateLabel.text = "\(month)/\(day)/\(year)"
                
            }
            
            isSettingLedgerDate = false
            
        }
        
    }
    
    func setCategory(category: String) {
        categoryLabel.text = category
    }
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetItemToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            if isSettingDueDate {
                
                datePickerVC.date = date
                
            } else {
                
                datePickerVC.date = ledgerDate
                
            }
            
        } else if segue.identifier == addOrEditBudgetItemToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            guard let currentCategory = categoryLabel.text else { return }
            
            categoryPickerVC.selectedCategory = currentCategory
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    @objc func nameTapped() {
        
        nameTextField.becomeFirstResponder()
        
    }
    
    @objc func categoryTapped() {
        
        guard let item = editableBudgetItem else { return }
        
        if item.type != categoryKey && item.type != paycheckKey {
            
            performSegue(withIdentifier: addOrEditBudgetItemToCategoryPickerSegueKey, sender: self)
            
        }

    }
    
    @objc func amountTapped() {
        
        amountTextField.becomeFirstResponder()
        
    }
    
    @objc func dueDateTapped() {
        
        isSettingDueDate = true
        
        dueDateSwitch.isOn = !dueDateSwitch.isOn
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditBudgetItemToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
        }
        
    }
    
    @objc func addToLedgerTapped() {
        
        guard let currentItem = editableBudgetItem else { return }
        
        if currentItem.addedToLedger == false {
            
            isSettingLedgerDate = true
            
            addToLedgerSwitch.isOn = !addToLedgerSwitch.isOn
            
            if addToLedgerSwitch.isOn {
                
                if currentItem.type != categoryKey {
                    
                    performSegue(withIdentifier: addOrEditBudgetItemToDatePickerSegueKey, sender: self)
                    
                } else {
                    
                    ledgerDateLabel.text = "OK!"
                    
                }
                
            } else {
                
                ledgerDateLabel.text = ""
                
            }
            
        }

    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        let nameTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let categoryTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        let amountTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let dueDateTap = UITapGestureRecognizer(target: self, action: #selector(dueDateTapped))
        let addToLedgerTap = UITapGestureRecognizer(target: self, action: #selector(addToLedgerTapped))
        
        nameView.addGestureRecognizer(nameTap)
        categoryView.addGestureRecognizer(categoryTap)
        amountView.addGestureRecognizer(amountTap)
        dueDateView.addGestureRecognizer(dueDateTap)
        addToLedgerView.addGestureRecognizer(addToLedgerTap)
        
        addCircleAroundButton(named: submitBudgetItemButton)
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        if isNewBudgetItem {
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add Budget Item"
            
            submitBudgetItemButton.setTitle("Add Budget Item", for: .normal)
            
            categoryLabel.text = unallocatedKey
            
            dateLabel.text = ""
            
            dueDateSwitch.isOn = false
            
        } else {
            
            backButton.title = "Cancel"
            navBar.topItem?.title = "Edit Budget Item"
            
            guard let currentBudgetItem = editableBudgetItem else { return }
            
            guard let name = currentBudgetItem.name else { return }
            
            toggleTypeSegmentInfo(forItem: currentBudgetItem)
            nameTextField.text = name
            amountTextField.text = "\(convertedAmountToDouble(amount: currentBudgetItem.amount))"
            toggleCategoryLabelInfo(forItem: currentBudgetItem)
            
            if currentBudgetItem.day > 0 {
                
                date = convertDayToCurrentDate(day: Int(currentBudgetItem.day))
                
                dateLabel.text = "\(convertDayToOrdinal(day: Int(currentBudgetItem.day)))"
                
                dueDateSwitch.isOn = true
                
            } else {
                
                date = Date()
                
                dateLabel.text = ""
                
                dueDateSwitch.isOn = false
                
            }
            
            if currentBudgetItem.addedToLedger {
                
                addToLedgerSwitch.isOn = true
                addToLedgerSwitch.isEnabled = false
                ledgerDateLabel.text = "Added!"
                
            }
            
            submitBudgetItemButton.setTitle("Save Changes", for: .normal)
            
        }
        
        self.nameTextField.delegate = self
        self.amountTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
    }
    
    
    
    
    
    
    
    
    
    
    

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditBudgetItemViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}













