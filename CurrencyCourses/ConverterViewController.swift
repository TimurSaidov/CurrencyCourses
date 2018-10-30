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
    
    @IBAction func pushFromAction(_ sender: UIButton) {
    }
    
    @IBAction func pushToAction(_ sender: UIButton) {
    }
    
    @IBAction func textFromEditingChanged(_ sender: UITextField) {
        let amount = Double(textFieldFrom.text!) 
        textFieldTo.text = Model.shared.conver(amount: amount)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        refreshButtons()
    }
    
    func refreshButtons() {
        buttonTo.setTitle(Model.shared.toCurrency.CharCode, for: .normal)
        buttonFrom.setTitle(Model.shared.fromCurrency.CharCode, for: .normal)
    }
}
