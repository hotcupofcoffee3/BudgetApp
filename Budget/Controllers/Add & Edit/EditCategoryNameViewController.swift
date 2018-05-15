//
//  EditCategoryNameViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/4/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditCategoryNameViewController: UIViewController, UITextFieldDelegate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentCategoryNameString = String()
    
    
    
    // *****
    // MARK: - Header for Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        submitEditCategoryNameForReview()
    }
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentCategoryNameString = editableCategoryName
        
        
        // MARK: Add tap gesture to textfields and their labels
        
        let nameViewTap = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        
        editNameView.addGestureRecognizer(nameViewTap)
        
        
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        self.currentCategoryName.text = currentCategoryNameString
        self.addCircleAroundButton(named: self.updateItemButton)
        
        self.newCategoryName.delegate = self
        
        
        // MARK: - Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var currentCategoryName: UILabel!
    
    @IBOutlet weak var editNameView: UIView!
    
    @IBOutlet weak var newCategoryName: UITextField!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
    
    
    
    
    // *****
    // MARK: - PickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - DatePickerView
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    
    // *** Edit Category Name Check
    
    // Name Error Check
    
    func submitEditCategoryNameForReview() {
        
        if let oldCategoryName = currentCategoryName.text, let newCategoryNameFromTextField = newCategoryName.text {
            
            // *** Is the field empty?
            if newCategoryNameFromTextField == "" {
                
                failureWithWarning(label: warningLabel, message: "There is nothing to update.")
                
                
                // *** Is the new category name equal to "Unallocated"?
            } else if newCategoryNameFromTextField == unallocatedKey {
                
                failureWithWarning(label: warningLabel, message: "You cannot rename a category to \"Unallocated\"")
                
                
                // *** Was the new category entered the same as the one already set?
            } else if oldCategoryName == newCategoryNameFromTextField {
                
                failureWithWarning(label: warningLabel, message: "The category is already named '\(currentCategoryNameString)'")
                
                
                // *** All impossible entries are taken care of.
            } else {
                
                for categoryName in budget.sortedCategoryKeys {
                    
                    if categoryName == newCategoryNameFromTextField {
                        
                        failureWithWarning(label: warningLabel, message: "There is already a category named '\(categoryName)'")
                        
                        return
                        
                    }
                    
                }
                
                // *** Alert message to pop up to confirmation
                
                showAlertToConfirmEditCategoryName(oldCategoryName: oldCategoryName, newCategoryName: newCategoryNameFromTextField)
                
            }
            
        }
        
    }
    
    // Name Alert Confirmation
    
    func showAlertToConfirmEditCategoryName(oldCategoryName: String, newCategoryName: String) {
        
        let alert = UIAlertController(title: nil, message: "Change '\(oldCategoryName)' to '\(newCategoryName)'?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            var oldAmount = Double()
            
            if let oldCategory = loadSpecificCategory(named: oldCategoryName) {
                
                oldAmount = oldCategory.budgeted
                
            }
            
            budget.updateCategory(named: oldCategoryName, updatedNewName: newCategoryName, andNewAmountAdded: oldAmount)
            
            
            // Update the UI elements with the new info
            self.currentCategoryNameString = newCategoryName
            
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
            self.currentCategoryName.text = newCategoryName
            
            self.successHaptic()
            
            editableCategoryName = newCategoryName
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    @objc func nameTapped() {
        
        newCategoryName.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitEditCategoryNameForReview()
        return true
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }

    

    
}













