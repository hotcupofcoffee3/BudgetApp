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
    // Mark: - Declared
    // *****
    
    var isNewBudgetItem = true
    
    var editableBudgetItem: BudgetItem?
    
    var editableBudgetItemName = String()
    
    var editableBudgetItemBudgeted = Double()
    
    var editableBudgetItemDueDay = Int()
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    var selectedBudgetTimeFrameStartID = Int()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var submitBudgetItemButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var dueDateView: UIView!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBudgetItem(_ sender: UIButton) {
        
        if isNewBudgetItem {
            
            submitAddBudgetItemForReview()
            
        } else {
            
            submitEditItemsForReview()
            
        }
        
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
    
    
    
    // *****
    // Mark: - Submissions
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
                
                if (categoryBeingWithdrawnFrom.available - amount) < 0 {
                    
                    failureWithWarning(label: warningLabel, message: "You don't have enough funds in this category.")
                    
                } else if amount <= 0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a number greater than 0.")
                    
                } else {
                    
                    showAlertToConfirmAddBudgetItem(newItemName: name, with: amount, toCategory: category, withDueDate: dueDate)
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
            }
            
        }
        
    }
    
    
    
    // *** Add Budget Item Alert Confirmation
    
    func showAlertToConfirmAddBudgetItem(newItemName name: String, with amount: Double, toCategory categoryName: String, withDueDate: Date?) {
        
        nameTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        
        var confirmationMessage = String()
        
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
        
        if withDueDate == nil {
            
            confirmationMessage = "Add named \"\(name)\" with an amount of \(convertedAmountToDollars(amount: amount)) for '\(categoryName)'?"
            
        } else {
            
            confirmationMessage = "Add named \"\(name)\" with an amount of \(convertedAmountToDollars(amount: amount)) for '\(categoryName) due on the \(convertDayToOrdinal(day: day))'?"
            
        }
        
        let alert = UIAlertController(title: nil, message: confirmationMessage, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            createAndSaveNewBudgetItem(timeSpanID: self.selectedBudgetTimeFrameStartID, type: "none", named: name, amount: amount, category: categoryName, year: year, month: month, day: day)
            
            saveData()
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\"\(name)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
            
            self.successHaptic()
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
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
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if currentBudgetItem.amount > newCategoryItself.available {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
            
        } else {
            
            submitEditAmountForReview()
            
        }
        
    }
    
    
    
    // *** Edit Budgeted Check
    
    func submitEditAmountForReview() {
        
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
                    
                    
                } else if newAmountDouble > currentCategory.available {
                    
                    failureWithWarning(label: warningLabel, message: "There are not enough funds available to allocate the budgeted amount at this time.")
                    
                    
                    // *** SUCCESS!
                } else {
                    
                    // ***** Go to Allocation Check
                    
                    showAlertToConfirmEdits()
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // *** Show Alert To Confirm Edits
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentBudgetItem = editableBudgetItem else { return }
        
        var updatedItemsConfirmationMessage = ""
        
        
        // Name
        guard let newName = nameTextField.text else { return }
        var changeName = false
        if newName != currentBudgetItem.name {
            changeName = true
            updatedItemsConfirmationMessage += "Change name to: \(newName)?\n"
        }
        
        
        // Category
        guard let newCategory = categoryLabel.text else { return }
        var changeCategory = false
        if newCategory != currentBudgetItem.category {
            changeCategory = true
            updatedItemsConfirmationMessage += "Change category to: \(newCategory)?\n"
        }
        
        
        // Amount
        guard let newAmount = Double(amountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentBudgetItem.amount {
            changeAmount = true
            updatedItemsConfirmationMessage += "Change amount to: \(convertedAmountToDollars(amount: newAmount))?\n"
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        let currentDate = convertDayToCurrentDate(day: Int(currentBudgetItem.day))
        
        let newDateDict = convertDateToInts(dateToConvert: newDate)
        guard let newDueDay = newDateDict[dayKey] else { return }
        
        // The 4th possibility, 'nil -> nil', does not change anything.
        // If current set date does not match the newly set date.
        // Accounts for 2 of the 4 possibilities: nil -> set, oldSet -> newSet
        if dateLabel.text != "" && newDate != currentDate {
            
            changeDate = true
            updatedItemsConfirmationMessage += "Change Due Date to the \(convertDayToOrdinal(day: newDueDay))?\n"
          
            
        // Accounts for 1 of the 4 possibilities: set -> nil
        } else if dateLabel.text == "" && currentBudgetItem.day > 0 {
            
            changeDate = true
            updatedItemsConfirmationMessage += "Remove Due Date?\n"
            
        }
        
        
        // Final confirmation, checking to see if there is even anything to change.
        if !changeName && !changeCategory && !changeAmount && !changeDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
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
                        if self.dueDateSwitch.isOn {
                            
                            budget.updateBudgetItemDueDate(dueDate: newDate, forItem: currentBudgetItem)
                            
                        // There was a date, and it was removed.
                        } else {
                            
                            budget.updateBudgetItemDueDate(dueDate: nil, forItem: currentBudgetItem)
                            
                        }
                        
                    } else {
                        
                        // There was no date, and it was set.
                        if self.dueDateSwitch.isOn {
                            
                            budget.updateBudgetItemDueDate(dueDate: newDate, forItem: currentBudgetItem)
                            
                        }
                        
                    }
                    
                }
                self.successHaptic()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    func setCategory(category: String) {
        categoryLabel.text = category
    }
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetItemToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        } else if segue.identifier == addOrEditBudgetItemToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            guard let currentCategory = categoryLabel.text else { return }
            
            categoryPickerVC.selectedCategory = currentCategory
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    @objc func nameTapped() {
        
        nameTextField.becomeFirstResponder()
        
    }
    
    @objc func categoryTapped() {
            
        performSegue(withIdentifier: addOrEditBudgetItemToCategoryPickerSegueKey, sender: self)
        
    }
    
    @objc func amountTapped() {
        
        amountTextField.becomeFirstResponder()
        
    }
    
    @objc func dueDateTapped() {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditBudgetItemToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Keyboard functions
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
        
        nameView.addGestureRecognizer(nameTap)
        categoryView.addGestureRecognizer(categoryTap)
        amountView.addGestureRecognizer(amountTap)
        dueDateView.addGestureRecognizer(dueDateTap)
        
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
            guard let category = currentBudgetItem.category else { return }
            
            nameTextField.text = name
            amountTextField.text = "\(convertedAmountToDouble(amount: currentBudgetItem.amount))"
            categoryLabel.text = category
            
            if currentBudgetItem.day > 0 {
                
                date = convertDayToCurrentDate(day: Int(currentBudgetItem.day))
                
                dateLabel.text = "\(convertDayToOrdinal(day: Int(currentBudgetItem.day)))"
                
                dueDateSwitch.isOn = true
                
            } else {
                
                date = Date()
                
                dateLabel.text = ""
                
                dueDateSwitch.isOn = false
                
            }
            
            submitBudgetItemButton.setTitle("Save Changes", for: .normal)
            
        }
        
        self.nameTextField.delegate = self
        self.amountTextField.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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













