//
//  TransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShowTransactionsForBudgetItem {
    
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - Declared
    // *****
    
    var isNewTransaction = true
    
    var selectedTransaction: Transaction?
    
    var selectedCategory: String?
    
    var transactionsToDisplay = [Transaction]()
    
    var budgetItemForTransaction: String?
    
    var selectedBudgetTimeFrameStartID = Int()
    
    var selectedBudgetTimeFrameEndID = Int()
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var addTransactionBarButton: UIBarButtonItem!
    
    @IBOutlet weak var mainBalanceLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func addTransactionButton(_ sender: UIBarButtonItem) {
        
        isNewTransaction = true
        
        performSegue(withIdentifier: transactionsToAddOrEditTransactionSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // MARK: - Submissions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    func loadTransactionsForBudgetItem(startID: Int, endID: Int, itemName: String) {

        transactionsToDisplay = loadTransactionsByBudgetItem(start: startID, end: endID, itemName: itemName)

    }
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! AddOrEditTransactionViewController
        
        destinationVC.isNewTransaction = isNewTransaction
        
        if let budgetItemName = budgetItemForTransaction {
            
            destinationVC.budgetItemForTransaction = budgetItemName
            
            destinationVC.canChooseAnyCategory = false
            
        } else {
            
            destinationVC.canChooseAnyCategory = true
            
        }
        
        if !isNewTransaction {
            
            guard let editableTransaction = selectedTransaction else { return }
            
            destinationVC.editableTransaction = editableTransaction
            
        }
        
        destinationVC.transactionPeriodStartID = selectedBudgetTimeFrameStartID
        
        destinationVC.transactionPeriodEndID = selectedBudgetTimeFrameEndID
        
        destinationVC.delegate = self
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.displayedDataTable.register(UINib(nibName: "TransactionTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionCell")
        
        refreshAvailableBalanceLabel(label: mainBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        // If the transactions displayed comes from the 'BudgetItems' VC, then it is enabled.
        // Otherwise, if it comes from the 'Categories' VC, then the 'selectedCategory' is true, and it is disabled.
        addTransactionBarButton.isEnabled = (selectedCategory == nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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








