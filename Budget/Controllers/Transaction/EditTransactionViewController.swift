//
//  EditTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionViewController: UIViewController {
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var currentTransaction: Transaction!
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var editTitleButton: UIButton!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var editAmountButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var editDateButton: UIButton!
    
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var editCategoryButton: UIButton!
    
    @IBOutlet weak var onHoldToggleSwitch: UISwitch!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editTitle(_ sender: UIButton) {
        performSegue(withIdentifier: editTransactionTitleSegueKey, sender: self)
    }
    
    @IBAction func editAmount(_ sender: UIButton) {
        performSegue(withIdentifier: editTransactionAmountSegueKey, sender: self)
    }
    
    @IBAction func editDate(_ sender: UIButton) {
        performSegue(withIdentifier: editTransactionDateSegueKey, sender: self)
    }
    
    @IBAction func editCategory(_ sender: UIButton) {
        performSegue(withIdentifier: editTransactionCategorySegueKey, sender: self)
    }
    
    @IBAction func onHoldToggle(_ sender: UISwitch) {
        
        currentTransaction.onHold = !currentTransaction.onHold
        
        budget.updateBalanceAndAvailableForOnHold(forTransaction: currentTransaction)
        
        saveData()
        
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func updateLabelsForCurrentTransaction(withID id: Int) {
        
        guard let currentTransaction = loadSpecificTransaction(idSubmitted: id) else { return }
        
        titleLabel.text = currentTransaction.title
        amountLabel.text = "\(convertedAmountToDollars(amount: currentTransaction.inTheAmountOf))"
        dateLabel.text = "\(currentTransaction.month)/\(currentTransaction.day)/\(currentTransaction.year)"
        categoryLabel.text = currentTransaction.forCategory
        
        if currentTransaction.type == depositKey {
            typeLabel.text = "Deposit"
        } else {
            typeLabel.text = "Withdrawal"
        }
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editableTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
        
        print(editableTransaction.id)
        
        currentTransaction = editableTransaction
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        self.updateLabelsForCurrentTransaction(withID: editableTransactionID)
        
        self.titleLabel.text = currentTransaction.title
        self.addCircleAroundButton(named: self.editTitleButton)
        self.addCircleAroundButton(named: self.editAmountButton)
        self.addCircleAroundButton(named: self.editDateButton)
        self.addCircleAroundButton(named: self.editCategoryButton)
        self.onHoldToggleSwitch.isOn = currentTransaction.onHold
        
        if currentTransaction.type == depositKey {
            
            editCategoryButton.isEnabled = false
            editCategoryButton.alpha = 0.5
            categoryLabel.isEnabled = false
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        self.updateLabelsForCurrentTransaction(withID: editableTransactionID)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    

    
    
    
  

  
    
}



















