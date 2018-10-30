//
//  Model.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

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
}

protocol Alert {
    func apperearanceAlert()
}

class Model: NSObject, XMLParserDelegate {
    static let shared = Model() // Синглтон класса Model. Вызвав св-во класса, в него запишется ссылка на экземпляр класса. И при каждом вызове Model.shared будет вызываться уже созданный, конкретный экземпляр Model(), на который лежит ссылка в константе shared.
    
    var delegate: Alert?
    
    var currencies: [Currency] = []
    var currentDate: String = ""
    
    var pathForXML: String {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] + "/data.xml" // Нулевой элемент - директория Library
        
        print(path)
        
        // Проверка, есть ли файл по указанному пути path. Если нет нет, то обращаться к файлу data.xml внаутри приложения.
        if FileManager.default.fileExists(atPath: path) {
            return path
        }
        
        return Bundle.main.path(forResource: "data", ofType: "xml")! // Обращение к приложению.
    }
    
    var urlForXML: URL {
        return URL(fileURLWithPath: pathForXML)
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
                    print("Error when save data: \(error.localizedDescription)")
                }
            } else {
                self.parseXML() // Если интернета нет, то парсятся xml-данные, которые были в файле на тот момент.
                
                self.delegate?.apperearanceAlert()
                
                print("Error in \(#function): \(error!.localizedDescription)")
            }
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("startLoadingXML"), object: self) // Отправка уведомления по всему приложению с названием startLoadingXML о том, что начинается загрузка данных data типа Data, содержащих xml-объект, и запись этих данных в файл.
        
        task.resume()
    }
    
    // Парсинг данных. В файле data.xml по пути pathForXML лежит xml-объект типа xml (в формате xml). Создавая парсер parser, вызываются 3 его метода, благодаря которым xml-объект парсится в массив currencies. А также уведомление приложения о том, что данные обновились.
    // xml-объект типа (формата) xml -> из которого создается экземпляр класса Currency и добавляется в массив.
    func parseXML() {
        currencies.removeAll() // Чтобы при каждом новом парсинге валюты не дублировались.
        
        let parser = XMLParser(contentsOf: urlForXML)
        parser?.delegate = self
        parser?.parse()
        
        print("Данные отображены")
        
        NotificationCenter.default.post(name: NSNotification.Name("dataRefreshed"), object: self) // Отправка уведомления по всему приложению с названием dataRefreshed о том, что данные распарсены и массив currencies заполнен.
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
