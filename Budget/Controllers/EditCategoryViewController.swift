//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController, UITextFieldDelegate {
    
    var currentCategoryNameString = String()
    var currentCategoryAmountDouble = Double()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        budget.updateBalance()
        leftLabelOnNavBar.title = "\(convertedAmountToDollars(amount: budget.balance))"
        
        guard let unallocated = loadSpecificCategory(named: unallocatedKey) else { return }
        leftAmountAtTopRight.text = "Unallocated: \(convertedAmountToDollars(amount: unallocated.available))"
    }
    
    func updateLabelsAtTop() {
        
        if let currentCategory = loadSpecificCategory(named: currentCategoryNameString) {
            
            currentCategoryName.text = currentCategoryNameString
<<<<<<< HEAD
            currentCategoryAmount.text = "$\(String(format: doubleFormatKey, currentCategory.budgeted))"
=======
            currentCategoryAmount.text = "Left: \(convertedAmountToDollars(amount: currentCategory.budgeted))"
>>>>>>> switchToCoreData
            
        }
    
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(label: UILabel, textFieldUsed: UITextField, successMessage: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Warning label update
        label.textColor = successColor
        label.text = successMessage
        
        
        // Update Left label at top right & balance labels
        updateLabelsAtTop()
        
        // Clear text field
        textFieldUsed.text = nil
        textFieldUsed.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(label: UILabel, message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        label.textColor = UIColor.red
        label.text = message
        
    }
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryAmount: UILabel!

    
    
    @IBOutlet weak var newCategoryName: UITextField!
    
    @IBOutlet weak var newCategoryAmount: UITextField!
    
    
    
    
    @IBOutlet weak var nameWarningLabel: UILabel!
    
    @IBOutlet weak var amountWarningLabel: UILabel!
    
    
    
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var amountView: UIView!
    
    
    
    // MARK: - Edit Category Name Check
    
    
    // Name Error Check
    
    func submitEditCategoryNameForReview() {
        
<<<<<<< HEAD
        guard let oldCategoryTitle = currentCategoryName.text else { return }
        guard let oldCategory = budget.categories[oldCategoryTitle] else { return }
        
        guard let newCategoryTitleFromTextField = newCategoryName.text else { return }
        guard let newCategoryBudgetedStringFromTextField = newCategoryAmount.text else { return }
            
        var newCategoryTitle = ""
        var newCategoryBudgeted = Double()

        // *** Are the fields empty?
        if newCategoryTitleFromTextField == "" && newCategoryBudgetedStringFromTextField == ""  {
            
            failureWithWarning(message: "There is nothing to update.")
        
        } else {
            
            // *** Are both fields the exact same as already set?
            if newCategoryTitleFromTextField == oldCategoryTitle && Double(newCategoryBudgetedStringFromTextField) == oldCategory.budgeted {
=======
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryTitleFromTextField = newCategoryName.text {
            
            // *** Is the field empty?
            if newCategoryTitleFromTextField == "" {
                
                failureWithWarning(label: nameWarningLabel, message: "There is nothing to update.")
                
>>>>>>> switchToCoreData
                
                // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryTitleFromTextField == unallocatedKey {
                
<<<<<<< HEAD
            // *** Was the new category entered the same as the one already set, if not amount changed?
            } else if oldCategoryTitle == newCategoryTitleFromTextField && newCategoryBudgetedStringFromTextField == "" {
=======
                failureWithWarning(label: nameWarningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
>>>>>>> switchToCoreData
                
                // *** Was the new category entered the same as the one already set?
            } else if oldCategoryTitle == newCategoryTitleFromTextField {
                
<<<<<<< HEAD
            // *** Was the amount entered the same as is already budgeted?
            } else if newCategoryTitleFromTextField == "" && Double(newCategoryBudgetedStringFromTextField) == oldCategory.budgeted {
                
                failureWithWarning(message: "The category is already budgeted $\(String(format: doubleFormatKey, oldCategory.budgeted))")
                
            // *** Was the amount not convertible to a Double?
            // *** This checks both if the name field is empty, as well as if both have information and the amount is not a Double.
            } else if (newCategoryTitleFromTextField == "" && Double(newCategoryBudgetedStringFromTextField) == nil) || (newCategoryTitleFromTextField != "" && newCategoryBudgetedStringFromTextField != "" && Double(newCategoryBudgetedStringFromTextField) == nil){
                
                failureWithWarning(message: "You have to enter a number.")
               
            // *** All is checked except for a negative number
            } else {
                
                // *** Assigns 'newCategoryBudgeted' a value based on if the field is blank (the amount already budgeted) or a new amount.
                if let budgetedAsDouble = Double(newCategoryBudgetedStringFromTextField) {
                    
                    // Assigns the amount from text field, if it is populated, to the 'newCategoryBudgeted' variable
                    newCategoryBudgeted = budgetedAsDouble
                    
                } else {
                    
                    // If it is left blank, then the amount from the old category is assigned to it.
                    newCategoryBudgeted = oldCategory.budgeted
                    
                }
                
                // *** Is the amount negative?
                if newCategoryBudgeted < 0.0 {
                    
                    failureWithWarning(message: "You have to enter a positive amount")
                    
                // *** Everything is checked. Successful entry!
                } else {
                    
                    // Sets 'newCategoryTitle'
                    if newCategoryTitleFromTextField == "" {
                        
                        newCategoryTitle = oldCategoryTitle
                        
                    } else {
                        
                        newCategoryTitle = newCategoryTitleFromTextField
                        
                    }
                    
                    // ***** Checks the fields to assign appropriate Alert and Success messages
                    var alertMessage = String()
                    var successMessage = String()
                    
                    // *** If only amount changed: Sets new category to old category.
                    if newCategoryTitleFromTextField == "" || newCategoryTitleFromTextField == oldCategoryTitle {
                        
                        alertMessage = "Update '\(oldCategoryTitle)' with $\(String(format: doubleFormatKey, newCategoryBudgeted))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully updated with $\(String(format: doubleFormatKey, newCategoryBudgeted))!"
                        
                    // *** If only name changed: Sets new category budgeted to old category budgeted.
                    } else if newCategoryBudgetedStringFromTextField == "" || Double(newCategoryBudgetedStringFromTextField) == oldCategory.budgeted {
                        
                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!"
                        
                    // *** If both change: Sets new budgeted amount to text field input.
                    } else {

                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)', and change budgeted amount from $\(String(format: doubleFormatKey, oldCategory.budgeted)) to $\(String(format: doubleFormatKey, newCategoryBudgeted))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)', and the budgeted amount of $\(String(format: doubleFormatKey, oldCategory.budgeted)) was changed to $\(String(format: doubleFormatKey, newCategoryBudgeted))!"
                        
                    }
                    
                    // *** Alert message to pop up to confirmation
                    
                    let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        // Update Category function called & local variables for labels set
                        
                        budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewBudgetedAmount: newCategoryBudgeted)
                        
                        self.currentCategoryNameString = newCategoryTitle
                        self.currentCategoryAmountDouble = newCategoryBudgeted
                        
                        self.updateUIElementsBecauseOfSuccess(successMessage: successMessage)
                        
                        self.updateLabelsAtTop()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    present(alert, animated: true, completion: nil)
=======
                failureWithWarning(label: nameWarningLabel, message: "The category is already named '\(currentCategoryNameString)'")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                for categoryName in budget.sortedCategoryKeys {
                    
                    if categoryName == newCategoryTitleFromTextField {
                        
                        failureWithWarning(label: nameWarningLabel, message: "There is already a category named '\(categoryName)'")
                        
                        return
                        
                    }
                    
                }
                
                // *** Alert message to pop up to confirmation
                
                showAlertToConfirmEditCategoryName(oldCategoryTitle: oldCategoryTitle, newCategoryTitle: newCategoryTitleFromTextField)
                
            }
            
        }
        
    }
    
    // Name Alert Confirmation
    
    func showAlertToConfirmEditCategoryName(oldCategoryTitle: String, newCategoryTitle: String) {
        
        let alert = UIAlertController(title: nil, message: "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewAmountAdded: 0.0)
            
            
            // Update the UI elements with the new info
            self.currentCategoryNameString = newCategoryTitle
            
            self.updateUIElementsBecauseOfSuccess(label: self.nameWarningLabel, textFieldUsed: self.newCategoryName, successMessage: "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!")
            
            self.updateLabelsAtTop()
            self.updateLeftLabelAtTopRight()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    // MARK: - Update Name Button
    
    @IBAction func changeName(_ sender: UIButton) {
        
        submitEditCategoryNameForReview()
        
    }
    
    
    
    
    
    // MARK: - Edit Category Amount Check
    
    
    // Amount Error Check
    
    func submitEditCategoryAmountForReview() {
        
        newCategoryAmount.resignFirstResponder()
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryAmountStringFromTextField = newCategoryAmount.text {
            
            var newCategoryAmount = Double()
            
            guard let oldCategory = loadSpecificCategory(named: oldCategoryTitle) else { return }
            
            
            // *** Is the field empty?
            if newCategoryAmountStringFromTextField == ""  {
                
                failureWithWarning(label: amountWarningLabel, message: "There is nothing to update.")
                
                
                // *** Was the amount not convertible to a Double?
            } else if Double(newCategoryAmountStringFromTextField) == nil {
                
                failureWithWarning(label: amountWarningLabel, message: "You have to enter a number.")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                // Sets 'newCategoryAmount' to the number entered.
                if let newCategoryAmountDouble = Double(newCategoryAmountStringFromTextField) {
                    
                    newCategoryAmount = newCategoryAmountDouble
                    
                }
                
                // *** Was the amount entered less than 0?
                if newCategoryAmount < 0.0 {
                    
                    failureWithWarning(label: amountWarningLabel, message: "You have to enter a positive amount")
                    
                    
                    // ***** SUCCESS!
                } else {
                    
                    // ***** Alert message to pop up to confirmation
                    
                    showAlertToConfirmEditCategoryAmount(newCategoryAmount: newCategoryAmount, oldCategoryTitle: oldCategoryTitle, oldCategory: oldCategory)
>>>>>>> switchToCoreData
                    
                }
                
            }
            
        }
        
    }
    
    // Amount Alert Confirmation
    
    func showAlertToConfirmEditCategoryAmount(newCategoryAmount: Double, oldCategoryTitle: String, oldCategory: Category) {
        
        let alert = UIAlertController(title: nil, message: "Change budgeted amount to \(convertedAmountToDollars(amount: newCategoryAmount)) for '\(oldCategoryTitle)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // Update Category function called & local variables for labels set
            
            print(newCategoryAmount)
            
            budget.updateCategory(named: oldCategoryTitle, updatedNewName: oldCategoryTitle, andNewAmountAdded: newCategoryAmount)
            
            
            // Update the UI element with the new info
            self.currentCategoryAmountDouble = newCategoryAmount
            
            self.updateUIElementsBecauseOfSuccess(label: self.amountWarningLabel, textFieldUsed: self.newCategoryAmount, successMessage: "New '\(oldCategoryTitle)' budgeted amount: \(self.convertedAmountToDollars(amount: newCategoryAmount))")
            
            self.updateLabelsAtTop()
            self.updateLeftLabelAtTopRight()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // MARK: - Update Amount Button
    
    @IBAction func addFunds(_ sender: UIButton) {
        
        submitEditCategoryAmountForReview()
        
    }
    
    
    
    // MARK: - Buttons as outets for rounded borders.
    
    @IBOutlet weak var addFundsButton: UIButton!
    
    @IBOutlet weak var changeNameButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // MARK: - Add done button
        
        let toolbar = UIToolbar()
        toolbar.barTintColor = UIColor.black
        
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.dismissNumberKeyboard))
        doneButton.tintColor = UIColor.white
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        newCategoryAmount.inputAccessoryView = toolbar
        
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        


        // Do any additional setup after loading the view.
        currentCategoryNameString = editableCategoryName
        
        updateLabelsAtTop()
        updateLeftLabelAtTopRight()
        
        self.addFundsButton.layer.cornerRadius = 27
        self.addFundsButton.layer.masksToBounds = true
        self.addFundsButton.layer.borderWidth = 1
        self.addFundsButton.layer.borderColor = lightGreenColor.cgColor
        
        self.changeNameButton.layer.cornerRadius = 27
        self.changeNameButton.layer.masksToBounds = true
        self.changeNameButton.layer.borderWidth = 1
        self.changeNameButton.layer.borderColor = lightGreenColor.cgColor
        
<<<<<<< HEAD
        self.editCategoryButton.layer.cornerRadius = 18
        self.editCategoryButton.layer.masksToBounds = true
=======
        self.newCategoryName.delegate = self
        self.newCategoryAmount.delegate = self
>>>>>>> switchToCoreData

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Keyboard dismissals
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1 {
            
            submitEditCategoryNameForReview()
            
        }
        
        return true
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc func dismissNumberKeyboard() {
        
        submitEditCategoryAmountForReview()
        
//        newCategoryAmount.resignFirstResponder()
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    // Remove warning label text
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        nameWarningLabel.text = ""
        amountWarningLabel.text = ""
    }
    
    
    
}
















