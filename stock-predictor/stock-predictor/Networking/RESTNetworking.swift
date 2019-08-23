//
//  RESTNetworking.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/17/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class RESTNetworking {
    
    static let TAG = "RESTNetworking"
    static let IEX_SANDBOX_TOKEN = "Tsk_c4ac493e5fce4aab9e71f9e911e5f482"
    
    static func fetchBatchedSecurities(_ symbols: [String]) -> [Security] {
        var securities = [Security]()
        symbols.forEach { (symbol) in
            let security = fetchSecurity(symbol)
            if security != nil {
                securities.append(security!)
            }
        }
        
        return securities
    }
    
    static func fetchSecurity(_ symbol: String) -> Security? {
        let url = URL(string: "https://sandbox.iexapis.com/stable/stock/\(symbol)/quote?token=\(IEX_SANDBOX_TOKEN)")!
        let semaphore = DispatchSemaphore(value: 0)
        var security: Security? = nil
        
        URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else {
                print("\(TAG): error fetching data for security \(symbol)")
                return
            }
            do {
                security = try JSONDecoder().decode(Security.self, from: data)
            } catch let jsonError {
                print("JSON error: \(jsonError)")
            }
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        return security
    }
    
    static func fetchBatchedShortData(forSymbols symbols: [String]) -> [ShortDatasource?] {
        var securities = [ShortDatasource?]()
        symbols.forEach { (symbol) in
            securities.append(fetchShortData(forSymbol: symbol))
        }
        
        return securities
    }
    
    static func fetchShortData(forSymbol symbol: String) -> ShortDatasource? {
        return ShortDatasource()
    }
    
}
