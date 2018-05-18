//
//  MoveFundsViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/19/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class MoveFundsViewController: UIViewController, UITextFieldDelegate, ChooseCategory {

    
    
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
    
    @IBOutlet weak var moveFundsButtonTitle: UIButton!
    
    @IBOutlet weak var allocateRemoveOrShift: UISegmentedControl!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var fundsTextField: UITextField!
    
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
        fundsTextField.text = nil
        
    }
    
    func updateUIForAllocate() {
        
        moveFundsButtonTitle.setTitle("Allocate Funds", for: .normal)
        
        // Enable 'To' & disable 'From'
        fromCategoryLabel.isEnabled = false
        toCategoryLabel.isEnabled = true
        
        
        // Set disabled 'from' picker to "Uncategorized"
        fromCategoryLabel.text = unallocatedKey
        
        // Update 'from' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: unallocatedKey, atLabel: fromCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForRemove() {
        
        moveFundsButtonTitle.setTitle("Remove Funds", for: .normal)
        
        // Disable 'To' & enable 'From'
        fromCategoryLabel.isEnabled = true
        toCategoryLabel.isEnabled = false
        
        
        
        // Set disabled 'to' picker to 'Uncategorized'
        toCategoryLabel.text = unallocatedKey
        
        // Update 'to' balance label to 'Uncategorized'
        updateCategoryBalanceLabel(for: unallocatedKey, atLabel: toCategoryCurrentBalanceLabel)
        
    }
    
    func updateUIForShift() {
        
        moveFundsButtonTitle.setTitle("Shift Funds", for: .normal)
        
        // Disable 'To' & enable 'From'
        fromCategoryLabel.isEnabled = true
        toCategoryLabel.isEnabled = true
        
    }
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func moveFundsButton(_ sender: UIButton) {
        submitAllOptionsForReview()
    }
    
    @IBAction func allocateRemoveOrShiftSwitch(_ sender: UISegmentedControl) {
        
        if allocateRemoveOrShift.selectedSegmentIndex == 0 {
            
            updateUIForAllocate()
            
        } else if allocateRemoveOrShift.selectedSegmentIndex == 1 {
            
            updateUIForRemove()
            
        } else if allocateRemoveOrShift.selectedSegmentIndex == 2 {
            
            updateUIForShift()
            
        }
        
        fundsTextField.resignFirstResponder()
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    // *** Allocate Check
    
    // Error Check
    
    func submitAllocateForReview (amountFromTextField: String) {
        
        guard let toCategorySelectedName = toCategoryLabel.text else { return }
        
        // Allocation submitted, with the amount being the default set budgeted amount
        if amountFromTextField == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount.")
            
            
            // Allocation submitted, with the amount being specifically set
        } else if let amount = Double(amountFromTextField) {
            
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
    
    
    // *** Remove Check
    
    // Error Check
    
    func submitRemoveForReview (amountFromTextField: String) {
        
        guard let fromCategorySelectedName = fromCategoryLabel.text else { return }
        
        guard let selectedCategory = loadSpecificCategory(named: fromCategorySelectedName) else { return }
        
        // Removal submitted, with the amount being the default set budgeted amount
        if amountFromTextField == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount.")
            
            
            // Removal submitted, with the amount being specifically set
        } else if let amount = Double(amountFromTextField) {
            
            if (selectedCategory.available - amount) < 0 {
                
                failureWithWarning(label: warningLabel, message: "You don't have enough funds in there for that.")
                
            } else if amount <= 0 {
                
                failureWithWarning(label: warningLabel, message: "The amount has to be greater than 0.")
                
            } else {
                
                showAlertToConfirmRemove(amount: amount, fromCategory: fromCategorySelectedName)
                
            }
            
        } else {
            
            failureWithWarning(label: warningLabel, message: "You can't have letters for the amount.")
            
        }
        
    }
    
    
    // Alert Confirmation
    
    func showAlertToConfirmRemove(amount: Double, fromCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Remove \(self.convertedAmountToDollars(amount: amount)) from \(fromCategory)?", preferredStyle: .alert)
        
        // Success!!! Removes specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: fromCategory, to: unallocatedKey)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) removed from \(fromCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategory, forToCategory: unallocatedKey)
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // *** Shift Check
    
    // Error Check
    
    func submitShiftForReview (amountFromTextField: String) {
        
        guard let fromCategorySelectedName = fromCategoryLabel.text else { return }
        
        guard let toCategorySelectedName = fromCategoryLabel.text else { return }
        
        
        if fundsTextField.text == "" {
            
            failureWithWarning(label: warningLabel, message: "You have to enter an amount first.")
            
        } else {
            
            if let amount = Double(amountFromTextField) {
                
                guard let fromCategory = loadSpecificCategory(named: fromCategorySelectedName) else { return }
                
                if (fromCategory.available - amount) < 0 {
                    
                    failureWithWarning(label: warningLabel, message: "You don't enough to shift from this category.")
                    
                } else if amount <= 0 {
                    
                    failureWithWarning(label: warningLabel, message: "The amount has to be greater than 0.")
                    
                } else {
                    
                    showAlertToConfirmShift(amount: amount, fromCategory: fromCategorySelectedName, toCategory: toCategorySelectedName)
                    
                }
                
            } else {
                
                failureWithWarning(label: warningLabel, message: "You can't use letters for the amount.")
                
            }
            
        }
        
    }
    
    // Alert Confirmation
    
    func showAlertToConfirmShift(amount: Double, fromCategory: String, toCategory: String) {
        
        let alert = UIAlertController(title: nil, message: "Shift \(self.convertedAmountToDollars(amount: amount)) from \(fromCategory) to \(toCategory)?", preferredStyle: .alert)
        
        // Adds specified amount
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.shiftFunds(withThisAmount: amount, from: fromCategory, to: toCategory)
            
            self.warningLabel.textColor = successColor
            self.warningLabel.text = "\(self.convertedAmountToDollars(amount: amount)) shifted from \(fromCategory) to \(toCategory)"
            
            self.successHaptic()
            
            self.updateUIElementsBecauseOfSuccess(forFromCategory: fromCategory, forToCategory: toCategory)
            self.updateBalanceAndUnallocatedLabelsAtTop(barButton: self.balanceOnNavBar, unallocatedButton: self.unallocatedLabelAtTop)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    // *** Consolidated function for when the "Move Funds" button is pressed or "Done" is pressed.
    
    func submitAllOptionsForReview() {
        
        fundsTextField.resignFirstResponder()
        
        guard let amountFromTextField = fundsTextField.text else { return }
        
        
        // *** Allocate
        if allocateRemoveOrShift.selectedSegmentIndex == 0 {
            
            submitAllocateForReview(amountFromTextField: amountFromTextField)
            
            
            // *** Remove
        } else if allocateRemoveOrShift.selectedSegmentIndex == 1 {
            
            submitRemoveForReview(amountFromTextField: amountFromTextField)
            
            
            // *** Shift
        } else if allocateRemoveOrShift.selectedSegmentIndex == 2 {
            
            submitShiftForReview(amountFromTextField: amountFromTextField)
            
            
        }
        
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
        
        fundsTextField.becomeFirstResponder()
        
    }
    
    @objc func toCategoryTapped() {
        
        if allocateRemoveOrShift.selectedSegmentIndex != 1 {
            
            isToCategory = true
            
            performSegue(withIdentifier: moveFundsToCategoryPickerSegueKey, sender: self)
            
        }
        
    }
    
    @objc func fromCategoryTapped() {
        
        if allocateRemoveOrShift.selectedSegmentIndex != 0 {
            
            isToCategory = false
            
            performSegue(withIdentifier: moveFundsToCategoryPickerSegueKey, sender: self)
            
        }
        
    }
    
    // 'Done' button on number pad to submit for review of final submitability
    @objc override func dismissNumberKeyboard() {
        
        fundsTextField.resignFirstResponder()
        submissionFromKeyboardReturnKey(specificTextField: fundsTextField)
        
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
        
        if fundsTextField.text != "" {
            
            submitAllOptionsForReview()
            
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
        
        
        addToolBarToNumberPad(textField: fundsTextField)
        
        
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
        
        addCircleAroundButton(named: moveFundsButtonTitle)
        
        updateUIForAllocate()
        
        self.fundsTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        
        updateUIForAllocate()
        
    }
    
    
    
    
    
    
    
    

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension MoveFundsViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}

















