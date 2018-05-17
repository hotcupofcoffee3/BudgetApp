//
//  AddOrEditBudgetedTimeFrameViewController.swift
//  Budget
//
//  Created by Adam Moore on 5/14/18.
//  Copyright © 2018 Adam Moore. All rights reserved.
//

import UIKit

class AddOrEditBudgetedTimeFrameViewController: UIViewController, ChooseDate {
    
    
    
    // ******************************************************
    
    // MARK: - Variables
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - Declared
    // *****
    
    var isNewBudgetTimeFrame = true
    
    var editableBudgetTimeFrame: Period?
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    var isStart = true
    
    var startDate = Date()
    
    var endDate = Date()
    
    
    
    // *****
    // Mark: - IBOutlets
    // *****
    
    @IBOutlet weak var balanceOnNavBar: UIBarButtonItem!
    
    @IBOutlet weak var unallocatedLabelAtTop: UILabel!
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitTimeFrameButton: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startDateView: UIView!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var endDateView: UIView!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // Mark: - General Functions
    // *****
    
    
    
    
    
    // *****
    // Mark: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTimeFrame(_ sender: UIButton) {
        submitTimeFrameForReview()
    }
    
    
    
    // *****
    // Mark: - Submissions
    // *****
    
    // ************************************************************************************************
    // ************************************************************************************************
    /*
     
     Add Or Edit Section
     
     */
    // ************************************************************************************************
    // ************************************************************************************************
    
    
    
    // **************************************
    // ***** Add Budgeted Time Frame
    // **************************************
    
    
    func submitTimeFrameForReview () {
        
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
            
            if isNewBudgetTimeFrame {
                
                showAlertToConfirmAddition(startID: startID, startYear: startYear, startMonth: startMonth, startDay: startDay, endYear: endYear, endMonth: endMonth, endDay: endDay)
                
            } else {
                
                showAlertToConfirmEdits()
                
            }
            
        }
        
    }
    
    // *** Alert to confirm adding a budgeted time frame.
    
    func showAlertToConfirmAddition(startID: Int, startYear: Int, startMonth: Int, startDay: Int, endYear: Int, endMonth: Int, endDay: Int) {
        
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
    
    
    
    
    
    
    // **************************************
    // ***** Edit Budgeted Time Frame
    // **************************************
    
    // *** Only the Alert for edits shows, as the check for review is the same for adding or editing the budgeted time frames.
    
    func showAlertToConfirmEdits() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return }
        
        var updatedItemsConfirmationMessage = ""
        
        
        // Start Date
        let newStartDate = startDate
        var changeStartDate = false
        
        let currentStartDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
        
        let currentStartDict = convertDateToInts(dateToConvert: newStartDate)
        
        guard let startYear = currentStartDict[yearKey] else { return }
        guard let startMonth = currentStartDict[monthKey] else { return }
        guard let startDay = currentStartDict[dayKey] else { return }
        
        if newStartDate != currentStartDate {
            changeStartDate = true
            updatedItemsConfirmationMessage += "Change Start Date to: \(startMonth)/\(startDay)/\(startYear)\n"
        }
        
        
        // End Date
        let newEndDate = startDate
        var changeEndDate = false
        
        let currentEndDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
        
        let currentEndDict = convertDateToInts(dateToConvert: newEndDate)
        
        guard let endYear = currentEndDict[yearKey] else { return }
        guard let endMonth = currentEndDict[monthKey] else { return }
        guard let endDay = currentEndDict[dayKey] else { return }
        
        if newEndDate != currentEndDate {
            changeEndDate = true
            updatedItemsConfirmationMessage += "Change End Date to: \(endMonth)/\(endDay)/\(endYear)"
        }
        
        
        // Final check to see if there is anything to change.
        if !changeStartDate && !changeEndDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            let alert = UIAlertController(title: nil, message: updatedItemsConfirmationMessage, preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                
                if changeStartDate {
                    budget.updateStartDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newStartDate: newStartDate)
                }
                
                if changeEndDate {
                    budget.updateEndDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newEndDate: newEndDate)
                }
                
                self.successHaptic()
                
                self.dismiss(animated: true, completion: nil)
                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Delegates
    // *****
    
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
    
    
    
    // *****
    // Mark: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = isStart ? startDate : endDate
            
        }
        
    }
    
    
    
    // *****
    // Mark: - Tap Functions
    // *****
    
    @objc func startDateTapped() {
        
        isStart = true
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    @objc func endDateTapped() {
        
        isStart = false
        
        performSegue(withIdentifier: addOrEditBudgetToDatePickerSegueKey, sender: self)
        
    }
    
    
    
    // *****
    // Mark: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if isNewBudgetTimeFrame {
            
            startDate = Date()
            endDate = Date()
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add New Time Frame"
            
            submitTimeFrameButton.setTitle("Add Time Frame", for: .normal)
            
        } else {
            
            backButton.title = "Cancel"
            
            navBar.topItem?.title = "Edit Time Frame"
            
            guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return }
            
            startDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
            
            endDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
            
            submitTimeFrameButton.setTitle("Save Changes", for: .normal)
            
        }
        
        
        
        loadSavedBudgetedTimeFrames()
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
        let startDateViewTap = UITapGestureRecognizer(target: self, action: #selector(startDateTapped))
        let endDateViewTap = UITapGestureRecognizer(target: self, action: #selector(endDateTapped))
        
        startDateView.addGestureRecognizer(startDateViewTap)
        endDateView.addGestureRecognizer(endDateViewTap)
        
        addCircleAroundButton(named: submitTimeFrameButton)
        
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let dateFormat = DateFormatter()
        dateFormat.dateStyle = .short
        
        startDateLabel.text = dateFormat.string(from: startDate)
        endDateLabel.text = dateFormat.string(from: endDate)
        
    }
    
  
    
    


}



// **************************************************************************************************
// **************************************************************************************************
// **************************************************************************************************



extension AddOrEditBudgetedTimeFrameViewController {
    
    
    
    // ******************************************************
    
    // MARK: - Table/Picker
    
    // ******************************************************
    
    
    
    
}

















