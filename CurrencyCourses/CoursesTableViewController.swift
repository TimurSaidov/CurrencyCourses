//
//  CoursesTableViewController.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class CoursesTableViewController: UITableViewController {
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func pushRefreshAction(_ sender: UIBarButtonItem) {
        Model.shared.loadXMLFile(desiredDate: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Model.shared.delegate = self
        Model.shared.loadXMLFile(desiredDate: nil)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("startLoadingXML"), object: nil, queue: nil) { (notification) in
            print("Уведомление startLoadingXML поймано")
            
            DispatchQueue.main.async {
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.color = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
                activityIndicator.startAnimating()
                self.navigationItem.leftBarButtonItem?.customView = activityIndicator
            }
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name("dataRefreshed"), object: nil, queue: nil) { (notification) in
            print("Уведомление dataRefreshed поймано")
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.navigationItem.title = Model.shared.currentDate
                
                let barButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.pushRefreshAction(_:)))
                self.navigationItem.leftBarButtonItem = barButtonItem
                self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
            }
        }
        
//        NotificationCenter.default.addObserver(forName: NSNotification.Name("ErrorWhenLoading"), object: nil, queue: nil) { (notification) in
//            print("Уведомление ErrorWhenLoading поймано")
//            
//            DispatchQueue.main.async {
//                let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
//                let action = UIAlertAction(title: "", style: .default, handler: { (action) in
//                    
//                })
//                alertController.addAction(action)
//                self.present(alertController, animated: true, completion: nil)
//                
//                let barButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.pushRefreshAction(_:)))
//                self.navigationItem.leftBarButtonItem = barButtonItem
//                self.navigationItem.leftBarButtonItem?.tintColor = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
//            }
//        }
        
        navigationItem.title = Model.shared.currentDate
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let course = Model.shared.currencies[indexPath.row]
        
        cell.textLabel?.text = course.Name
        cell.detailTextLabel?.text = course.Value

        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CoursesTableViewController: Alert {
    func apperearanceAlert() {
        let alertController = UIAlertController(title: "The Internet connection appears to be offline", message: "Try to connect to the Internet. Last loaded data is now displayed", preferredStyle: .alert)
        let action = UIAlertAction(title: "Connect again", style: .default) { (action) in
            Model.shared.loadXMLFile(desiredDate: nil)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertInvalidData() {
        let alertController = UIAlertController(title: "Invalid data XML", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Connect again", style: .default) { (action) in
            Model.shared.loadXMLFile(desiredDate: nil)
        }
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
}
