//
//  ShortSqueezeDetector.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/14/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class ShortSqueezeDetector: Detector {
    
    // MARK: - Properties
    
    var PERCENT_ABOVE_AVERAGE_PERCENT_THRESHOLD: Double = 1
    
    var DAYS_FOR_ANOMALOUS_BEHAVIOR: Int = 5
    
    var securities: [Security]
    
    // MARK: - Init
    
    init() {
        securities = []
    }
    
    init(for security: Security) {
        self.securities = [security]
    }
    
    init(for securities: [Security]) {
        self.securities = securities
    }
    
    // MARK: - Raw Data Anlysis
    
    func analyze() -> [ShortSqueezeData] {
        return analyze(securities)
    }
    
    func analyze(_ security: Security) -> ShortSqueezeData {
        return analyze([security])[0]
    }
    
    func analyze(_ securities: [Security]) -> [ShortSqueezeData] {
        var results = [ShortSqueezeData]()
        for security in securities {
            var shortSqueezeData = ShortSqueezeData(security)
            assignAverageMovements(on: &shortSqueezeData)
        }
        
        results.append(ShortSqueezeData(Security(symbol: "AAPL", latestVolume: nil, companyName: nil, marketCap: nil, open: nil, low: nil, high: nil, close: nil, week52High: nil, week52Low: nil)))
        return results
    }
    
    private func assignAverageMovements(on shortSqueezeData: inout ShortSqueezeData) {
        let security = shortSqueezeData.security
        guard let historicDailyData = DatabaseController.shared.getDailyHistoricData(for: security) else { return }
        for el in historicDailyData.dailyData {
            print(el.date)
        }
    }
    
    // MARK: - Detector Protocol
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
