//
//  EditTransactionCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionCategoryViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    

    var currentTransaction = budget.transactions[editableTransactionIndex]
    var newCategorySelected = String()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    

    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var editingItemAmountLabel: UILabel!
    
    
    
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    
    
    
    // MARK: - Picker
    
    @IBOutlet weak var newCategoryPicker: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return budget.sortedCategoryKeys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: budget.sortedCategoryKeys[row], attributes: [NSAttributedStringKey.foregroundColor:UIColor.white])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        newCategorySelected = budget.sortedCategoryKeys[row]
        
        guard let currentCategory = loadSpecificCategory(named: budget.sortedCategoryKeys[row]) else { return }
        
        leftInCategoryLabel.text = "~ Left in \(newCategorySelected): \(convertedAmountToDollars(amount: currentCategory.available)) ~"
        
        warningLabel.text = ""
    }
    
    
    
    
    
    func showAlertToConfirmUpdate(newCategoryName: String) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction category from \"\(currentTransaction.forCategory!)\" to \"\(newCategoryName)\"?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let updatedTransaction = budget.transactions[editableTransactionIndex]
            
            updatedTransaction.forCategory = newCategoryName
            
            budget.updateTransaction(named: updatedTransaction, forOldTransactionAtIndex: editableTransactionIndex)
            
            // Finds the index where this new transactionID is located, in order to set it to the current 'editableTransactionIndex' for the main 'EditTransactions' VC.
            if let newTransactionIndex = budget.transactions.index(where: { $0.id == updatedTransaction.id }) {
                
                editableTransactionIndex = newTransactionIndex
                
            }
            
            self.editingItemLabel.text = updatedTransaction.forCategory
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeCategorySubmittedForReview () {
        
        let indexOfNewCategory = newCategoryPicker.selectedRow(inComponent: 0)
        let newSelectedCategoryName = budget.sortedCategoryKeys[indexOfNewCategory]
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if newSelectedCategoryName == currentTransaction.forCategory {
            
            failureWithWarning(label: warningLabel, message: "The category is already set to \(currentTransaction.forCategory!)")
            
        } else if currentTransaction.inTheAmountOf > newCategoryItself.available {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
        } else {
            
            showAlertToConfirmUpdate(newCategoryName: newSelectedCategoryName)
            
        }
        
    }
    
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    @IBAction func updateItem(_ sender: UIButton) {
        
        changeCategorySubmittedForReview()
        
    }
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        self.newCategorySelected = currentTransaction.forCategory!
        
        guard let indexOfCurrentCategory = budget.sortedCategoryKeys.index(of: self.newCategorySelected) else { return }
        self.newCategoryPicker.selectRow(indexOfCurrentCategory, inComponent: 0, animated: true)
        
        
        self.editingItemLabel.text = "\(currentTransaction.forCategory!)"
        self.editingItemAmountLabel.text = "~ Transaction amount: \(convertedAmountToDollars(amount: currentTransaction.inTheAmountOf)) ~"
        
        if let currentCategory = loadSpecificCategory(named: currentTransaction.forCategory!) {
            
            self.leftInCategoryLabel.text = "~ Left in \(currentTransaction.forCategory!): \(convertedAmountToDollars(amount: currentCategory.available)) ~"
            
        }
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
