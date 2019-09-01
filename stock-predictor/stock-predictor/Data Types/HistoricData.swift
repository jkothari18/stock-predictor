//
//  HistoricData.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/31/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

internal struct HistoricDailyData {
    
    var open: Double
    
    var close: Double
    
    var volume: Int
    
    var low: Double
    
    var high: Double
    
    var date: Date
    
}

struct HistoricData {
    
    let security: Security
    
    var dailyData: [HistoricDailyData] = []
    
    init(withSecurity security: Security) {
        self.security = security
    }
    
}
