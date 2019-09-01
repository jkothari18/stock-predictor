//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

let s = Security(symbol: "SQ", latestVolume: nil, companyName: nil, marketCap: nil, open: nil, low: nil, high: nil, close: nil, week52High: nil, week52Low: nil)
let d = ShortSqueezeDetector()
d.analyze(for: [s])

/// Outline
///     1. Fetch
///     2. Print detectors/predictors and wait for user input
///     3. Depending upon selection, accept user input for tickers (manual, CSV, or empty)
///     4. Do predictions and such
///     5. Output to well-defined output file for use in ML applications later

let sqSecurity = RESTNetworking.fetchSecurity("sq")!
let securities = RESTNetworking.fetchBatchedSecurities(["sq", "aapl", "msft", "brk.a", "brk.b", "lyft"])
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "dd/MM/yyyy"
let result = dateFormatter.string(from: Date())

let database = DatabaseController.shared
if let db = database.initDatabase() {
    let createTableString = "CREATE TABLE IF NOT EXISTS \(DatabaseController.DAILY_TABLE_NAME) ( date CHAR(255), ticker CHAR(255), open_price REAL);"
    database.createTable(inDatabase: db, withString: createTableString)
    
    let insertString = "INSERT INTO daily_stock (date, ticker, open_price) VALUES (?, ?, ?);"
    for security in securities {
        database.insert(insertString, into: db, withAction: {(insertStatement: OpaquePointer?) -> Void in
            let date: NSString = NSString(string: result)
            let ticker: NSString = NSString(string: security.symbol)
            let open_price: Double = security.open ?? 0
            sqlite3_bind_text(insertStatement, 1, date.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, ticker.utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 3, open_price)
        })
    }
}
