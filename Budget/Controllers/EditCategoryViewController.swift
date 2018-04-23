//
//  EditCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/22/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryViewController: UIViewController {
    
    var currentCategoryNameString = String()
    var currentCategoryAmountDouble = Double()
    var warningMessage = String()
    var alertMessage = String()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateLabelsAtTop() {
        if let currentCategory = budget.categories[currentCategoryNameString] {
            currentCategoryName.text = "New Category"
            currentCategoryAmount.text = "\(String(format: doubleFormatKey, currentCategory.budgeted))"
        }
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess(forFromCategory: String, forToCategory: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        
        
        
        // TODO: Add success label stuff here
        
        
        
        
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
            
            var newCategoryTitle = ""
            var newCategoryBudgeted = Double()
            
            guard let oldCategory = budget.categories[oldCategoryTitle] else { return }
            

            // ***** Are the fields empty?
            if newCategoryTitleFromTextField == "" && newCategoryBudgetedStringFromTextField == "" {
                
                failureWithWarning(message: "There is nothing to update.")
                
                
            // ***** Was the new category entered the same as the one already set?
            } else if oldCategoryTitle == newCategoryTitleFromTextField && newCategoryBudgetedStringFromTextField == "" {
                
                failureWithWarning(message: "The category is already named '\(currentCategoryName)'")
            
                
            // *** Was the category left blank and an amount entered?
            } else if newCategoryTitleFromTextField == "" && newCategoryBudgetedStringFromTextField != "" {
                
                
                // *** Was the amount entered convertible to a Double?
                if let newCategoryBudgetedDouble = Double(newCategoryBudgetedStringFromTextField) {
                    
                    
                    // *** Was the amount entered less than 0?
                    if newCategoryBudgetedDouble < 0.0 {
                        
                        failureWithWarning(message: "You have to enter a positive amount")
                        
                        
                    // *** Was the amount entered the same as is already budgeted?
                    } else if newCategoryBudgetedDouble == oldCategory.budgeted {
                        
                        failureWithWarning(message: "This is the same amount already budgeted.")
                        
                    }
                
                
                // *** Was the amount entered something OTHER than an amount convertible to a Double?
                } else {
                    
                    failureWithWarning(message: "You have to enter a number.")
                    
                }
                
                
            // *** If everything is set properly:
            } else {
                
                
                // This is only done if the above errors are not met:
                // 1) Both of the fields are not empty.
                // 2) The new category entered is not equal to a category already created.
                // 3) If the category was left blank (and therefore only updating the amount), the amount is different from what was set.
                
                
                // Sets new category to old category if empty.
                if newCategoryTitleFromTextField == "" {
                    
                    newCategoryTitle = oldCategoryTitle
                    
                }
                
                // Sets budgeted amount if empty, or converts budgeted amount String to Double.
                if newCategoryBudgetedStringFromTextField == "" {
                    
                    newCategoryBudgeted = oldCategory.budgeted
                    
                } else if let newBudgtedAsDouble = Double(newCategoryBudgetedStringFromTextField) {
                    
                    newCategoryBudgeted = newBudgtedAsDouble
                    
                }
                
                // TODO: Add warning label popup to confirm:
                
                let alert = UIAlertController(title: nil, message: "", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                    
                    
                    
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                present(alert, animated: true, completion: nil)
                
                // Update Category function called & local variables for labels set
                
                budget.updateCategory(named: oldCategoryTitle, updatedNewName: newCategoryTitle, andNewBudgetedAmount: newCategoryBudgeted)
                self.currentCategoryNameString = newCategoryTitle
                self.currentCategoryAmountDouble = newCategoryBudgeted
                
                // *** If only amount updated...
                if oldCategoryTitle == newCategoryTitle && oldCategory.budgeted != newCategoryBudgeted {
                    
                    // TODO: Success message - "Old category was updated with amount $0.00"
                
                    
                    
                // *** If only the title was updated...
                } else if oldCategoryTitle != newCategoryTitle && oldCategory.budgeted == newCategoryBudgeted {
                    
                    // TODO: Success message - "Old category was changed to new category, still with a budgeted amount of $0.00"
                    
                    
                    
                // *** If both were changed
                } else {
                    
                    // TODO: Success message - "Old category with a budgeted amount of $0.00 was changed to New category with a budgeted amount of $0.00"
                    
                }
                
            }
            
        }
        
    }
    
    @IBOutlet weak var editCategoryButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        currentCategoryName.text = editableCategoryName
        
        if let currentCategory = budget.categories[editableCategoryName] {
            
            self.currentCategoryNameString = editableCategoryName
            self.currentCategoryAmountDouble = currentCategory.budgeted
            
            currentCategoryAmount.text = "$\(String(format: doubleFormatKey, currentCategory.budgeted))"
            
        }
        
        self.editCategoryButton.layer.cornerRadius = 18
        self.editCategoryButton.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
