//
//  EditTransactionCategoryViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionCategoryViewController: UIViewController, ChooseCategory {
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentTransaction: Transaction!
    
    var newCategorySelected = String()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var editingItemAmountLabel: UILabel!
    
    @IBOutlet weak var leftInCategoryLabel: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        changeCategorySubmittedForReview()
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func showAlertToConfirmUpdate(newCategoryName: String) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction category from \"\(currentTransaction.forCategory!)\" to \"\(newCategoryName)\"?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            guard let updatedTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
            
            budget.updateTransactionCategory(category: newCategoryName, withID: Int(updatedTransaction.id))
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
            self.editingItemLabel.text = updatedTransaction.forCategory
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func changeCategorySubmittedForReview () {
        
        guard let newSelectedCategoryName = categoryLabel.text else { return }
        guard let newCategoryItself = loadSpecificCategory(named: newSelectedCategoryName) else { return }
        
        if newSelectedCategoryName == currentTransaction.forCategory {
            
            failureWithWarning(label: warningLabel, message: "The category is already set to \(newSelectedCategoryName)")
            
        } else if currentTransaction.inTheAmountOf > newCategoryItself.available {
            
            failureWithWarning(label: warningLabel, message: "There are not enough funds in that category for this transaction.")
            
        } else {
            
            showAlertToConfirmUpdate(newCategoryName: newSelectedCategoryName)
            
        }
        
    }
    
    @objc func categoryTapped() {
        
        performSegue(withIdentifier: changeTransactionCategoryToCategoryPickerSegueKey, sender: self)
        
    }
    
    func setCategory(category: String) {
        newCategorySelected = category
        categoryLabel.text = newCategorySelected
        updateLeftInCategoryAmount(categoryName: category, forLabel: leftInCategoryLabel)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == changeTransactionCategoryToCategoryPickerSegueKey {
            
            let categoryPickerVC = segue.destination as! CategoryPickerViewController
            
            categoryPickerVC.delegate = self
            
            guard let currentCategory = categoryLabel.text else { return }
            
            categoryPickerVC.selectedCategory = currentCategory
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editableTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
        
        currentTransaction = editableTransaction
        
        let categoryViewTap = UITapGestureRecognizer(target: self, action: #selector(categoryTapped))
        
        categoryView.addGestureRecognizer(categoryViewTap)
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        budget.sortCategoriesByKey(withUnallocated: true)
        
        guard let currentCategory = currentTransaction.forCategory else { return }
        
        self.newCategorySelected = currentCategory
        
        self.categoryLabel.text = currentCategory
        
        self.editingItemLabel.text = "\(currentCategory)"
        self.editingItemAmountLabel.text = "~ Transaction amount: \(convertedAmountToDollars(amount: currentTransaction.inTheAmountOf)) ~"
        
        updateLeftInCategoryAmount(categoryName: currentCategory, forLabel: leftInCategoryLabel)

        self.addCircleAroundButton(named: self.updateItemButton)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    

    
    
    
 
    
    
    
    

}













