//
//  MainScreen.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class MainScreen: UIViewController {
    
    @IBOutlet weak var availableBalanceLabel: UILabel!
    
    func refreshAvailableBalanceLabel() {
        if let availableBalance = budget.categories[uncategorizedKey] {
            availableBalanceLabel.text = "$\(String(format: doubleFormatKey, availableBalance.available))"
        }
    }
    
    @IBOutlet weak var categoriesButtonTitle: UIButton!
    
    @IBOutlet weak var transactionsButtonTitle: UIButton!
    
    @IBAction func categoriesButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToCategoriesSegueKey, sender: self)
    }
    
    @IBAction func transactionsButton(_ sender: UIButton) {
        performSegue(withIdentifier: mainToTransactionsSegueKey, sender: self)
    }
    
    @IBAction func deleteEVERYTHING(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            budget.deleteEVERYTHING()
            self.refreshAvailableBalanceLabel()
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func addSomething(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            // Just so I don't forget the structure, this is the only one being left like this.
            // All the rest use the "performSegue()" function.
            
//            let addACategoryViewController = self.storyboard?.instantiateViewController(withIdentifier: addACategoryViewControllerKey) as! AddCategoryViewController
//
//            self.present(addACategoryViewController, animated: true, completion: nil)
            
            self.performSegue(withIdentifier: mainToAddCategorySegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Add Transaction", style: .default) { (action) in
          
            self.performSegue(withIdentifier: mainToAddTransactionSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Move Funds", style: .default) { (action) in
            
            self.performSegue(withIdentifier: mainToMoveFundsSegueKey, sender: self)
            
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAvailableBalanceLabel()
        loadCategories()
        loadTransactions()
        
//        for transaction in budget.transactions {
//            print(transaction.transactionID)
//        }

        categoriesButtonTitle.layer.cornerRadius = 35
        categoriesButtonTitle.layer.masksToBounds = true
        categoriesButtonTitle.layer.borderWidth = 1
        categoriesButtonTitle.layer.borderColor = UIColor.white.cgColor
        
        transactionsButtonTitle.layer.cornerRadius = 35
        transactionsButtonTitle.layer.masksToBounds = true
        transactionsButtonTitle.layer.borderWidth = 1
        transactionsButtonTitle.layer.borderColor = UIColor.white.cgColor
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

}
