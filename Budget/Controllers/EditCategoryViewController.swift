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
        
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
        
        guard let unallocated = budget.categories[unallocatedKey] else { return }
        leftAmountAtTopRight.text = "Unallocated: $\(String(format: doubleFormatKey, unallocated.available))"
    }
    
    func updateLabelsAtTop() {
        
        if let currentCategory = budget.categories[currentCategoryNameString] {
            
            currentCategoryName.text = currentCategoryNameString
            currentCategoryAmount.text = "$\(String(format: doubleFormatKey, currentCategory.available))"
            
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
        
        if let oldCategoryTitle = currentCategoryName.text, let newCategoryTitleFromTextField = newCategoryName.text, let newCategoryAvailableStringFromTextField = newCategoryAmount.text {
            
            var newCategoryTitle = newCategoryTitleFromTextField
            var newCategoryAvailable = Double()
            
            guard let oldCategory = budget.categories[oldCategoryTitle] else { return }
            

            // ***** Are the fields empty?
            if newCategoryTitleFromTextField == "" && newCategoryAvailableStringFromTextField == ""  {
                
                failureWithWarning(message: "There is nothing to update.")
               
                
            // ***** Do both fields have info, and it is the exact same as the current info?
            } else if newCategoryTitleFromTextField == oldCategoryTitle && Double(newCategoryAvailableStringFromTextField) == oldCategory.available {
                
                failureWithWarning(message: "This is the same information that is already set.")
                
                
            // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryTitleFromTextField == unallocatedKey {
                
                failureWithWarning(message: "You cannot rename a category to \"Unallocated\"")
                
                
            // ***** Was the new category entered the same as the one already set, if not amount changed?
            } else if oldCategoryTitle == newCategoryTitleFromTextField && newCategoryAvailableStringFromTextField == "" {
                
                failureWithWarning(message: "The category is already named '\(currentCategoryNameString)'")
                
                
            // *** Was the amount entered the same as is already budgeted?
            } else if newCategoryTitleFromTextField == "" && Double(newCategoryAvailableStringFromTextField) == oldCategory.available {
                
                failureWithWarning(message: "The category is already budgeted $\(String(format: doubleFormatKey, oldCategory.available))")
                
                
            // *** Was category blank and amount not convertible to a Double?
            } else if newCategoryTitleFromTextField == "" && Double(newCategoryAvailableStringFromTextField) == nil {
                
                failureWithWarning(message: "You have to enter a number.")
                
            
            // ***** All impossible entries are taken care of.
            } else {
                
                guard let unallocated = budget.categories[unallocatedKey] else { return }
                
                // Sets new Category budgeted amount to an actual amount
                if let newCategoryAvailableDouble = Double(newCategoryAvailableStringFromTextField) {
                    
                    newCategoryAvailable = newCategoryAvailableDouble
                    
                } else {
                    
                    newCategoryAvailable = oldCategory.available
                    
                }
                
                
                // *** Was the amount entered less than 0?
                if newCategoryAvailable < 0.0 {
                    
                    failureWithWarning(message: "You have to enter a positive amount")
                    
                // *** If there was not enough unallocated funds available.
                } else if newCategoryAvailable > (unallocated.available + oldCategory.available) {
                    
                    failureWithWarning(message: "You don't have enough unallocated funds for this")
                    
                    
                // ****************
                // Everything is properly set:
                // 1) The category is not being given the same information.
                // 2) The amount is a double and isn't negative.
                // ****************
                    
                } else {
                    
                    
                    // *** Checks the fields to assign appropriate Alert and Success messages
                    
                    var alertMessage = String()
                    var successMessage = String()
                    
                    
                    // *** If only amount changed: Sets new category to old category.
                    
                    if newCategoryTitleFromTextField == "" || newCategoryTitleFromTextField == oldCategoryTitle {
                        
                        newCategoryTitle = oldCategoryTitle
                        
                        // Add the old amount back into "Unallocated", then take out the new amount.
                        unallocated.available += oldCategory.available
                        unallocated.available -= newCategoryAvailable

                        alertMessage = "Update '\(oldCategoryTitle)' with $\(String(format: doubleFormatKey, newCategoryAvailable))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully updated with $\(String(format: doubleFormatKey, newCategoryAvailable))!"
                        
                        
                    // ***** If only name changed: Sets new category budgeted to old category budgeted.
                    } else if newCategoryAvailableStringFromTextField == "" {
                        
                        newCategoryAvailable = oldCategory.available
                        
                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)'?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)'!"
                        
                        
                    // ***** If both change: Sets new budgeted amount to text field input.
                    } else {
                        
                        // Add the old amount back into "Unallocated", then take out the new amount.
                        unallocated.available += oldCategory.available
                        unallocated.available -= newCategoryAvailable

                        alertMessage = "Change '\(oldCategoryTitle)' to '\(newCategoryTitle)', and change budgeted amount from $\(String(format: doubleFormatKey, oldCategory.available)) to $\(String(format: doubleFormatKey, newCategoryAvailable))?"
                        
                        successMessage = "'\(oldCategoryTitle)' successfully changed to '\(newCategoryTitle)', and the budgeted amount of $\(String(format: doubleFormatKey, oldCategory.available)) was changed to $\(String(format: doubleFormatKey, newCategoryAvailable))!"
                        
                    }
                    
                    // ***** Alert message to pop up to confirmation
                    
                    let alert = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        // Update Category function called & local variables for labels set
                        
                        budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewAvailableAmount: newCategoryAvailable)
                        
                        
                        // Update the UI elements with the new info
                        self.currentCategoryNameString = newCategoryTitle
                        self.currentCategoryAmountDouble = newCategoryAvailable
                        
                        self.updateUIElementsBecauseOfSuccess(successMessage: successMessage)
                        
                        self.updateLabelsAtTop()
                        self.updateLeftLabelAtTopRight()
                        
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
        updateLeftLabelAtTopRight()
        
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
