//
//  EditTransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionViewController: UIViewController {
    
    var currentTransaction = budget.transactions[editableTransactionIndex]

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Update Amounts At Top
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    func updateLeftLabelAtTopRight() {
        
        leftLabelOnNavBar.title = "$\(String(format: doubleFormatKey, budget.balance))"
        
        guard let unallocated = budget.categories[unallocatedKey] else { return }
        leftAmountAtTopRight.text = "Unallocated: $\(String(format: doubleFormatKey, unallocated.available))"
    }
    
    @IBOutlet weak var typeLabel: UILabel!
    
    // MARK: - Update Labels for Current Transaction
    
    func updateLabelsForCurrentTransaction(at index: Int) {
        
        let currentTransaction = budget.transactions[index]
        
        titleLabel.text = currentTransaction.title
        amountLabel.text = "$\(String(format: doubleFormatKey, currentTransaction.inTheAmountOf))"
        dateLabel.text = "\(currentTransaction.month)/\(currentTransaction.day)/\(currentTransaction.year)"
        categoryLabel.text = currentTransaction.forCategory
        
        if currentTransaction.type == .deposit {
            typeLabel.text = "Deposit"
            changeTypeButton.setTitle("Change to Withdrawal", for: .normal)
        } else {
            typeLabel.text = "Withdrawal"
            changeTypeButton.setTitle("Change to Deposit", for: .normal)
        }
        
    }
    
    
    
    // MARK: - Title
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var editTitleButton: UIButton!
    
    @IBAction func editTitle(_ sender: UIButton) {
        print(titleLabel.text!)
    }
    
    
    // MARK: - Amount
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var editAmountButton: UIButton!
    
    @IBAction func editAmount(_ sender: UIButton) {
        print(amountLabel.text!)
    }
    
    // MARK: - Date
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var editDateButton: UIButton!
    
    @IBAction func editDate(_ sender: UIButton) {
        print(dateLabel.text!)
    }
    
    
    
    // MARK: - Category
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var editCategoryButton: UIButton!
    
    @IBAction func editCategory(_ sender: UIButton) {
        print(categoryLabel.text!)
    }
    
    
    // MARK: - Change Type Button
    
    @IBOutlet weak var changeTypeButton: UIButton!
    
    @IBAction func changeType(_ sender: UIButton) {
        print(currentTransaction.type)
    }
    
    
    // MARK: - Button Formatter
    func addCircleAroundButton(named button: UIButton) {
        
        button.layer.cornerRadius = 27
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = lightGreenColor.cgColor
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLeftLabelAtTopRight()
        self.updateLabelsForCurrentTransaction(at: editableTransactionIndex)

        self.titleLabel.text = currentTransaction.title
        self.addCircleAroundButton(named: self.editTitleButton)
        self.addCircleAroundButton(named: self.editAmountButton)
        self.addCircleAroundButton(named: self.editDateButton)
        self.addCircleAroundButton(named: self.editCategoryButton)
        self.addCircleAroundButton(named: self.changeTypeButton)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}








