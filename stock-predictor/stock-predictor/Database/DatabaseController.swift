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
            if stepResult == SQLITE_DONE {
                print("Successfully created table")
            } else {
                print("Table could not be created with error: \(stepResult)")
            }
        } else {
            print("CREATE TABLE statement could not be prepared with error: \(prepareResult)")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(_ statement: String, into db: OpaquePointer, withAction handler: (OpaquePointer?) -> Void) {
        var insertStatement: OpaquePointer? = nil
        
        let prepareResult = sqlite3_prepare_v2(db, statement, -1, &insertStatement, nil)
        if prepareResult == SQLITE_OK {
            handler(insertStatement)
            
            let stepResult = sqlite3_step(insertStatement)
            if stepResult == SQLITE_DONE {
                print("Successfully inserted row")
            } else {
                print("Could not insert row with error: \(stepResult)")
            }
        } else {
            print("INSERT statement could not be prepared with error: \(prepareResult)")
        }
        sqlite3_finalize(insertStatement)
    }
    
}
