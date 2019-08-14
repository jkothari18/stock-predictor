//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation
import SQLite

let SANDBOX_TOKEN = "Tsk_c4ac493e5fce4aab9e71f9e911e5f482"

func fetchBatchedSecurities(_ symbols: [String]) -> [Security] {
    let url = "https://sandbox.iexapis.com/stable/stock/sq/quote?token=\(SANDBOX_TOKEN)"
    print(url)
    
    return []
}

func fetchSecurity(_ symbol: String) -> Security? {
    let url = URL(string: "https://sandbox.iexapis.com/stable/stock/\(symbol)/quote?token=\(SANDBOX_TOKEN)")!
    let semaphore = DispatchSemaphore(value: 0)
    var security: Security? = nil
    
    URLSession.shared.dataTask(with: url) {(data, response, error) in
        guard let data = data else { return }
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


fetchSecurity("sq")
sleep(1)
