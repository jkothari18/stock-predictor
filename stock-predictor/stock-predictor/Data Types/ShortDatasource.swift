//
//  ShortDatasource.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/17/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class ShortDatasource {
    
}

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
