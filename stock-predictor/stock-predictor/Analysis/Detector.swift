//
//  Detector.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/14/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

enum GeneralizedMovement {
    case strongBearish
    case moderateBearish
    case neutral
    case moderateBullish
    case strongBullish
}

protocol Detector {
    
    func generalizedMovement() -> GeneralizedMovement
    
}
