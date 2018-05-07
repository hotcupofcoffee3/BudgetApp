//
//  TransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var editableTransactionIndex = Int()

var selectedCategory: String?
var selectedStartDate: Date?
var selectedEndDate: Date?

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var transactionsToDisplay = [Transaction]()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBAction func addTransactionButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: transactionsToAddTransactionSegueKey, sender: self)
    }
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        return budget.transactions.count
        return transactionsToDisplay.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        cell.accessoryType = .disclosureIndicator
        
        if !transactionsToDisplay.isEmpty {
//            let transaction = budget.transactions[indexPath.row]
            let transaction = transactionsToDisplay[indexPath.row]
            cell.textLabel?.text = "\(transaction.title!): \(convertedAmountToDollars(amount: transaction.inTheAmountOf))"
            
            if transaction.type == depositKey {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): Deposit"
            } else {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): \(transaction.forCategory!)"
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let selectedTransaction = transactionsToDisplay[indexPath.row]
        
        guard let selectedTransactionIndexPath = budget.transactions.index(of: selectedTransaction) else { return }
        
        editableTransactionIndex = selectedTransactionIndexPath
        
        performSegue(withIdentifier: editTransactionSegueKey, sender: self)
        
        displayedDataTable.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
//            let transactionToDelete = budget.transactions[indexPath.row]
            let transactionToDelete = transactionsToDisplay[indexPath.row]
            
            let message = "Delete \(transactionToDelete.title!) with \(convertedAmountToDollars(amount: transactionToDelete.inTheAmountOf))?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                let selectedTransaction = self.transactionsToDisplay[indexPath.row]
                
                guard let selectedTransactionIndexPath = budget.transactions.index(of: selectedTransaction) else { return }
                
                budget.deleteTransaction(at: selectedTransactionIndexPath)
                self.transactionsToDisplay.remove(at: indexPath.row)
                
                self.successHaptic()
                
                self.refreshAvailableBalanceLabel(label: self.availableBalanceLabel)
                self.displayedDataTable.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transactionsToDisplay = loadChosenTransactions()
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
        for transaction in transactionsToDisplay {
            
            print(transaction.id)
            
        }
        
    }
    
    @objc func swipe() {
        
        performSegue(withIdentifier: transactionsToCategoriesSegueKey, sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        transactionsToDisplay = loadChosenTransactions()
        
        refreshAvailableBalanceLabel(label: availableBalanceLabel)
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
