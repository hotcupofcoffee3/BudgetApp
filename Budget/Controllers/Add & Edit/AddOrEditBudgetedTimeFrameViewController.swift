//
//  AddOrEditBudgetedTimeFrameViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditBudgetedTimeFrameViewController: UIViewController, ChooseDate {
    
    
    
    // *****
    // MARK: - Variables
    // *****
    
    var isAddingNewItem = true
    
    var isStart = true
    
    var startDate = Date()
    
    var endDate = Date()
    
    
    
    // *****
    // MARK: - Header for Add & Main Edit Views
    // *****
    
    // *** IBOutlets
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var addTimeFrameButton: UIButton!
    
    
    
    // *** IBActions
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addTimeFrame(_ sender: UIButton) {
        submitAddTimeFrameForReview()
    }
    

    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedBudgetedTimeFrames()
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
        let startDateViewTap = UITapGestureRecognizer(target: self, action: #selector(startDateTapped))
        let endDateViewTap = UITapGestureRecognizer(target: self, action: #selector(endDateTapped))
        
        startDateView.addGestureRecognizer(startDateViewTap)
        endDateView.addGestureRecognizer(endDateViewTap)
        
        addCircleAroundButton(named: addTimeFrameButton)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
    }
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startDateView: UIView!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var endDateView: UIView!
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Functions
    // *****
    
    // *** Taps
    
    @objc func startDateTapped() {
        
        isStart = true
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func endDateTapped() {
        
        isStart = false
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    
    
    // *** Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
                
            datePickerVC.date = isStart ? startDate : endDate
          
        }
        
    }
    
    
    
    // *** Delegate Method
    
    func setDate(date: Date) {
        
        startDate = isStart ? date : startDate
        
        endDate = isStart ? endDate : date
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            if isStart {
                
                startDateLabel.text = "\(month)/\(day)/\(year)"
                
            } else {
                
                endDateLabel.text = "\(month)/\(day)/\(year)"
                
            }
            
        }
        
    }
    
    
    
    // *** Submit
    
    func submitAddTimeFrameForReview () {
        
        let startDateDict = convertDateToInts(dateToConvert: startDate)
        guard let startMonth = startDateDict[monthKey] else { return }
        guard let startDay = startDateDict[dayKey] else { return }
        guard let startYear = startDateDict[yearKey] else { return }
        
        let endDateDict = convertDateToInts(dateToConvert: endDate)
        guard let endMonth = endDateDict[monthKey] else { return }
        guard let endDay = endDateDict[dayKey] else { return }
        guard let endYear = endDateDict[yearKey] else { return }
        
        let startDateYYYYMMDD = convertDateInfoToYYYYMMDD(year: startYear, month: startMonth, day: startDay)
        let endDateYYYYMMDD = convertDateInfoToYYYYMMDD(year: endYear, month: endMonth, day: endDay)
        
        let startID = convertedDateToBudgetedTimeFrameID(timeFrame: startDate, isEnd: false)
        let endID = convertedDateToBudgetedTimeFrameID(timeFrame: endDate, isEnd: true)
        
        
        if startDateYYYYMMDD > endDateYYYYMMDD {
            
            failureWithWarning(label: warningLabel, message: "The start date cannot be later than the end date.")
            
        } else {
            
            for period in budget.budgetedTimeFrames {
                
                let periodStartID = Int(period.startDateID)
                let periodEndID = Int(period.endDateID)
                
                if startID >= periodStartID && startID <= periodEndID {
                    
                    failureWithWarning(label: warningLabel, message: "The start date is in the range of another budgeted time frame.\nThe time frames cannot overlap.")
                    return
                    
                } else if endID >= periodStartID && endID <= periodEndID {
                    
                    failureWithWarning(label: warningLabel, message: "The end date is in the range of another budgeted time frame.\nThe time frames cannot overlap.")
                    return
                    
                }
                
            }
            
            showAlertToConfirm(startID: startID, startYear: startYear, startMonth: startMonth, startDay: startDay, endYear: endYear, endMonth: endMonth, endDay: endDay)
            
        }
        
    }
    
    func showAlertToConfirm(startID: Int, startYear: Int, startMonth: Int, startDay: Int, endYear: Int, endMonth: Int, endDay: Int) {
        
        // *** Alert message to pop up to confirmation
        
        let alert = UIAlertController(title: nil, message: "Add new budgeted time frame:\n\(startMonth)/\(startDay)/\(startYear) - \(endMonth)/\(endDay)/\(endYear)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            budget.addTimeFrame(start: self.startDate, end: self.endDate)
            
            createAndSaveNewSetOfBudgetItemsWithCategories(startDateID: startID)
            
            self.successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    


}

















