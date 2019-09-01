//
//  ShortSqueezeDetector.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/14/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

enum ShortSqueezeStrength {
    case strong, moderate, neutral
}

enum ShortSqueezeState {
    case nonexistant, early, rampUp, imminent
}

struct ShortSqueezeData {
    
    let security: Security
    
    var strength: ShortSqueezeStrength?
    
    var estimatedDaysUntilSqueeze: Int?
    
    var state: ShortSqueezeState?
    
    /// GIven as a percent to be normalize across all securities
    var averageDailyMovementPercent: Double?
    var averageDailyMovementRaw: Double?
    
    /// GIven as a percent to be normalize across all securities
    var averageWeeklyMovementPercent: Double?
    var averageWeeklyMovementRaw: Double?
    
    /// GIven as a percent to be normalize across all securities
    var averageMonthlyMovementPercent: Double?
    var averageMonthlyMovementRaw: Double?
    
    /// In days
    var averageSqueezeDuration: Int?
    var longestSqueezeDuration: Int?
    var shortestSqueezeDuration: Int?
    
    var highVolatilityDates: [Date]?
    
    init(_ security: Security) {
        self.security = security
    }
    
}

/// It would be sick if you could specify what types (are there types?) you want to be searched
/// for a specific security or set of securities

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
        return analyze(for: securities)
    }
    
    func analyze(for securities: [Security]) -> [ShortSqueezeData] {
        let results = [ShortSqueezeData]()
        for security in securities {
            var shortSqueezeData = ShortSqueezeData(security)
            assignAverageMovemenths(on: &shortSqueezeData)
        }
        
        return results
    }
    
    private func assignAverageMovemenths(on shortSqueezeData: inout ShortSqueezeData) {
        let security = shortSqueezeData.security
        let ticker = security.symbol
        let historicDailyData = DatabaseController.shared.getDailyHistoricData(for: ticker)
    }
    
    // MARK: - Detector Protocol
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
