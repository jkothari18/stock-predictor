//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

//_ = RESTNetworking.fetchSecurity("sq")
print(RESTNetworking.fetchBatchedSecurities(["sq", "aapl", "fb", "msft", "hmny"]))

let patternDetector: PatternDetector<Int> = PatternDetector(withPatternLength: 2, 3)
let arr: [Int] = [1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0]
print(patternDetector.detectGenericPattern(for: arr))
