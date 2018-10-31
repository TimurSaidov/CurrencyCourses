//
//  SelectCurrencyTableViewController.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 31/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

enum FlagCurrencySelected {
    case from
    case to
}

class SelectCurrencyTableViewController: UITableViewController {
    
    var flagCurrency: FlagCurrencySelected = .from

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Model.shared.currencies.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)

        let currentCurrency = Model.shared.currencies[indexPath.row]
        cell.textLabel?.text = currentCurrency.Name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency = Model.shared.currencies[indexPath.row]
        
        switch flagCurrency {
        case .from:
            Model.shared.fromCurrency = selectedCurrency
        case .to:
            Model.shared.toCurrency = selectedCurrency
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        dismiss(animated: true, completion: nil)
    }
}
