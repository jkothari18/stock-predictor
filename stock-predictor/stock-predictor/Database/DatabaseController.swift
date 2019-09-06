//
//  DatabaseController.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/22/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

enum DatabaseMode {
    case single, continuous
}

final class DatabaseController {
    
    static let DAILY_TABLE_NAME = "daily_stock"
    static let HISTORICAL_DAILY_DATA_TABLE = "historical_daily_data"
    
    static let shared = DatabaseController()
    
    var mode: DatabaseMode = .single
    
    func initDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if let prefix = ProcessInfo.processInfo.environment["STOCK_PRED_DB"] {
            let path = URL(fileURLWithPath: "\(prefix)/StockPredictor.sqlite3")
            let openResult = sqlite3_open(path.absoluteString, &db)
            if openResult == SQLITE_OK {
                print("Successfully opened db at: \(path)")
                return db
            } else {
                print("Failed to open db at: \(path) with error: \(openResult)")
            }
        }
        return nil
    }
    
    func createTable(inDatabase db: OpaquePointer, withString createString: String) {
        var createTableStatement: OpaquePointer? = nil
        let prepareResult = sqlite3_prepare_v2(db, createString, -1, &createTableStatement, nil)
        if prepareResult == SQLITE_OK {
            let stepResult = sqlite3_step(createTableStatement)
            if stepResult != SQLITE_DONE {
                print("Table could not be created with error: \(stepResult)")
            }
        } else {
            print("CREATE TABLE statement could not be prepared with error: \(prepareResult)")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func replace(_ statement: String, into db: OpaquePointer, withAction handler: (OpaquePointer?) -> Void) {
        var replaceStatement: OpaquePointer? = nil
        let prepareResult = sqlite3_prepare_v2(db, statement, -1, &replaceStatement, nil)
        if prepareResult == SQLITE_OK {
            handler(replaceStatement)
            
            let stepResult = sqlite3_step(replaceStatement)
            if stepResult != SQLITE_DONE {
                print("Could not insert row with error: \(stepResult)")
            }
        } else {
            print("REPLACE statement could not be prepared with error: \(prepareResult)")
        }
        sqlite3_finalize(replaceStatement)
    }
    
    // TODO: - Implement callback for the while loop part
    func execute(_ statement: String, on db: OpaquePointer, withAction handler: (OpaquePointer?) -> Void) {
        var executeStatement: OpaquePointer? = nil
        let prepareResult = sqlite3_prepare_v2(db, statement, -1, &executeStatement, nil)
        if prepareResult == SQLITE_OK {
            handler(executeStatement)
        } else {
            print("EXECUTE statement could not be prepared with error: \(prepareResult)")
        }
    }
    
    // TODO: - Turn this into a batched request to vastly improve SQLite performance
    func getDailyHistoricData(for security: Security) -> HistoricData? {
        guard let db = initDatabase() else { return nil }
        let getDataForSecurityString = "SELECT * FROM \(DatabaseController.HISTORICAL_DAILY_DATA_TABLE) WHERE ticker LIKE '\(security.symbol)';"
        
        var dailyData = [HistoricDailyData]()
        execute(getDataForSecurityString, on: db) { (executeStatement) in
            while sqlite3_step(executeStatement) == SQLITE_ROW {
                let dateFormatter = Date.getBasicDateFormatter()
                let ticker = String(cString: sqlite3_column_text(executeStatement, 0))
                guard let date = dateFormatter.date(from: String(cString: sqlite3_column_text(executeStatement, 1))) else { return }
                let open = sqlite3_column_double(executeStatement, 2)
                let high = sqlite3_column_double(executeStatement, 3)
                let low = sqlite3_column_double(executeStatement, 4)
                let close = sqlite3_column_double(executeStatement, 5)
                let volume = sqlite3_column_int(executeStatement, 6)
                let historicData = HistoricDailyData(ticker: ticker, date: date, open: open, close: close, volume: Int(volume), low: low, high: high)
                dailyData.append(historicData)
            }
        }
        
        var historicData = HistoricData(security: security, dailyData: dailyData)
        historicData.dailyData.sort(by: {$0.date < $1.date})
        return historicData
    }
    
    func updateHistoricalData(for security: Security) {
        guard let historicalData = security.historicalData else { return }
        guard let db = initDatabase() else { return }
        let createTableString = "CREATE TABLE IF NOT EXISTS \(DatabaseController.HISTORICAL_DAILY_DATA_TABLE) ( ticker CHAR(255), date CHAR(255), open REAL, high REAL, low REAL, close REAL, volume INTEGER, UNIQUE (ticker, date) ON CONFLICT REPLACE);"
        createTable(inDatabase: db, withString: createTableString)
        
        let replaceString = "INSERT INTO \(DatabaseController.HISTORICAL_DAILY_DATA_TABLE) (ticker, date, open, high, low, close, volume) VALUES (?, ?, ?, ?, ?, ?, ?);"
        for dailyData in historicalData.dailyData {
            replace(replaceString, into: db, withAction: {(insertStatement: OpaquePointer?) -> Void in
                let ticker: NSString = NSString(string: security.symbol)
                let formatter = Date.getBasicDateFormatter()
                let result = formatter.string(from: dailyData.date)
                let date: NSString = NSString(string: result)
                
                sqlite3_bind_text(insertStatement, 1, ticker.utf8String, -1, nil)
                sqlite3_bind_text(insertStatement, 2, date.utf8String, -1, nil)
                sqlite3_bind_double(insertStatement, 3, dailyData.open)
                sqlite3_bind_double(insertStatement, 4, dailyData.high)
                sqlite3_bind_double(insertStatement, 5, dailyData.low)
                sqlite3_bind_double(insertStatement, 6, dailyData.close)
                sqlite3_bind_int(insertStatement, 7, Int32(dailyData.volume))
            })
        }
    }
    
}
