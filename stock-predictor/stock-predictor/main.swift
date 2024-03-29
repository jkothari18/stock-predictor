//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

//if let security = RESTNetworking.fetchSecurity("sq") {
//    DatabaseController.shared.updateSecurity(for: security)
//}
//
//RESTNetworking.fetchHistoricalDailyData(for: "sq")

if let s = DatabaseController.shared.getSecurity("sq") {
    let d = ShortSqueezeDetector()
    d.analyze([s])
}
//
//let sqSecurity = RESTNetworking.fetchSecurity("sq")!
//let securities = RESTNetworking.fetchBatchedSecurities(["sq", "aapl", "msft", "brk.a", "brk.b", "lyft"])
//let dateFormatter = Date.getBasicDateFormatter()
//let result = dateFormatter.string(from: Date())
//
//let database = DatabaseController.shared
//if let db = database.initDatabase() {
//    let createTableString = "CREATE TABLE IF NOT EXISTS \(DatabaseController.DAILY_TABLE_NAME) ( date CHAR(255), ticker CHAR(255), open_price REAL);"
//    database.createTable(inDatabase: db, withString: createTableString)
//    // TODO: - This only kinda works.
//    let replaceString = "REPLACE INTO daily_stock (date, ticker, open_price) VALUES (?, ?, ?);"
//    for security in securities {
//        database.replace(replaceString, into: db, withAction: {(insertStatement: OpaquePointer?) -> Void in
//            let date: NSString = NSString(string: result)
//            let ticker: NSString = NSString(string: security.symbol)
//            let open_price: Double = security.open ?? 0
//            sqlite3_bind_text(insertStatement, 1, date.utf8String, -1, nil)
//            sqlite3_bind_text(insertStatement, 2, ticker.utf8String, -1, nil)
//            sqlite3_bind_double(insertStatement, 3, open_price)
//        })
//    }
//}
