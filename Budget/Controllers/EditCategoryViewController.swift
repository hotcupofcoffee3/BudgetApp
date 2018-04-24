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
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryTitleFromTextField = newCategoryName.text, let newCategoryBudgetedStringFromTextField = newCategoryAmount.text {
            
            var newCategoryTitle = newCategoryTitleFromTextField
            var newCategoryBudgeted = Double()
            
            guard let oldCategory = budget.categories[oldCategoryTitle] else { return }
            

            // ***** Are the fields empty?
            if newCategoryTitleFromTextField == "" && newCategoryBudgetedStringFromTextField == ""  {
                
                failureWithWarning(message: "There is nothing to update.")
               
                
            // ***** Do both fields have info, and it is the exact same as the current info?
            } else if newCategoryTitleFromTextField == oldCategoryTitle && Double(newCategoryBudgetedStringFromTextField) == oldCategory.budgeted {
                
                failureWithWarning(message: "This is the same information that is already set.")
                
                
            // ***** Was the new category entered the same as the one already set, if not amount changed?
            } else if oldCategoryTitle == newCategoryTitleFromTextField && newCategoryBudgetedStringFromTextField == "" {
                
                failureWithWarning(message: "The category is already named '\(currentCategoryNameString)'")
                
                
            // *** Was the amount entered the same as is already budgeted?
            } else if newCategoryTitleFromTextField == "" && Double(newCategoryBudgetedStringFromTextField) == oldCategory.budgeted {
                
                failureWithWarning(message: "The category is already budgeted $\(String(format: doubleFormatKey, oldCategory.budgeted))")
                
                
            // *** Was category blank and amount not convertible to a Double?
            } else if newCategoryTitleFromTextField == "" && Double(newCategoryBudgetedStringFromTextField) == nil {
                
                failureWithWarning(message: "You have to enter a number.")
                
            
            // ***** All impossible entries are taken care of.
            } else {
                
                // Sets new Category budgeted amount to an actual amount
                if let newCategoryBudgetedDouble = Double(newCategoryBudgetedStringFromTextField) {
                    
                    newCategoryBudgeted = newCategoryBudgetedDouble
                    
                } else {
                    
                    newCategoryBudgeted = oldCategory.budgeted
                    
                }
                
                
                // *** Was the amount entered less than 0?
                if newCategoryBudgeted < 0.0 {
                    
                    failureWithWarning(message: "You have to enter a positive amount")
                    
                    
                    
                    
                // ****************
                // Everything is properly set:
                // 1) The category is not being given the same information.
                // 2) The amount is a double and isn't negative.
                // ****************
                    
                } else {
                    
                    
                    // ***** Checks the fields to assign appropriate Alert and Success messages
                    
                    var alertMessage = String()
                    var successMessage = String()
                    
                    
                    // ***** If only amount changed: Sets new category to old category.
                    
                    if newCategoryTitleFromTextField == "" || newCategoryTitleFromTextField == oldCategoryTitle {
                        
                        newCategoryTitle = oldCategoryTitle

                        alertMessage = "Update '\(oldCategoryTitle)' with $\(String(format: doubleFormatKey, newCategoryBudgeted))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully updated with $\(String(format: doubleFormatKey, newCategoryBudgeted))!"
                        
                        
                    // ***** If only name changed: Sets new category budgeted to old category budgeted.
                    } else if newCategoryBudgetedStringFromTextField == "" {
                        
                        newCategoryBudgeted = oldCategory.budgeted
                        
                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!"
                        
                        
                    // ***** If both change: Sets new budgeted amount to text field input.
                    } else {

                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)', and change budgeted amount from $\(String(format: doubleFormatKey, oldCategory.budgeted)) to $\(String(format: doubleFormatKey, newCategoryBudgeted))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)', and the budgeted amount of $\(String(format: doubleFormatKey, oldCategory.budgeted)) was changed to $\(String(format: doubleFormatKey, newCategoryBudgeted))!"
                        
                    }
                    
                    // ***** Alert message to pop up to confirmation
                    
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
        
        self.editCategoryButton.layer.cornerRadius = 27
        self.editCategoryButton.layer.masksToBounds = true
        self.editCategoryButton.layer.borderWidth = 1
        self.editCategoryButton.layer.borderColor = lightGreenColor.cgColor

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
