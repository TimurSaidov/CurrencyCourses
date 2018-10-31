//
//  ConverterViewController.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class ConverterViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var textFieldFrom: UITextField!
    @IBOutlet weak var buttonFrom: UIButton!
    @IBOutlet weak var imageFrom: UIImageView!
    @IBOutlet weak var textFieldTo: UITextField!
    @IBOutlet weak var buttonTo: UIButton!
    @IBOutlet weak var imageTo: UIImageView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func unwindToConvert(segue: UIStoryboardSegue) {
    }
    
    @IBAction func pushFromAction(_ sender: UIButton) {
        let navController = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        (navController.viewControllers.first! as! SelectCurrencyTableViewController).flagCurrency = .from
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func pushToAction(_ sender: UIButton) {
        let navController = storyboard?.instantiateViewController(withIdentifier: "selectedCurrencyNSID") as! UINavigationController
        (navController.viewControllers.first! as! SelectCurrencyTableViewController).flagCurrency = .to
        present(navController, animated: true, completion: nil)
    }
    
    @IBAction func textFromEditingChanged(_ sender: UITextField) {
        let amount = Double(textFieldFrom.text!) 
        textFieldTo.text = Model.shared.conver(amount: amount)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        textFieldFrom.resignFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldFrom.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationItem.rightBarButtonItem = nil
        
        refreshButtons()
        
        dateLabel.text = "Course for the date: \(Model.shared.currentDate)"
        textFromEditingChanged(textFieldFrom)
    }
    
    func refreshButtons() {
        buttonTo.setTitle(Model.shared.toCurrency.CharCode, for: .normal)
        buttonFrom.setTitle(Model.shared.fromCurrency.CharCode, for: .normal)
    }
    
    // При нажатии на любое место View, клавиатура Text Field'а убирается.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        navigationItem.rightBarButtonItem = nil
    }
}

extension ConverterViewController: UITextFieldDelegate {
    // Этот метод вызывается в тот момент, когда начинается редактирование поля textField.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        doneButton.tintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
        navigationItem.rightBarButtonItem = doneButton
        
        return true // true - редактирование возможно. false - редактирование запрещено.
    }
}