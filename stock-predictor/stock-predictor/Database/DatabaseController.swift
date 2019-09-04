//
//  DatabaseController.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/22/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

final class DatabaseController {
    
    static let DAILY_TABLE_NAME = "daily_stock"
    
    static let shared = DatabaseController()
    
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
        print(statement)
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
        let getDataForSecurityString = "SELECT * FROM \(DatabaseController.DAILY_TABLE_NAME) WHERE ticker LIKE '\(security.symbol)'"
        
        var dailyData = [HistoricDailyData]()
        execute(getDataForSecurityString, on: db) { (executeStatement) in
            while sqlite3_step(executeStatement) == SQLITE_ROW {
                let dateFormatter = Date.getBasicDateFormatter()
                guard let date = dateFormatter.date(from: String(cString: sqlite3_column_text(executeStatement, 0))) else { return }
                let ticker = String(cString: sqlite3_column_text(executeStatement, 1))
                let open = sqlite3_column_double(executeStatement, 2)
                let historicData = HistoricDailyData(ticker: ticker, open: open, close: 0, volume: 0, low: 0, high: 0, date: date)
                dailyData.append(historicData)
            }
        }
        
        var historicData = HistoricData(security: security, dailyData: dailyData)
        historicData.dailyData.sort(by: {$0.date < $1.date})
        return historicData
    }
    
    private func parseRawSQLHistoricData(_ rawData: Any) -> [HistoricData] {
        return []
    }
    
}
