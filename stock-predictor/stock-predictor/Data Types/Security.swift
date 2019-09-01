//
//  Security.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

struct Security: Decodable {
    let symbol: String
    let latestVolume: Int?
    let companyName: String?
    let marketCap: Int?
    let open: Double?
    let low: Double?
    let high: Double?
    let close: Double?
    let week52High: Double?
    let week52Low: Double?
}
