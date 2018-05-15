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
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var isNewTransaction = true
    
    var selectedTransaction: Transaction?
    
    var transactionsToDisplay = [Transaction]()
    
    
    
    // *****
    // MARK: - Header for Main Views
    // *****
    
    
    
    // *** IBOutlets
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTransactionButton(_ sender: UIBarButtonItem) {
        isNewTransaction = true
        performSegue(withIdentifier: transactionsToAddOrEditTransactionSegueKey, sender: self)
    }
    
    
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        transactionsToDisplay = loadChosenTransactions()
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        
    }
    
    
    
    
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
    // *****
    // MARK: - TableView
    // *****
    
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
                
                let selectedTransaction = self.transactionsToDisplay[indexPath.row]
                
                guard let selectedTransactionIndexPath = budget.transactions.index(of: selectedTransaction) else { return }
                
                budget.deleteTransaction(at: selectedTransactionIndexPath)
                self.transactionsToDisplay.remove(at: indexPath.row)
                
                self.successHaptic()
                
                self.refreshAvailableBalanceLabel(label: self.mainBalanceLabel)
                self.displayedDataTable.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    

    
    // *****
    // MARK: - Functions
    // *****
  
    
  
    
    
    // *****
    // MARK: - Prepare For Segue
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! AddOrEditTransactionViewController
        
        destinationVC.isNewTransaction = isNewTransaction
        
        if isNewTransaction {
            
            destinationVC.navBar.topItem?.title = "Add Transaction"
            
            destinationVC.submitTransactionButton.setTitle("Add Withdrawal", for: .normal)
            
        } else {
            
            destinationVC.navBar.topItem?.title = "Edit Transaction"
            
            guard let editableTransaction = selectedTransaction else { return }
            
            destinationVC.editableTransaction = editableTransaction
            
            guard let type = editableTransaction.type else { return }
            guard let name = editableTransaction.title else { return }
            guard let category = editableTransaction.forCategory else { return }
            
            destinationVC.transactionSegmentedControl.selectedSegmentIndex = (type == withdrawalKey ? 0 : 1)
            destinationVC.transactionNameTextField.text = name
            destinationVC.transactionAmountTextField.text = "\(convertedAmountToDouble(amount: editableTransaction.inTheAmountOf)))"
            destinationVC.dateLabel.text = "\(editableTransaction.month)/\(editableTransaction.day)/\(editableTransaction.year)"
            destinationVC.categoryLabel.text = category
            destinationVC.holdToggle.isOn = editableTransaction.onHold

            destinationVC.submitTransactionButton.setTitle("Save Changes", for: .normal)
            
        }
        
    }
    
    
    
    
    
    
    

}








