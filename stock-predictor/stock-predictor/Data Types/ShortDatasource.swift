//
//  ShortDatasource.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/17/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

enum ShortSqueezeStrength {
    case strong, moderate, neutral
}

enum ShortSqueezeState {
    case nonexistant, early, rampUp, imminent
}

struct ShortSqueezeDatasource {
    
    let security: Security
    
    var strength: ShortSqueezeStrength?
    
    var estimatedDaysUntilSqueeze: Int?
    
    var state: ShortSqueezeState?
    
    /// Non-absolute value based (i.e. 5.0 & -5.0 would average to 0.0)
    var averageDailyMovementPercent: Double?
    var averageDailyMovementRaw: Double?
    var averageDailyPositiveMovementPercent: Double?
    var averageDailyPositiveMovementRaw: Double?
    var averageDailyNegativeMovementPercent: Double?
    var averageDailyNegativeMovementRaw: Double?
    
    /// Absoute value based (i.e. -5.0 & 5.0 would average to 5.0)
    var averageHighLowDiffPercent: Double?
    var averageHighLowDiffRaw: Double?
    
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
    
    var highVolatilityOccurences = [HistoricDailyData]()
    var highVolumeOccurences = [HistoricDailyData]()
    
    init(_ security: Security) {
        self.security = security
    }
    
}
