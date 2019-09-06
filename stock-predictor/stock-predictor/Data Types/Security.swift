//
//  Security.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

final class Security: Decodable {
    
    private enum SecurityStructKeys: String, CodingKey {
        case symbol = "symbol"
        case averageVolume = "avgTotalVolume"
        case companyName = "companyName"
        case marketCap = "marketCap"
        case week52High = "week52High"
        case week52Low = "week52Low"
    }
    
    let symbol: String
    var averageVolume: Int?
    var companyName: String?
    var marketCap: Int?
    var week52High: Double?
    var week52Low: Double?
    
    var shortSqueezeData: ShortSqueezeDatasource? = nil
    var historicalData: HistoricData? = nil
    
    init(symbol: String, latestVolume: Int?, companyName: String?, marketCap: Int?, open: Double?, low: Double?, high: Double?, close: Double?, week52High: Double?, week52Low: Double?) {
        self.symbol = symbol
        self.averageVolume = latestVolume
        self.companyName = companyName
        self.marketCap = marketCap
        self.week52High = week52High
        self.week52Low = week52Low
    }
    
    init(symbol: String) {
        self.symbol = symbol
        
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SecurityStructKeys.self)
        symbol = try values.decode(String.self, forKey: .symbol)
        averageVolume = try values.decode(Int.self, forKey: .averageVolume)
        companyName = try values.decode(String.self, forKey: .companyName)
        marketCap = try values.decode(Int.self, forKey: .marketCap)
        week52High = try values.decode(Double.self, forKey: .week52High)
        week52Low = try values.decode(Double.self, forKey: .week52Low)
    }
    
}
