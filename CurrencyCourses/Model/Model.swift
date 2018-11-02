//
//  Model.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import UIKit
import Foundation

/*
<ValCurs Date="02.03.2002" name="Foreign Currency Market">
<Valute ID="R01010">
    <NumCode>036</NumCode>
    <CharCode>AUD</CharCode>
    <Nominal>1</Nominal>
    <Name>...</Name>
    <Value>16,0102</Value>
</Valute>
</ValCurs>
*/

class Currency {
    var NumCode: String?
    var CharCode: String?
    
    var Nominal: String?
    var nominalDouble: Double?
    
    var Name: String?
    
    var Value: String?
    var valueDouble: Double?
    
    var imageFlag: UIImage? {
        if let charCode = CharCode {
            return UIImage(named: charCode+".png")
        }
        return nil
    }
    
    class func rouble() -> Currency {
        let rub = Currency()
        
        rub.CharCode = "RUR"
        rub.Nominal = "1"
        rub.nominalDouble = 1
        rub.Name = "Российский рубль"
        rub.Value = "1"
        rub.valueDouble = 1
        
        return rub
    }
}

protocol Alert {
    func alertInvalidData()
    func apperearanceAlert()
}

class Model: NSObject, XMLParserDelegate {
    static let shared = Model() // Синглтон класса Model. Вызвав св-во класса, в него запишется ссылка на экземпляр класса. И при каждом вызове Model.shared будет вызываться уже созданный, конкретный экземпляр Model(), на который лежит ссылка в константе shared.
    
    var delegate: Alert?
    
    var currencies: [Currency] = []
    var currentDate: String = ""
    
    // Переменные для конвертации.
    var fromCurrency: Currency = Currency.rouble()
    var toCurrency: Currency = Currency.rouble()
    
    // Функция конвертации.
    func conver(amount: Double?) -> String {
        guard let amount = amount else { return "" }
        
        let money = ((fromCurrency.nominalDouble! * fromCurrency.valueDouble!) / (toCurrency.nominalDouble! * toCurrency.valueDouble!)) * amount
        
        return String(money)
    }
    
    var pathForXML: String? {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml" // Нулевой элемент - директория Library
        
        print(path)
        
        // Проверка, есть ли файл по указанному пути path. Если нет, то вызывается alert.
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
        return nil
    }
    
    var urlForXML: URL? {
        if let urlPath = pathForXML {
            return URL(fileURLWithPath: urlPath)
        }
        return nil
    }
    
    // Загрузка XML-данных (XML-объекта) с cbr.ru и их сохранение в каталоге приложения.
    // http://www.cbr.ru/scripts/XML_daily.asp?date_req=02/03/2002
    func loadXMLFile(desiredDate: Date?) {
        var strUrl = "http://www.cbr.ru/scripts/XML_daily.asp?date_req="
        
        if let date = desiredDate {
            strUrl = strUrl + CourseDateFormatter.dateFormatter.string(from: date)
        }
        let url = URL(string: strUrl)

        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//            var errorWhenLoad: String?
            
            if error == nil {
                let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml"
                let urlForSave = URL(fileURLWithPath: path)
                
                do {
                    try data?.write(to: urlForSave)
                    
                    print("Файл загружен")
                    print("Data: \(data!)")
                    if let xmlDataString = String(data: data!, encoding: String.Encoding.iso2022JP) {
                        print("Data, конвертируемые из типа Data в тип String - \(xmlDataString)")
                    }
                    
                    self.parseXML() // Парсятся обновленные в файле xml-данные.
                } catch {
                    self.parseXML() // Если пришли неправильные данные, то парсятся xml-данные, которые были в файле на тот момент и вызывается alert controller.
                    
                    self.delegate?.alertInvalidData() // Вместо делегата можно использовать NotificationCenter.
//                    errorWhenLoad = error.localizedDescription
                    
                    print("Error when save data: \(error.localizedDescription)")
                }
            } else { // Условие, если интернета нет, или данные по API получить нельзя.
                self.parseXML() // Если интернета нет, то парсятся xml-данные, которые были в файле на тот момент  и вызывается alert controller.
                
                self.delegate?.apperearanceAlert() // Вместо делегата можно использовать NotificationCenter.
//                errorWhenLoad = error?.localizedDescription
                
                print("Error in \(#function): \(error!.localizedDescription)")
            }
            
//            if let error = errorWhenLoad {
//                NotificationCenter.default.post(name: NSNotification.Name("ErrorWhenLoading"), object: self, userInfo: ["ErrorName": error])
//
//            }
        }
        task.resume()
        
        NotificationCenter.default.post(name: NSNotification.Name("startLoadingXML"), object: self) // Отправка уведомления по всему приложению с названием startLoadingXML о том, что начинается загрузка данных data типа Data, содержащих xml-объект, и запись этих данных в файл.
    }
    
    // Парсинг данных. В файле data.xml по пути pathForXML лежит xml-объект типа xml (в формате xml). Создавая парсер parser, вызываются 3 его метода, благодаря которым xml-объект парсится в массив currencies. А также уведомление приложения о том, что данные обновились.
    // xml-объект типа (формата) xml -> из которого создается экземпляр класса Currency и добавляется в массив.
    func parseXML() {
        currencies = [Currency.rouble()] // Чтобы при каждом новом парсинге валюты не дублировались, переопределяем массив, первым элементом которого становится рубль.
        
        if let urlForXMLParse = urlForXML {
            let parser = XMLParser(contentsOf: urlForXMLParse)
            parser?.delegate = self
            parser?.parse()
        }
        
        print("Данные отображены")
        
        NotificationCenter.default.post(name: NSNotification.Name("dataRefreshed"), object: self) // Отправка уведомления по всему приложению с названием dataRefreshed о том, что данные распарсены и массив currencies заполнен, или, если файла data.xml нет, то просто отображение пустой таблицы.
        
        // При изменении даты в Настойках, необходимо менять и св-ва fromCurrency и toCurrency.
        for currency in currencies {
            if currency.CharCode == fromCurrency.CharCode {
                fromCurrency = currency
            }
            if currency.CharCode == toCurrency.CharCode {
                toCurrency = currency
            }
        }
    }
    
    var currentCurrency: Currency?
    // Когда parser видит новый тег, вызывается метод didStartElement. То есть <ValCurs Date="02.03.2002" name="Foreign Currency Market"> - это начало открыввающего тега ValCurs. Все, что внутри него, то есть    от < до >, записывается в словарь аттрибутов attributeDict.
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "ValCurs" {
            if let currentDateString = attributeDict["Date"] {
                currentDate = currentDateString
            }
        }
        
        if elementName == "Valute" {
            currentCurrency = Currency()
        }
    }
    
    var currentCharacters: String = ""
    // Когда parser видит то, что внутри открывающего и закрывающего тега, вызывается метод foundCharacters. То есть все то, что внутри <ValCurs Date="02.03.2002" name="Foreign Currency Market"> ... </ValCurs>. Или <NumCode>036</NumCode> - где foundCharacters - это 036.
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentCharacters = string
    }
    
    // Когда parser видит закрытый тег, вызываетсяя метод didEndElement. То есть </ValCurs>.
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        /*
        <Valute ID="R01010">
            <NumCode>036</NumCode>
            <CharCode>AUD</CharCode>
            <Nominal>1</Nominal>
            <Name>...</Name>
            <Value>16,0102</Value>
        </Valute>
        */
        
        if elementName == "NumCode" {
            currentCurrency?.NumCode = currentCharacters
        }
        if elementName == "CharCode" {
            currentCurrency?.CharCode = currentCharacters
        }
        if elementName == "Nominal" {
            currentCurrency?.Nominal = currentCharacters
            currentCurrency?.nominalDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        }
        if elementName == "Name" {
            currentCurrency?.Name = currentCharacters
        }
        if elementName == "Value" {
            currentCurrency?.Value = currentCharacters
            currentCurrency?.valueDouble = Double(currentCharacters.replacingOccurrences(of: ",", with: "."))
        }
        if elementName == "Valute" {
            currencies.append(currentCurrency!)
        }
    }
}

class CourseDateFormatter {
    static let dateFormatter: DateFormatter = { // Cинглтон класса DateFormatter.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        return dateFormatter
    }()
}
