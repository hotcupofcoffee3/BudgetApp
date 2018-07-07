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
    // MARK: - Declared
    // *****
    
    var isNewBudgetTimeFrame = true
    
    var editableBudgetTimeFrame: Period?
    
    var startDateFormatYYYYMMDD = Int()
    
    var endDateFormatYYYYMMDD = Int()
    
    var isStart = true
    
    var startDate = Date()
    
    var endDate = Date()
    
    let isFirstTime = (UserDefaults.standard.object(forKey: isSetUpKey) == nil) ? true : false
    
    
    
    // *****
    // MARK: - IBOutlets
    // *****
    
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var submitTimeFrameButton: UIButton!
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var startDateLabel: UILabel!
    
    @IBOutlet weak var startDateView: UIView!
    
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var endDateView: UIView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    
    // ******************************************************
    
    // MARK: - Functions
    
    // ******************************************************
    
    
    
    // *****
    // MARK: - General Functions
    // *****
    
    func convertDateToDateLabelText(date: Date) -> String {
        
        var dateAsLabelText = String()
        
        var dateDict = convertDateToInts(dateToConvert: date)
        
        if let year = dateDict[yearKey], let month = dateDict[monthKey], let day = dateDict[dayKey] {
            
            dateAsLabelText = "\(month)/\(day)/\(year)"
            
        }
        
        return dateAsLabelText
        
    }
    
    func updateDateLabels(withDate date: Date) {
        
        if isStart {
            
            if date >= endDate {
                
                endDate = convertEndDateToOneDayAfterStartDate(startDate: startDate)
                
            }
            
        } else {
            
            if date <= startDate {
                
                startDate = convertStartDateToOneDayBeforeEndDate(endDate: endDate)
                
            }
            
        }
        
        startDateLabel.text = convertDateToDateLabelText(date: startDate)
        endDateLabel.text = convertDateToDateLabelText(date: endDate)
        
    }
    
    
    
    // *****
    // MARK: - IBActions
    // *****
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitTimeFrame(_ sender: UIButton) {
        submitTimeFrameForReview()
    }
    
    
    
    // *****
    // MARK: - Submissions
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
        
        let startID = convertDateToBudgetedTimeFrameID(timeFrame: startDate, isEnd: false)
        let endID = convertDateToBudgetedTimeFrameID(timeFrame: endDate, isEnd: true)
        
        
        if startDateYYYYMMDD > endDateYYYYMMDD {
            
            failureWithWarning(label: warningLabel, message: "The start date cannot be later than the end date.")
            
        } else {
            
            let periods = loadSavedBudgetedTimeFrames()
            
            for period in periods {
                
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
                
                if isFirstTime {
                    
                    let currentDateAsPeriodID = convertDateToBudgetedTimeFrameID(timeFrame: Date(), isEnd: false)
                    
                    if startID > currentDateAsPeriodID || endID < currentDateAsPeriodID {
                        
                        failureWithWarning(label: warningLabel, message: "The starting period has to include the current date.")
                        return
                        
                    }
                    
                }
                
                addBudgetedTimeFrameSubmission(startID: startID, startYear: startYear, startMonth: startMonth, startDay: startDay, endYear: endYear, endMonth: endMonth, endDay: endDay)
                
            } else {
                
                editSubmission()
                
            }
            
        }
        
    }
    
    // *** Add Budgeted Time Frame Submission.
    
    func addBudgetedTimeFrameSubmission(startID: Int, startYear: Int, startMonth: Int, startDay: Int, endYear: Int, endMonth: Int, endDay: Int) {
        
        addNewPeriod(start: startDate, end: endDate)
        
        successHaptic()
        
        if isFirstTime {
            
//            performSegue(withIdentifier: addOrEditPeriodToAddOrEditPaycheckSegueKey, sender: self)
            
        } else {
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    
    
    
    // **************************************
    // ***** Edit Budgeted Time Frame
    // **************************************
    
    // *** Only the Confirmation for edits shows, as the check for review is the same for adding or editing the budgeted time frames.
    
    func editSubmission() {
        
        // *** Add in all checks to see if something has been changed or not, then pop up alert message with specific items to update.
        // *** Alert only shows actual changes being made.
        
        guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return }
        
        
        // Start Date
        let newStartDate = startDate
        var changeStartDate = false
        
        let currentStartDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
       
        if newStartDate != currentStartDate {
            changeStartDate = true
        }
        
        
        // End Date
        let newEndDate = startDate
        var changeEndDate = false
        
        let currentEndDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
        
        if newEndDate != currentEndDate {
            changeEndDate = true
        }
        
        
        // Final check to see if there is anything to change.
        if !changeStartDate && !changeEndDate {
            
            failureWithWarning(label: warningLabel, message: "There is nothing to update.")
            
        } else {
            
            if changeStartDate {
                budget.updateStartDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newStartDate: newStartDate)
            }
            
            if changeEndDate {
                budget.updateEndDate(currentStartID: Int(currentBudgetTimeFrame.startDateID), newEndDate: newEndDate)
            }
            
            successHaptic()
            
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Delegates
    // *****
    
    func setDate(date: Date) {
        
        startDate = isStart ? date : startDate
        
        endDate = isStart ? endDate : date

        updateDateLabels(withDate: date)
        
    }
    
    
    
    // *****
    // MARK: - Segues
    // *****
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == addOrEditBudgetToDatePickerSegueKey {
            
            let datePickerVC = segue.destination as! DatePickerViewController
            
            datePickerVC.delegate = self
            
            datePickerVC.date = isStart ? startDate : endDate
            
        }
        
    }
    
    
    
    // *****
    // MARK: - Tap Functions
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
    // MARK: - Keyboard functions
    // *****
    
    
    
    
    
    // *****
    // MARK: - Loadables
    // *****
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNewBudgetTimeFrame {
            
            startDate = Date()
            endDate = convertEndDateToOneDayAfterStartDate(startDate: Date())
            
            backButton.title = "Back"
            
            navBar.topItem?.title = "Add New Time Frame"
            
            submitTimeFrameButton.setTitle("Add Time Frame", for: .normal)
            
            if isFirstTime {
                
                instructionsLabel.text = "Add a Starting Budget Period.\n\nToday's date has to be within the date range."
                
            } else {
                
                instructionsLabel.text = ""
                
            }
            
        } else {
            
            instructionsLabel.text = ""
            
            backButton.title = "Cancel"
            
            navBar.topItem?.title = "Edit Time Frame"
            
            guard let currentBudgetTimeFrame = editableBudgetTimeFrame else { return print("It didn't work") }
            
            startDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.startYear), month: Int(currentBudgetTimeFrame.startMonth), day: Int(currentBudgetTimeFrame.startDay))
            
            endDate = convertComponentsToDate(year: Int(currentBudgetTimeFrame.endYear), month: Int(currentBudgetTimeFrame.endMonth), day: Int(currentBudgetTimeFrame.endDay))
            
            submitTimeFrameButton.setTitle("Save Changes", for: .normal)
            
        }
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
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

















