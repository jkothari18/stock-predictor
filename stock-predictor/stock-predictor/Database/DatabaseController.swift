//
//  DatabaseController.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/22/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite3

class DatabaseController {
    
    static let shared = DatabaseController()
    
    private init() {
        // init
    }
    
    func initDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        if let prefix = ProcessInfo.processInfo.environment["STOCK_PRED_DB"] {
            let path = URL(fileURLWithPath: "\(prefix)/StockPredictor")
            if sqlite3_open(path.absoluteString, &db) == SQLITE_OK {
                print("Successfully opened db at: \(path)")
                return db
            } else {
                print("Failed to open db at: \(path)")
            }
        }
        return nil
    }
    
    func createTable(inDatabase db: OpaquePointer, withString createString: String) {
        var createTableStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, createString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                print("Successfully created table")
            } else {
                print("Table could not be created.")
            }
        } else {
            print("CREATE TABLE statement could not be prepared.")
        }
        sqlite3_finalize(createTableStatement)
    }
    
    func insert(_ statement: String, into db: OpaquePointer, _ handler: @escaping (OpaquePointer?) -> Void) {
        var insertStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, statement, -1, &insertStatement, nil) == SQLITE_OK {
            handler(insertStatement)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully inserted row.")
            } else {
                print("Could not insert row.")
            }
        } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insertStatement)
    }
    
}
