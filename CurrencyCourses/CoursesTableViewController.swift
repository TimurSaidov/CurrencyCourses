//
//  CoursesTableViewController.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit

class CoursesTableViewController: UITableViewController {
    
    var tableViewShown: Bool = false
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func pushRefreshAction(_ sender: UIBarButtonItem) {
        tableViewShown = false
        
        Model.shared.loadXMLFile(desiredDate: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        
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
                self.tableViewShown = true
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
        
        Model.shared.delegate = self
        Model.shared.loadXMLFile(desiredDate: nil)
        
        navigationItem.title = Model.shared.currentDate
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("Currencies во время \(#function): \(Model.shared.currencies.count)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        print("Currencies во время \(#function): \(Model.shared.currencies.count)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if tableViewShown {
            print("Currencies во время \(#function): \(Model.shared.currencies.count)")
            return Model.shared.currencies.count
        } else {
            print("Currencies во время \(#function): 0")
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CoursesTableViewCell

        let course = Model.shared.currencies[indexPath.row]
        
        cell.currencyNameLabel.text = course.Name
        let value = Double(round(100*course.valueDouble!)/100)
        cell.currencyCourseLabel.text = "\(value)"
        cell.currencyImageView.image = course.imageFlag
        cell.currencyImageView.layer.cornerRadius = 11
        cell.currencyImageView.clipsToBounds = true
        cell.currencyImageView.layer.borderWidth = 1
        cell.currencyImageView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        let alertController = UIAlertController(title: "Нет соединения с Интернетом", message: "Для обновления данных включите передачу данных по сотовой сети или используйте Wi-Fi. Сейчас будут отображены данные, которые сохранились при Вашем крайнем запуске приложения", preferredStyle: .alert)
        let action = UIAlertAction(title: "Подключиться снова", style: .default) { (action) in
            Model.shared.loadXMLFile(desiredDate: nil)
        }
        let cancel = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(action)
        alertController.addAction(cancel)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func alertInvalidData() {
        let alertController = UIAlertController(title: "Неправильные XML-данные", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Подключиться снова", style: .default) { (action) in
            Model.shared.loadXMLFile(desiredDate: nil)
        }
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
}
