//
//  PatternDetector.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/16/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class PatternDetector<T: Numeric>: Detector {
    
    private let TAG = "PatternDetector"
    
    private var numRepetitions: Int = 0
    private var patternLength: Int = 0
    private var patternDuration: Int = 0
    
    init(withPatternLength pLength: Int, _ repetitions: Int) {
        patternLength = pLength
        numRepetitions = repetitions
        patternDuration = patternLength * numRepetitions
    }
    
    private func isValidEntry(_ datapoints: [T], currentIndex: Int) -> Bool {
        return (currentIndex - patternLength >= 0 && datapoints[currentIndex] == datapoints[currentIndex - patternLength])
    }
    
    /// Returns an array of booleans indicating whether a pattern has been detected at a given index. A pattern is "detected" if the pattern has been observed 1 complete time, and any subsequent datapoints stay true to that pattern.
    /// For numRepetitions = 3, patternLength = 2
    /// [1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0]
    /// [F, F, F, F, F, F, F, F, F, F, T, T, T, F]
    func detectGenericPattern(for datapoints: [T]) -> [Bool] {
        var pattern = [Bool]()
        var isTracking = false
        var startIndex = 0
        if datapoints.count < patternLength {
            return [Bool](repeating: false, count: datapoints.count)
        }
        
        for (index, _) in datapoints.enumerated() {
            if isValidEntry(datapoints, currentIndex: index) {
                if !isTracking {
                    isTracking = true
                    startIndex = index - patternLength
                }
                let value = (index + 1) - startIndex >= patternDuration
                pattern.append(value)
            } else {
                isTracking = false
                pattern.append(false)
            }
        }
        
        return pattern
    }
    
    func generalizedMovement() -> GeneralizedMovement {
        return .neutral
    }
    
}
