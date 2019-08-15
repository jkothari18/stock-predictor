//
//  ShortSqueezeDetector.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/14/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class ShortSqueezeDetector: Detector {
    
    var securities: [Security]
    
    // MARK: - Init
    
    init(for security: Security) {
        self.securities = [security]
    }
    
    init(for securities: [Security]) {
        self.securities = securities
    }
    
    // MARK: - Detector
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
