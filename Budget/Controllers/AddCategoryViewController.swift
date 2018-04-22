//
//  AddCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit
import Foundation

class AddCategoryViewController: UIViewController, UITextFieldDelegate {
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        if let uncategorized = budget.categories[uncategorizedKey] {
            leftAmountAtTopRight.text = "Left: $\(String(format: doubleFormatKey, uncategorized.available))"
        }
    }
    
    // MARK: Update elements because of success
    
    func updateUIElementsBecauseOfSuccess() {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right & current balance
        updateLeftLabelAtTopRight()
        // Update Left label at top right
        updateLeftLabelAtTopRight()
        
        // Set text fields back to being empty
        categoryNameTextField.text = nil
        categoryBudgetedAmountTextField.text = nil
        
    }
    
    // MARK: Failure message
    
    func failureWithWarning(message: String) {
        
        // Warning notification haptic
        let warningHaptic = UINotificationFeedbackGenerator()
        warningHaptic.notificationOccurred(.error)
        
        categoryWarningLabel.textColor = UIColor.red
        categoryWarningLabel.text = message
        
    }
    
    @IBOutlet weak var categoryNameTextField: UITextField!
    
    @IBOutlet weak var categoryBudgetedAmountTextField: UITextField!
    
    @IBOutlet weak var categoryWarningLabel: UILabel!
    
    @IBOutlet weak var addCategoryButton: UIButton!
    
    @IBAction func addCategory(_ sender: UIButton) {
        
        if let categoryName = categoryNameTextField.text, let categoryAmount = categoryBudgetedAmountTextField.text {
            
            if categoryName == "" || categoryAmount == "" {
                
               failureWithWarning(message: "You have to complete all fields.")
                
            } else {
                
                // Success
                if let categoryAmount = Double(categoryAmount){
                    
                    let alert = UIAlertController(title: nil, message: "Create category named \"\(categoryName)\" with a budgeted amount of $\(String(format: doubleFormatKey, categoryAmount))?", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                        
                        budget.addCategory(named: categoryName, withThisAmount: categoryAmount)
                        
                        self.categoryWarningLabel.textColor = successColor
                        self.categoryWarningLabel.text = "\"\(categoryName)\" with a budgeted amount of $\(String(format: doubleFormatKey, categoryAmount)) has been added."

                        self.updateUIElementsBecauseOfSuccess()
                        
                    }))
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    
                    present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    failureWithWarning(message: "You have to enter a number for the amount.")
                    
                }
                
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLeftLabelAtTopRight()
        
        addCategoryButton.layer.cornerRadius = 18
        addCategoryButton.layer.masksToBounds = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLeftLabelAtTopRight()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Keyboard dismissals
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
