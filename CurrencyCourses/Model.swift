//
//  Model.swift
//  CurrencyCourses
//
//  Created by Timur Saidov on 30/10/2018.
//  Copyright © 2018 Timur Saidov. All rights reserved.
//

import Foundation

/*
<NumCode>036</NumCode>
    <CharCode>AUD</CharCode>
    <Nominal>1</Nominal>
    <Name>...</Name>
    <Value>16,0102</Value>
*/

class Currency {
    var NumCode: String?
    var CharCode: String?
    
    var Nominal: String?
    var nominalDouble: String?
    
    var Name: String?
    
    var Value: String?
    var valueDouble: String?
}

class Model: NSObject {
    static let shared = Model() // Синглтон. Вызвав св-во класса(let), в него запишется ссылка на экземпляр класса.
    
    var currecies: [Currency] = []
    
    var pathForXML: String {
        return ""
    }
    
    var urlFoXML: URL? {
        return nil
    }
    
    // Загрузка XML-данных (XML-объектов) с cbr.ru и их сохранение в каталоге приложения.
    func loadXMLFile(data: Data) {
        
    }
    
    // Парсинг данных. А также уведомление приложения о том, что данные обновились.
    func parseXML() {
        
    }
}
