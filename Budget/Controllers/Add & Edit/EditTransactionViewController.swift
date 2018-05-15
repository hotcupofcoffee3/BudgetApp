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
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let editableTransaction = loadSpecificTransaction(idSubmitted: editableTransactionID) else { return }
        
        print(editableTransaction.id)
        
        currentTransaction = editableTransaction
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        self.updateLabelsForCurrentTransaction(withID: editableTransactionID)
        
        self.titleLabel.text = currentTransaction.title
        self.addCircleAroundButton(named: self.editTitleButton)
        self.addCircleAroundButton(named: self.editAmountButton)
        self.addCircleAroundButton(named: self.editDateButton)
        self.addCircleAroundButton(named: self.editCategoryButton)
        self.onHoldToggleSwitch.isOn = currentTransaction.onHold
        
        let onHoldTap = UITapGestureRecognizer(target: self, action: #selector(toggleOnHold))
        onHoldView.addGestureRecognizer(onHoldTap)
        
        if currentTransaction.type == depositKey {
            
            editCategoryButton.isEnabled = false
            editCategoryButton.alpha = 0.5
            categoryLabel.isEnabled = false
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.updateBalanceAndUnallocatedLabelsAtTop(barButton: balanceOnNavBar, unallocatedButton: unallocatedLabelAtTop)
        self.updateLabelsForCurrentTransaction(withID: editableTransactionID)
        
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
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
    
    @IBOutlet weak var onHoldView: UIView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
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
    
    @objc func toggleOnHold() {
        
        onHoldToggleSwitch.isOn = !onHoldToggleSwitch.isOn
        
        currentTransaction.onHold = !currentTransaction.onHold
        
        budget.updateBalanceAndAvailableForOnHold(forTransaction: currentTransaction)
        
        saveData()
        
    }
    
    
    
    
    
    
    
   
    
    

    
    
    
  

  
    
}



















