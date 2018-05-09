//
//  EditTransactionDateViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/27/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class EditTransactionDateViewController: UIViewController, ChooseDate {

    
    // *****
    // MARK: - Variables
    // *****
    
    var currentTransaction = budget.transactions[editableTransactionIndex]
    
    var date = Date()
    
    var dateFormatYYYYMMDD = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var leftLabelOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var leftAmountAtTopRight: UILabel!
    
    @IBOutlet weak var editingItemLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var dateView: UIView!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var updateItemButton: UIButton!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateItem(_ sender: UIButton) {
        changeDateSubmittedForReview()
    }
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    func showAlertToConfirmUpdate(newMonth: Int, newDay: Int, newYear: Int) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Change transaction date to \(newMonth)/\(newDay)/\(newYear)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            let newID = convertedDateComponentsToTransactionID(year: newYear, month: newMonth, day: newDay)
            
            let updatedTransaction = budget.transactions[editableTransactionIndex]
            
            updatedTransaction.id = Int64(newID)
            
            budget.updateTransaction(named: updatedTransaction, forOldTransactionAtIndex: editableTransactionIndex)
            
            self.successHaptic()
            
            budget.sortTransactionsDescending()
            
            // Finds the index where this new transactionID is located, in order to set it to the current 'editableTransactionIndex' for the main 'EditTransactions' VC.
            if let newTransactionIndex = budget.transactions.index(where: { $0.id == updatedTransaction.id }) {
                
                editableTransactionIndex = newTransactionIndex
                
            }
            
            self.editingItemLabel.text = "\(newMonth)/\(newDay)/\(newYear)"
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func changeDateSubmittedForReview () {
        
        let newDateDictionary = convertDateToInts(dateToConvert: date)
        guard let newMonth = newDateDictionary[monthKey] else { return }
        guard let newDay = newDateDictionary[dayKey] else { return }
        guard let newYear = newDateDictionary[yearKey] else { return }
        
        if currentTransaction.month == newMonth && currentTransaction.day == newDay && currentTransaction.year == newYear {
            
            failureWithWarning(label: warningLabel, message: "This is already the date.")
            
        } else {
            
            showAlertToConfirmUpdate(newMonth: newMonth, newDay: newDay, newYear: newYear)
            
        }
        
    }
    
    func setDate(date: Date) {
        
        self.date = date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateFormatYYYYMMDD = convertDateInfoToYYYYMMDD(year: year, month: month, day: day)
            
            dateLabel.text = "\(month)/\(day)/\(year)"
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateLeftLabelAtTopRight(barButton: leftLabelOnNavBar, unallocatedButton: leftAmountAtTopRight)
        
        self.editingItemLabel.text = "\(currentTransaction.month)/\(currentTransaction.day)/\(currentTransaction.year)"
        
        self.addCircleAroundButton(named: self.updateItemButton)
        
    }
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    

    
    

    
    
    
   
    
    

}















