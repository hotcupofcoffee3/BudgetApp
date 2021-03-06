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
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isNewCategory = true
    
    var editableCategory: Category?
    
    var editableCategoryName = String()
    
    var editableCategoryBudgeted = Double()
    
    var editableCategoryDueDay = Int()
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    let isFirstTime = (UserDefaults.standard.object(forKey: isSetUpKey) == nil) ? true : false
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitCategoryButton: UIButton!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var nameView: UIView!
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var budgetedAmountTextField: UITextField!
   
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Set text fields back to being empty
        categoryNameTextField.text = nil
        budgetedAmountTextField.text = nil
        
    }
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
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
    
    @IBAction func dueDateToggleSwitch(_ sender: UISwitch) {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditCategoryToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
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
    // ***** Add Category
    // **************************************
    
    
    
    // *** Submit Add Category For Review
    
    func submitAddCategoryForReview() {
        
        if let categoryName = categoryNameTextField.text, let budgetedAmount = budgetedAmountTextField.text {
            
            // *** Checks if it's already created.
            var isAlreadyCreated = false
            
            for category in budget.categories {
                
                if category.name! == categoryName {
                    
                    isAlreadyCreated = true
                    
                }
                
            }
            
            // *** If everything is blank
            if categoryName == "" || budgetedAmount == "" {
                
                failureWithWarning(label: warningLabel, message: "You have to complete both fields.")
                
                
                // *** If "Unallocated" is the attempted name
            } else if categoryName == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot create a category called \"Unallocated\"")
                
                
                // *** If the category name already exists.
            } else if isAlreadyCreated == true {
                
                failureWithWarning(label: warningLabel, message: "A category with this name has already been created.")
                
                
                // *** If both are filled out, but the amount is not a double
            } else if categoryName != "" && budgetedAmount != "" && Double(budgetedAmount) == nil {
                
                failureWithWarning(label: warningLabel, message: "You have to enter a number for the amount.")
                
                
            } else {
                
                if let budgetedAmountAsDouble = Double(budgetedAmount) {
                    
                    if budgetedAmountAsDouble < 0.0 {
                        
                        failureWithWarning(label: warningLabel, message: "You have to enter a positive number")
                        
                    } else {
                        
                        addCategorySubmission(newCategoryName: categoryName, with: budgetedAmountAsDouble)
                        
                    }
                    
                }
                
            }
            
        }
        
    }
    
    
    
    // *** Add Category Alert Confirmation
    
    func addCategorySubmission(newCategoryName: String, with amount: Double) {
        
        categoryNameTextField.resignFirstResponder()
        budgetedAmountTextField.resignFirstResponder()
        
        var dueDay = Int()
        
        if self.dueDateSwitch.isOn {
            
            let dateDict = convertDateToInts(dateToConvert: date)
            guard let day = dateDict[dayKey] else { return }
            
            dueDay = day
            
        }
        
        budget.addCategory(named: newCategoryName, withBudgeted: amount, withDueDay: dueDay)
     
        saveData()
        
        warningLabel.textColor = successColor
        warningLabel.text = "\"\(newCategoryName)\" with an amount of \(convertedAmountToDollars(amount: amount)) has been added."
        
        updateUIElementsBecauseOfSuccess()
        successHaptic()
        
    }
    

    
    // **************************************
    // ***** Edit Category
    // **************************************
    
    
    // *** Submit Edit Items For Review
    
    func submitEditItemsForReview() {
        
        // The 'else' on this leads to the next 'submit' check, and so on, until the end, in which case the 'else' calls the 'showAlertToConfirmEdits' function.
        submitEditNameForReview()
        
    }
    
    
    
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
    
    
    
    // *** Edit Budgeted Check
    
    func submitEditBudgetedForReview() {
        
        if let newBudgetedAmount = budgetedAmountTextField.text {
            
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
                    
                    editSubmission()
                    
                }
                
            }
            
        }
        
    }
    
    
    // *** Show Alert To Confirm Edits
    
    func editSubmission() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentCategory = editableCategory else { return }
        guard let currentCategoryName = currentCategory.name else { return }
       
        // Name
        guard let newName = categoryNameTextField.text else { return }
        var changeName = false
        if newName != currentCategory.name {
            changeName = true
        }
        
        
        // Amount
        guard let newAmount = Double(budgetedAmountTextField.text!) else { return }
        var changeAmount = false
        if newAmount != currentCategory.budgeted {
            changeAmount = true
        }
        
        
        // Date
        let newDate = date
        var changeDate = false
        let currentDate = convertDayToCurrentDate(day: Int(currentCategory.dueDay))
        
        if dateLabel.text != "" && newDate != currentDate {
            changeDate = true
        }
        
        // Final confirmation, checking to see if there is even anything to change.
        if !changeName && !changeAmount && !changeDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            if changeName {
                budget.updateCategory(named: currentCategoryName, updatedNewName: newName, andNewAmountBudgeted: currentCategory.budgeted)
            }
            if changeAmount {
                budget.updateCategory(named: newName, updatedNewName: newName, andNewAmountBudgeted: newAmount)
            }
            if changeDate {
                let newDateDict = convertDateToInts(dateToConvert: newDate)
                guard let newDueDay = newDateDict[dayKey] else { return }
                currentCategory.dueDay = Int64(newDueDay)
            }
            
            self.successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditCategoryToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = date
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    @objc func nameTapped() {
        
        categoryNameTextField.becomeFirstResponder()
        
    }
    
    @objc func amountTapped() {
        
        budgetedAmountTextField.becomeFirstResponder()
        
    }
    
    @objc func dateTapped() {
        
        if dueDateSwitch.isOn == true {
            
            performSegue(withIdentifier: addOrEditCategoryToDatePickerSegueKey, sender: self)
            
        } else {
            
            dateLabel.text = ""
            
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
        
        budgetedAmountTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: budgetedAmountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        warningLabel.text = ""
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
            budgetedAmountTextField.text = "\(convertedAmountToDouble(amount: budgeted))"
            
            if currentCategory.dueDay > 0 {
                
                date = convertDayToCurrentDate(day: Int(currentCategory.dueDay))
                dateLabel.text = "\(convertDayToOrdinal(day: dueDay))"
                
            } else {
                
                date = Date()
                dateLabel.text = ""
                
            }
            
            submitCategoryButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        // *** Tap gesture to textfields and their labels
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let datetap = UITapGestureRecognizer(target: self, action: #selector(dateTapped))
        
        nameView.addGestureRecognizer(nameViewTap)
        amountView.addGestureRecognizer(amountViewTap)
        dateLabel.addGestureRecognizer(datetap)
        
        
        // *** Toolbar with 'Done' on Number Pad
        addToolBarToNumberPad(textField: budgetedAmountTextField)
        
        
        // *** Swipe gesture to close keyboard
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        // *** Circle around button
        addCircleAroundButton(named: submitCategoryButton)
        
        
        // *** Textfield Delegates
        self.categoryNameTextField.delegate = self
        self.budgetedAmountTextField.delegate = self
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
    }
    
    



    
    
    
}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditCategoryViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}














