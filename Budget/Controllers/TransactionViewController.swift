//
//  TransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var selectedCategory: String?

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var isNewTransaction = true
    
    var selectedTransaction: Transaction?
    
    var transactionsToDisplay = [Transaction]()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTransactionButton(_ sender: UIBarButtonItem) {
        isNewTransaction = true
        performSegue(withIdentifier: transactionsToAddOrEditTransactionSegueKey, sender: self)
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
    
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! AddOrEditTransactionViewController
        
        destinationVC.isNewTransaction = isNewTransaction
        
        if !isNewTransaction {
            
            guard let editableTransaction = selectedTransaction else { return }
            
            destinationVC.editableTransaction = editableTransaction
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedDataTable.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        
        transactionsToDisplay = loadChosenTransactions()
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        for transaction in transactionsToDisplay {
            
            print(transaction.id)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        transactionsToDisplay = loadChosenTransactions()
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        
    }
  
   
  
 
    
    
    

}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension TransactionViewController {
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return transactionsToDisplay.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as! TransactionTableViewCell
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        
        cell.accessoryType = .disclosureIndicator
        
        if !transactionsToDisplay.isEmpty {
            
            let transaction = transactionsToDisplay[indexPath.row]
            
            cell.transactionNameLabel.text = "\(transaction.title!)"
            
            if transaction.onHold == true {
                
                cell.transactionAmountLabel.text = "✋🏽 \(convertedAmountToDollars(amount: transaction.inTheAmountOf))"
                
            } else {
                
                cell.transactionAmountLabel.text = "\(convertedAmountToDollars(amount: transaction.inTheAmountOf))"
                
            }
            
            
            
            if transaction.type == depositKey {
                
                cell.transactionDateLabel.text = "\(transaction.month)/\(transaction.day)/\((transaction.year % 100))"
                
                cell.transactionCategoryLabel.text = "Deposit"
                
            } else {
                
                cell.transactionDateLabel.text = "\(transaction.month)/\(transaction.day)/\((transaction.year % 100))"
                
                cell.transactionCategoryLabel.text = "\(transaction.forCategory!)"
                
            }
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        isNewTransaction = false
        
        selectedTransaction = transactionsToDisplay[indexPath.row]
        
        performSegue(withIdentifier: transactionsToAddOrEditTransactionSegueKey, sender: self)
        
        displayedDataTable.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let transactionToDelete = transactionsToDisplay[indexPath.row]
            
            let message = "Delete \(transactionToDelete.title!) with \(convertedAmountToDollars(amount: transactionToDelete.inTheAmountOf))?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                budget.deleteTransaction(withID: Int(transactionToDelete.id))
                
                self.transactionsToDisplay.remove(at: indexPath.row)
                
                self.successHaptic()
                
                self.refreshAvailableBalanceLabel(label: self.mainBalanceLabel)
                self.displayedDataTable.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
    
    
}








