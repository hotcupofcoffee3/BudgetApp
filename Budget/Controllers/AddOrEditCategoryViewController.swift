//
//  AddOrEditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import Foundation

class AddOrEditCategoryViewController: UIViewController, UITextFieldDelegate, ChooseDate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var isNewCategory = true
    
    var editableCategory: Category?
    
    var editableCategoryName = String()
    
    var editableCategoryBudgeted = Double()
    
    var editableCategoryDueDay = Int()
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitCategoryButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    
    // *** IBActions
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitCategory(_ sender: UIButton) {
        
        if isNewCategory {
            
            submitAddCategoryForReview()
            
        } else {
            
            submitEditItemsForReview()
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNewCategory {
            
            backButton.title = "Back"
            navBar.topItem?.title = "Add Category"
            submitCategoryButton.setTitle("Add Category", for: .normal)
            
        } else {
            
            backButton.title = "Cancel"
            navBar.topItem?.title = "Edit Category"
            
            guard let currentCategory = editableCategory else { return }
            
            guard let name = currentCategory.name else { return }
            let budgeted = currentCategory.budgeted
            let dueDay = Int(currentCategory.dueDay)
            
            categoryNameTextField.text = name
            categoryAmountTextField.text = "\(convertedAmountToDouble(amount: budgeted))"
            
            if currentCategory.dueDay > 0 {
                
                date = convertDayToCurrentDate(day: Int(currentCategory.dueDay))
                dateLabel.text = "\(convertDayToOrdinal(day: dueDay))"
                
            } else {
                
                date = Date()
                dateLabel.text = ""
                
            }
            
            currentAllocationStatus.isOn = false
            
            submitCategoryButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        // *** Tap gesture to textfields and their labels
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let allocateViewTap = UITapGestureRecognizer(target: self, action: #selector(allocateTapped))
        let datetap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        allocateView.addGestureRecognizer(allocateViewTap)
        dateLabel.addGestureRecognizer(datetap)
        
        
        // *** Toolbar with 'Done' on Number Pad
        addToolBarToNumberPad(textField: categoryAmountTextField)
        
        
        // *** Swipe gesture to close keyboard
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        // *** Update labels
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        
        // *** Circle around button
        addCircleAroundButton(named: submitCategoryButton)
        
        
        // *** Textfield Delegates
        self.categoryNameTextField.delegate = self
        self.categoryAmountTextField.delegate = self
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var categoryAmountTextField: UITextField!
    
    @IBOutlet weak var currentAllocationStatus: UISwitch!

    @IBOutlet weak var allocateView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func dueDateToggleSwitch(_ sender: UISwitch) {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditCategoryToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Set text fields back to being empty
        categoryNameTextField.text = nil
        categoryAmountTextField.text = nil
        
    }
    
    
    
    
    
    
    
    
    
    
    
    // ****************************************************************************************
    
    // ***** Main error check for adding categories
    
    // *** Add Category Check
    
    // Error Check
    
    func submitAddCategoryForReview() {
        
        if let categoryName = categoryNameTextField.text, let categoryAmount = categoryAmountTextField.text {
            
            // *** Checks if it's already created.
            var isAlreadyCreated = false
            
            for category in budget.categories {
                
                if category.name! == categoryName {
                    
                    isAlreadyCreated = true
                    
                }
                
            }
            
            // *** If everything is blank
            if categoryName == "" || categoryAmount == "" {
                
                failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if categoryName == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(label: warningLabel, message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if categoryName != "" && categoryAmount != "" && Double(categoryAmount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let categoryAmountAsDouble = Double(categoryAmount) {
                    
                    guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
                    
                    if categoryAmountAsDouble < 0.0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
                        
                        
                        // *** If 'Allocate' is switched on, is there enough in 'Unallocated'
                    } else if currentAllocationStatus.isOn && categoryAmountAsDouble > unallocated.available {
                        
                        failureWithWarning(label: warningLabel, message: "You don't have enough funds to allocate at this time.")
                        
                    } else {
                        
                        showAlertToConfirmAddCategory(newCategoryName: categoryName, with: categoryAmountAsDouble)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // Add Category Alert Confirmation
    
    func showAlertToConfirmAddCategory(newCategoryName: String, with amount: Double) {
        
        categoryNameTextField.resignFirstResponder()
        categoryAmountTextField.resignFirstResponder()
        
        let alert = UIAlertController(title: nil, message: "Create category named \"\(newCategoryName)\" with an amount of \(convertedAmountToDollars(amount: amount))?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.addCategory(named: newCategoryName, withBudgeted: amount)
            
            guard let newCategory = loadSpecificCategory(named: newCategoryName) else { return }
            
            if self.currentAllocationStatus.isOn {
                budget.shiftFunds(withThisAmount: amount, from: unallocatedKey, to: newCategoryName)
            }
            
            if self.dueDateSwitch.isOn {
                
                let dateDict = convertDateToInts(dateToConvert: self.date)
                guard let day = dateDict[dayKey] else { return }
                
                newCategory.dueDay = Int64(day)
                
            }
            
            saveData()
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\"\(newCategoryName)\" with an amount of \(self.convertedAmountToDollars(amount: amount)) has been added."
            
            self.updateUIElementsBecauseOfSuccess()
            self.successHaptic()
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    // ****************************************************************************************
    // ****************************************************************************************
    
    /*
 
     The main editing section to be submitted.
     
     */
    
    // ****************************************************************************************
    // ****************************************************************************************
    
    
    
    func submitEditItemsForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
    }
    
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentCategory = editableCategory else { return }
        guard let currentCategoryName = currentCategory.name else { return }
        
        var updatedItemsConfirmationMessage = ""
        
        
        // Name
        guard let newName = categoryNameTextField.text else { return }
        var changeName = false
        if newName != currentCategory.name {
            changeName = true
            updatedItemsConfirmationMessage += "Change name to: \(newName)\n"
        }
        
        
        // Amount
        guard let newAmount = Double(categoryAmountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentCategory.budgeted {
            changeAmount = true
            updatedItemsConfirmationMessage += "Change budgeted amount to: \(convertedAmountToDollars(amount: newAmount))\n"
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        let currentDate = convertDayToCurrentDate(day: Int(currentCategory.dueDay))
        
        if dateLabel.text != "" && newDate != currentDate {
            
            let newDateDict = convertDateToInts(dateToConvert: newDate)
            guard let newDueDay = newDateDict[dayKey] else { return }
            
            changeDate = true
            updatedItemsConfirmationMessage += "Change Date to the \(convertDayToOrdinal(day: newDueDay))\n"
        }
        
        
        // Allocate
        let willAllocate = currentAllocationStatus.isOn
        if willAllocate == true {
            updatedItemsConfirmationMessage += "Allocate: \(convertedAmountToDollars(amount: currentCategory.budgeted))"
        }
        
        // Final confirmation, checking to see if there is even anything to change.
        if !changeName && !changeAmount && !changeDate && !willAllocate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                if changeName {
                    budget.updateCategory(named: currentCategoryName, updatedNewName: newName, andNewAmountBudgeted: currentCategory.budgeted)
                }
                if changeAmount {
                    budget.updateCategory(named: currentCategoryName, updatedNewName: currentCategoryName, andNewAmountBudgeted: newAmount)
                }
                if willAllocate {
                    budget.shiftFunds(withThisAmount: currentCategory.budgeted, from: unallocatedKey, to: currentCategoryName)
                }
                if changeDate {
                    let newDateDict = convertDateToInts(dateToConvert: newDate)
                    guard let newDueDay = newDateDict[dayKey] else { return }
                    currentCategory.dueDay = Int64(newDueDay)
                }
                
                self.successHaptic()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }

    }

    

    
    // ****************************************************************************************
    
    
    

    
    // *** Edit Name Check
    
    func submitEditNameForReview() {
        
        if let newCategoryName = categoryNameTextField.text {
            
            // *** Is the field empty?
            if newCategoryName == "" {
                
                failureWithWarning(label: warningLabel, message: "You can't leave the name blank.")
                
                
                // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryName == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // *** Go to Budgeted Amount Check
                
                submitEditBudgetedForReview()
                
            }
            
        }
        
    }
    
    
    // ****************************************************************************************
    
    

    
    // *** Edit Budgeted Error Check
    
    func submitEditBudgetedForReview() {
        
        if let newBudgetedAmount = categoryAmountTextField.text {
            
            var newCategoryBudgeted = Double()
            
            // *** Is the field empty?
            if newBudgetedAmount == ""  {
                
                failureWithWarning(label: warningLabel, message: "You can't leave the budgeted amount empty.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newBudgetedAmount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number.")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // Sets 'newCategoryBudgeted' to the number entered.
                if let newCategoryBudgetedDouble = Double(newBudgetedAmount) {
                    
                    newCategoryBudgeted = newCategoryBudgetedDouble
                    
                }
                
                // *** Was the amount entered less than 0?
                if newCategoryBudgeted < 0.0 {
                    
                    failureWithWarning(label: warningLabel, message: "You have to enter a positive amount")
                    
                    
                    // ***** SUCCESS!
                } else {
                    
                    // ***** Go to Allocation Check
                    
                    submitAllocateForReview()
                    
                }
                
            }
            
        }
        
    }
    

    
    // ****************************************************************************************
    
    
    
    
   
    
    // *** Allocate Check
    
    // Amount Error Check
    
    func submitAllocateForReview() {
        
        if currentAllocationStatus.isOn {
            
            guard let currentCategory = editableCategory else { return }
            guard let unallocatedCategory = loadSpecificCategory(named: unallocatedKey) else { return }
            
            // *** Were there enough funds available in the 'From' Category?
            if currentCategory.budgeted > unallocatedCategory.available {
                
                failureWithWarning(label: warningLabel, message: "There are not enough funds available to allocate the budgeted amount at this time.")
                
                
                // ***** SUCCESS!
            } else {
                
                // ***** Present confirm popup
                
                showAlertToConfirmEdits()
                
            }
            
        } else {
            
            showAlertToConfirmEdits()
            
        }
       
    }
    

    
    
    
    
    
    
    
    // ****************************************************************************************
    
    
    
    

    
    
    @objc func nameTapped() {
        
        categoryNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        categoryAmountTextField.becomeFirstResponder()
        
    }
    
    @objc func allocateTapped() {
        
        currentAllocationStatus.isOn = !currentAllocationStatus.isOn
        
    }
    
    @objc func dateTapped() {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditCategoryToDatePickerSegueKey, sender: self)
            
        }
        
    }
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditCategoryToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        }
        
    }
    
    
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Test for submitability
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if categoryNameTextField.text != "" {
            
            if isNewCategory {
           
                submitAddCategoryForReview()
           
            } else {
           
                submitEditItemsForReview()
           
            }
            
        } else {
            
            specificTextField.resignFirstResponder()
            
        }
        
    }
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc override func dismissNumberKeyboard() {
        
        categoryAmountTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: categoryAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
    }
    
    
    


    
    
    
}














