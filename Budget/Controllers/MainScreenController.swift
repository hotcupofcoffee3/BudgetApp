//
//  MainScreen.swift
//  Budget
//
//  Created by Adam Moore on 4/3/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class MainScreen: UIViewController {
    
    @IBOutlet weak var hiddenDeleteButton: UIButton!
    
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
    
    @IBAction func addSomething(_ sender: UIButton) {
        
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
        categoriesButtonTitle.layer.borderWidth = 2
        categoriesButtonTitle.layer.borderColor = tealColor.cgColor
        
        transactionsButtonTitle.layer.cornerRadius = 35
        transactionsButtonTitle.layer.masksToBounds = true
        transactionsButtonTitle.layer.borderWidth = 2
        transactionsButtonTitle.layer.borderColor = tealColor.cgColor
        
        
        // Long press gesture recognizer
        let uilpr = UILongPressGestureRecognizer(target: self, action: #selector(MainScreen.longpress(gestureRecognizer:)))
        
        uilpr.minimumPressDuration = 2
        
        hiddenDeleteButton.addGestureRecognizer(uilpr)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        refreshAvailableBalanceLabel()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // Long press recognizer function
    @objc func longpress(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Only does it once, even if it is held down for longer.
        // If this isn't done, then it'll keep adding a new one of these every 2 seconds (the amount of time we have it set).
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            
            let alert = UIAlertController(title: nil, message: "Delete EVERYTHING?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
                budget.deleteEVERYTHING()
                self.refreshAvailableBalanceLabel()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    

}
