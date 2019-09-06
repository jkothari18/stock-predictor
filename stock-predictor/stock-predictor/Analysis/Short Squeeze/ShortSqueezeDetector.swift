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
    
    func analyze() {
        analyze(securities)
    }
    
    func analyze(_ security: Security) {
        analyze([security])
    }
    
    /// Iterates through each security, adding/updating each security's shortSqueezeData: ShortSqueezeData? var and appending to an array to be optionally used.
    /// In the for-loop, it creates
    func analyze(_ securities: [Security]) {
        for security in securities {
            var shortSqueezeData = security.shortSqueezeData != nil ? security.shortSqueezeData! : ShortSqueezeDatasource(security)
            security.shortSqueezeData = shortSqueezeData
            assignAverageMovements(on: &shortSqueezeData)
            security.shortSqueezeData = shortSqueezeData
        }
    }
    
    private func assignAverageMovements(on shortSqueezeData: inout ShortSqueezeDatasource) {
        let security = shortSqueezeData.security
        guard let historicDailyData = DatabaseController.shared.getDailyHistoricData(for: security) else { return }
        var nonbiasPercentSum = 0.0, nonbiasRawSum = 0.0
        var positivePercentSum = 0.0, positiveRawSum = 0.0, positiveCount = 0.0
        var negativePercentSum = 0.0, negativeRawSum = 0.0, negativeCount = 0.0
        
        for dailyData in historicDailyData.dailyData {
            let dailyDiff: Double = dailyData.open - dailyData.close
            nonbiasRawSum += dailyDiff
            let diffPercent = (dailyDiff / dailyData.open) * 100
            nonbiasPercentSum += diffPercent
            if diffPercent >= 0 {
                positiveRawSum += dailyDiff
                positivePercentSum += diffPercent
                positiveCount += 1
            } else {
                negativeRawSum += dailyDiff
                negativePercentSum += diffPercent
                negativeCount += 1
            }
            
            let highLowDiffRaw = abs(dailyData.high - dailyData.low)
            let highLowDiffPercent = (highLowDiffRaw / dailyData.open) * 100
            shortSqueezeData.averageHighLowDiffRaw = highLowDiffRaw
            shortSqueezeData.averageHighLowDiffPercent = highLowDiffPercent
            
            if (abs(diffPercent) >= 5.0 || highLowDiffPercent >= 7.5) {
                shortSqueezeData.highVolatilityOccurences.append(dailyData)
            }
            
            if let averageVolume = security.averageVolume {
                if (dailyData.volume >= averageVolume * 4) {
                    shortSqueezeData.highVolumeOccurences.append(dailyData)
                }
            }
        }
        
        shortSqueezeData.averageDailyMovementPercent = nonbiasPercentSum / Double(historicDailyData.dailyData.count)
        shortSqueezeData.averageDailyMovementRaw = nonbiasRawSum / Double(historicDailyData.dailyData.count)
        shortSqueezeData.averageDailyPositiveMovementPercent = positivePercentSum / positiveCount
        shortSqueezeData.averageDailyPositiveMovementRaw = positiveRawSum / positiveCount
        shortSqueezeData.averageDailyNegativeMovementPercent = negativePercentSum / negativeCount
        shortSqueezeData.averageDailyNegativeMovementRaw = negativeRawSum / negativeCount
    }
    
    // MARK: - Detector Protocol
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
