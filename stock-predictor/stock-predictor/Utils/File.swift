//
//  File.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 9/3/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

extension Date {
    
    static func getBasicDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }
    
}
