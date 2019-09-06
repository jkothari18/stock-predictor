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
    static let GENERAL_INFO_TABLE_NAME = "general_info"
    static let HISTORICAL_DAILY_DATA_TABLE = "historical_daily_data"
    
    static let shared = DatabaseController()
    
    var mode: DatabaseMode = .single
    
    // MARK: - Initialization
    
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
    
    // MARK: - General Stock Data
    
    /// Inserts symbol, companyName, averageVolume, marketCap, week52High, and week52Low into database.
    func updateSecurity(for security: Security) {
        let symbol: NSString = NSString(string: security.symbol)
        let companyName: NSString = NSString(string: security.companyName ?? "")
        let averageVolume = security.averageVolume ?? 0
        let marketCap = security.marketCap ?? 0
        let week52High = security.week52High ?? 0.0
        let week52Low = security.week52Low ?? 0.0
        
        guard let db = initDatabase() else { return }
        let createTableString = "CREATE TABLE IF NOT EXISTS \(DatabaseController.GENERAL_INFO_TABLE_NAME) ( ticker CHAR(255), companyName CHAR(255), averageVolume INTEGER, marketCap INTEGER, week52High REAL, week52Low REAL, UNIQUE(ticker) ON CONFLICT REPLACE);"
        createTable(inDatabase: db, withString: createTableString)
        
        let replaceString = "INSERT INTO \(DatabaseController.GENERAL_INFO_TABLE_NAME) (ticker, companyName, averageVolume, marketCap, week52High, week52Low) VALUES (?, ?, ?, ?, ?, ?);"
        replace(replaceString, into: db) { (insertStatement: OpaquePointer?) in
            sqlite3_bind_text(insertStatement, 1, symbol.utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, companyName.utf8String, -1, nil)
            sqlite3_bind_int64(insertStatement, 3, Int64(averageVolume))
            sqlite3_bind_int64(insertStatement, 4, Int64(marketCap))
            sqlite3_bind_double(insertStatement, 5, week52High)
            sqlite3_bind_double(insertStatement, 6, week52Low)
        }
    }
    
    func getSecurity(_ symbol: String) -> Security? {
        guard let db = initDatabase() else { return nil }
        let getDataForSecurityString = "SELECT * FROM \(DatabaseController.GENERAL_INFO_TABLE_NAME) WHERE ticker LIKE '\(symbol)';"
        let security = Security(symbol: symbol)
        
        execute(getDataForSecurityString, on: db) { (executeStatement) in
            while sqlite3_step(executeStatement) == SQLITE_ROW {
                security.companyName = String(cString: sqlite3_column_text(executeStatement, 1))
                security.averageVolume = Int(sqlite3_column_int64(executeStatement, 2))
                security.marketCap = Int(sqlite3_column_int64(executeStatement, 3))
                security.week52High = sqlite3_column_double(executeStatement, 4)
                security.week52Low = sqlite3_column_double(executeStatement, 5)
            }
        }
        
        return security
    }
    
    // MARK: - Historical Data
    
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
    
    // MARK: - Helpers
    
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
    
    func execute(_ statement: String, on db: OpaquePointer, withAction handler: (OpaquePointer?) -> Void) {
        var executeStatement: OpaquePointer? = nil
        let prepareResult = sqlite3_prepare_v2(db, statement, -1, &executeStatement, nil)
        if prepareResult == SQLITE_OK {
            handler(executeStatement)
        } else {
            print("EXECUTE statement could not be prepared with error: \(prepareResult)")
        }
    }
    
}
