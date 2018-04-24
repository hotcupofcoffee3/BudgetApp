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
    
    func updateLabelsAtTop() {
        
        if let currentCategory = budget.categories[currentCategoryNameString] {
            
            currentCategoryName.text = currentCategoryNameString
            currentCategoryAmount.text = "$\(String(format: doubleFormatKey, currentCategory.budgeted))"
            
        }
    
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(successMessage: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Warning label update
        warningLabel.textColor = successColor
        warningLabel.text = successMessage
        
        
        // Update Left label at top right & balance labels
        updateLabelsAtTop()
        
        // Clear text field
        newCategoryName.text = nil
        newCategoryAmount.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(message: String) {
        
        // Warning notification haptic
        let warning = UINotificationFeedbackGenerator()
        warning.notificationOccurred(.error)
        
        warningLabel.textColor = UIColor.red
        warningLabel.text = message
        
    }
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var currentCategoryAmount: UILabel!
    
    @IBOutlet weak var newCategoryName: UITextField!
    
    @IBOutlet weak var newCategoryAmount: UITextField!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBAction func editCategory(_ sender: UIButton) {
        
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
                
                failureWithWarning(message: "This is the same information that is already set.")
                
            // *** Was the new category entered the same as the one already set, if not amount changed?
            } else if oldCategoryTitle == newCategoryTitleFromTextField && newCategoryBudgetedStringFromTextField == "" {
                
                failureWithWarning(message: "The category is already named '\(currentCategoryNameString)'")
                
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
                    
                }
            
            }
            
        }
        
    }
    
    @IBOutlet weak var editCategoryButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentCategoryNameString = editableCategoryName
        
        updateLabelsAtTop()
        
        self.editCategoryButton.layer.cornerRadius = 18
        self.editCategoryButton.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
