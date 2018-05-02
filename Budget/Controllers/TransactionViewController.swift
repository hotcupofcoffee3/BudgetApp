//
//  TransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

var editableTransactionIndex = Int()

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func refreshAvailableBalanceLabel() {
        availableBalanceLabel.text = "$\(String(format: doubleFormatKey, budget.balance))"
    }
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBAction func addTransactionButton(_ sender: UIButton) {
        performSegue(withIdentifier: transactionsToAddTransactionSegueKey, sender: self)
    }
    
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.transactions.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = displayedDataTable.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath)
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 0.0)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        cell.accessoryType = .disclosureIndicator
        
        if !budget.transactions.isEmpty {
            let transaction = budget.transactions[indexPath.row]
            cell.textLabel?.text = "\(transaction.title!): $\(String(format: doubleFormatKey, transaction.inTheAmountOf))"
            
            if transaction.type == depositKey {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): \(depositKey)"
            } else {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): \(transaction.forCategory!)"
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        editableTransactionIndex = indexPath.row
        
        performSegue(withIdentifier: editTransactionSegueKey, sender: self)
        
        displayedDataTable.deselectRow(at: indexPath, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            func deleteTransaction() {
                budget.deleteTransaction(at: indexPath.row)
                displayedDataTable.reloadData()
                refreshAvailableBalanceLabel()
            }
            
            let transactionToDelete = budget.transactions[indexPath.row]
            
            let message = "Delete \(transactionToDelete.title!) with $\(String(format: doubleFormatKey, transactionToDelete.inTheAmountOf))?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                budget.deleteTransaction(at: indexPath.row)
                
                self.refreshAvailableBalanceLabel()
                budget.sortCategoriesByKey(withUnallocated: true)
                self.displayedDataTable.reloadData()
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func addSomething(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            self.performSegue(withIdentifier: transactionsToAddCategorySegueKey, sender: self)
            
        })

        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
            
            self.performSegue(withIdentifier: transactionsToAddTransactionSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Move Funds", style: .default) { (action) in
            
            self.performSegue(withIdentifier: transactionsToMoveFundsSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAvailableBalanceLabel()
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
        
        
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe))
        rightSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(rightSwipe)
        
    }
    
    @objc func swipe() {
        
        performSegue(withIdentifier: transactionsToCategoriesSegueKey, sender: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        refreshAvailableBalanceLabel()
        displayedDataTable.reloadData()
        displayedDataTable.separatorStyle = .none
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
