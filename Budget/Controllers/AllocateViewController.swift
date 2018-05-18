//
//  AllocateViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/19/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AllocateViewController: UIViewController, UITextFieldDelegate, ChooseCategory {

    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var isToCategory = true
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var allocateButton: UIButton!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var toCategoryLabel: UILabel!
    
    @IBOutlet weak var toCategoryView: UIView!
    
    @IBOutlet weak var fromCategoryLabel: UILabel!
    
    @IBOutlet var fromCategoryView: UIView!
    
    @IBOutlet weak var fromCategoryCurrentBalanceLabel: UILabel!
    
    @IBOutlet weak var toCategoryCurrentBalanceLabel: UILabel!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    func updateCategoryBalanceLabel(for categoryName: String, atLabel: UILabel) {
        
        guard let selectedCategory = loadSpecificCategory(named: categoryName) else { return }
        
        atLabel.text = "Left: \(convertedAmountToDollars(amount: selectedCategory.available))"
        
    }
    
    func updateUIElementsBecauseOfSuccess(forFromCategory: String, forToCategory: String) {
        
        // Success notification haptic
        let successHaptic = UINotificationFeedbackGenerator()
        successHaptic.notificationOccurred(.success)
        
        // Update Left label at top right & balance labels
        updateCategoryBalanceLabel(for: forFromCategory, atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: forToCategory, atLabel: toCategoryCurrentBalanceLabel)
        
        // Clear text field
        amountTextField.text = nil
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func allocateButton(_ sender: UIButton) {
        submitAllocateForReview()
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    // *** Allocate Check
    
    // Error Check
    
    func submitAllocateForReview () {
        
        guard let amountAsText = amountTextField.text else { return }
        
        guard let toCategorySelectedName = toCategoryLabel.text else { return }
        
        // Allocation submitted, with the amount being the default set budgeted amount
        if amountAsText == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount.")
            
            
            // Allocation submitted, with the amount being specifically set
        } else if let amount = Double(amountAsText) {
            
            guard let unallocatedCategory = loadSpecificCategory(named: unallocatedKey) else { return }
            
            if (unallocatedCategory.available - amount) < 0 {
                
                failureWithWarning(label: warningLabel, message: "You don't have enough funds left that.")
                
            } else if amount <= 0 {
                
                failureWithWarning(label: warningLabel, message: "The amount can't be negative.")
                
            } else {
                
                showAlertToConfirmAllocate(amount: amount, toCategory: toCategorySelectedName)
                
            }
            
        } else {
            
            failureWithWarning(label: warningLabel, message: "You can't have letters for the amount.")
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmAllocate(amount: Double, toCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Allocate \(self.convertedAmountToDollars(amount: amount)) to \(toCategory)?", preferredStyle: .alert)
        
        // Success!!! Adds specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: unallocatedKey, to: toCategory)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) allocated to \(toCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: unallocatedKey, forToCategory: toCategory)
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    func setCategory(category: String) {
        
        if isToCategory == true {
            
            toCategoryLabel.text = category
            
            updateCategoryBalanceLabel(for: category, atLabel: toCategoryCurrentBalanceLabel)
            
        } else if isToCategory == false {
            
            fromCategoryLabel.text = category
            
            updateCategoryBalanceLabel(for: category, atLabel: fromCategoryCurrentBalanceLabel)
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == moveFundsToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            if isToCategory == true {
                
                guard let currentCategory = toCategoryLabel.text else { return }
                
                categoryPickerVC.selectedCategory = currentCategory
                
            } else if isToCategory == false {
                
                guard let currentCategory = fromCategoryLabel.text else { return }
                
                categoryPickerVC.selectedCategory = currentCategory
                
            }
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    @objc func amountTapped() {
        
        amountTextField.becomeFirstResponder()
        
    }
    
    @objc func toCategoryTapped() {
        
        isToCategory = true
        
        performSegue(withIdentifier: moveFundsToCategoryPickerSegueKey, sender: self)
        
    }
    
    @objc func fromCategoryTapped() {
        
        isToCategory = false
        
        performSegue(withIdentifier: moveFundsToCategoryPickerSegueKey, sender: self)
        
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc override func dismissNumberKeyboard() {
        
        amountTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: amountTextField)
        
    }
    
    // Swipe to close keyboard
    @objc func closeKeyboardFromSwipe() {
        
        self.view.endEditing(true)
        
    }
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // Test for submitability
    func submissionFromKeyboardReturnKey(specificTextField: UITextField) {
        
        if amountTextField.text != "" {
            
            submitAllocateForReview()
            
        } else {
            specificTextField.resignFirstResponder()
        }
        
    }
    
    // Submit for review of final submitability
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        submissionFromKeyboardReturnKey(specificTextField: textField)
        
        return true
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
        
        let amountViewTap = UITapGestureRecognizer(target: self, action: #selector(amountTapped))
        let toCategoryViewTap = UITapGestureRecognizer(target: self, action: #selector(toCategoryTapped))
        let fromCategoryViewTap = UITapGestureRecognizer(target: self, action: #selector(fromCategoryTapped))
        
        // Add tap gesture to textfields and their labels
        amountView.addGestureRecognizer(amountViewTap)
        toCategoryView.addGestureRecognizer(toCategoryViewTap)
        fromCategoryView.addGestureRecognizer(fromCategoryViewTap)
        
        
        addToolBarToNumberPad(textField: amountTextField)
        
        
        // Add swipe gesture to close keyboard
        
        let closeKeyboardGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.closeKeyboardFromSwipe))
        closeKeyboardGesture.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(closeKeyboardGesture)
        
        
        budget.sortCategoriesByKey(withUnallocated: true)
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        toCategoryLabel.text = unallocatedKey
        fromCategoryLabel.text = unallocatedKey
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: fromCategoryCurrentBalanceLabel)
        updateCategoryBalanceLabel(for: budget.sortedCategoryKeys[0], atLabel: toCategoryCurrentBalanceLabel)
        
        addCircleAroundButton(named: allocateButton)
      
        self.amountTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
    }
    
    
    
    
    
    
    
    

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AllocateViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}

















