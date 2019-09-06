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
    
    func analyze() -> [ShortSqueezeDatasource] {
        return analyze(securities)
    }
    
    func analyze(_ security: Security) -> ShortSqueezeDatasource {
        return analyze([security])[0]
    }
    
    /// Iterates through each security, adding/updating each security's shortSqueezeData: ShortSqueezeData? var and appending to an array to be optionally used.
    /// In the for-loop, it creates
    func analyze(_ securities: [Security]) -> [ShortSqueezeDatasource] {
        var results = [ShortSqueezeDatasource]()
        for security in securities {
            var shortSqueezeData = security.shortSqueezeData != nil ? security.shortSqueezeData! : ShortSqueezeDatasource(security)
            security.shortSqueezeData = shortSqueezeData
            results.append(shortSqueezeData)
            assignAverageMovements(on: &shortSqueezeData)
        }
        
        return results
    }
    
    private func assignAverageMovements(on shortSqueezeData: inout ShortSqueezeDatasource) {
        let security = shortSqueezeData.security
        guard let historicDailyData = DatabaseController.shared.getDailyHistoricData(for: security) else { return }
        for el in historicDailyData.dailyData {
            let dailyDiff: Double = el.open - el.close
            let diffPercent = (dailyDiff / el.open) * 100
            print(diffPercent)
        }
    }
    
    // MARK: - Detector Protocol
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
