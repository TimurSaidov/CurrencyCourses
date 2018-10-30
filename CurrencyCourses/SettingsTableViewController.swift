//
//  SettingsTableViewController.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    var isDatePickerShown: Bool = false
    let datePickerCellIndexPath = IndexPath(row: 1, section: 0)
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func valueChanged(_ sender: UIDatePicker) {
        updateDate()
        doneButtonState()
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        Model.shared.loadXMLFile(desiredDate: datePicker.date)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        doneButtonState()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerCellIndexPath:
            if isDatePickerShown {
                return 216
            } else {
                return 0
            }
        default:
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (datePickerCellIndexPath.section, datePickerCellIndexPath.row - 1):
            if isDatePickerShown {
                isDatePickerShown = false
            } else {
                isDatePickerShown = true
                
                updateDate()
            }
        default:
            isDatePickerShown = false
        }
        tableView.reloadData()
    }
    
    func updateDate() {
        dateLabel.text = CourseDateFormatter.dateFormatter.string(from: datePicker.date)
        
        print(datePicker.date)
        print(CourseDateFormatter.dateFormatter.string(from: datePicker.date))
    }
    
    func doneButtonState() {
        if dateLabel.text == "" {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
}
