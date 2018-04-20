//
//  TransactionViewController.swift
//  Budget
//
//  Created by Adam Moore on 4/5/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class TransactionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func refreshAvailableBalanceLabel() {
        if let availableBalance = budget.categories[uncategorizedKey] {
            availableBalanceLabel.text = "$\(String(format: doubleFormatKey, availableBalance.available))"
        }
    }
    
    var transactionNames = [String]()
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    @IBOutlet weak var displayedDataTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return budget.transactions.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "TransactionCell")
        
        cell.backgroundColor = UIColor.init(red: 70/255, green: 109/255, blue: 111/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        if !budget.transactions.isEmpty {
            let transaction = budget.transactions[indexPath.row]
            cell.textLabel?.text = "\(transaction.title): $\(String(format: doubleFormatKey, transaction.inTheAmountOf))"
            
            if transaction.type == .deposit {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): \(depositKey)"
            } else {
                cell.detailTextLabel?.text = "\(transaction.month)/\(transaction.day)/\(transaction.year): \(transaction.forCategory)"
            }

        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            func deleteTransaction() {
                budget.deleteTransaction(at: indexPath.row)
                displayedDataTable.reloadData()
                refreshAvailableBalanceLabel()
            }
            
            let transactionToDelete = budget.transactions[indexPath.row]
            
            let message = "Delete \(transactionToDelete.title) with $\(String(format: doubleFormatKey, transactionToDelete.inTheAmountOf))?"
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                
                budget.deleteTransaction(at: indexPath.row)
                
                self.refreshAvailableBalanceLabel()
                budget.sortCategoriesByKey(withUncategorized: false)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        refreshAvailableBalanceLabel()
        displayedDataTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
