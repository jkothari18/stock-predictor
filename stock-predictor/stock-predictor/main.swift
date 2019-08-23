//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

//print(RESTNetworking.fetchBatchedSecurities(["sq", "aapl", "fb", "msft", "hmny"]))

/*
let patternDetector: PatternDetector<Int> = PatternDetector(withPatternLength: 2, 3)
let arr: [Int] = [1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0]
print(patternDetector.detectGenericPattern(for: arr))
 */

let database = DatabaseController.shared
if let db = database.initDatabase() {
    let createTableString = "CREATE TABLE daily_stock(id INT PRIMARY KEY NOT NULL, ticker CHAR(255), open_price REAL);"
    database.createTable(inDatabase: db, withString: createTableString)
    let insertString = "INSERT INTO daily_stock(id, ticker, open_price) VALUES (?, ?, ?);"
    database.insert(insertString, into: db, {(insertStatement: OpaquePointer?) -> Void in
        let id: Int32 = 100
        let ticker: NSString = "SQ"
        let open_price: Double = 74.32
        
        sqlite3_bind_int(insertStatement, 1, id)
        sqlite3_bind_text(insertStatement, 2, ticker.utf8String, -1, nil)
        sqlite3_bind_double(insertStatement, 3, open_price)
    })
}
