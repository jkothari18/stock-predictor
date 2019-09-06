//
//  RESTNetworking.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/17/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

/// https://www.alphavantage.co/documentation/

private enum HistoricalDailyKeys: String {
    case open   = "1. open"
    case high   = "2. high"
    case low    = "3. low"
    case close  = "4. close"
    case volume = "5. volume"
}

final class MinimalSecurity: Decodable {
    
    var symbol: String
    
    var name: String
    
}

final class RESTNetworking {
    
    static let TAG = "RESTNetworking"
    static let IEX_SANDBOX_TOKEN = "Tsk_c4ac493e5fce4aab9e71f9e911e5f482"
    static let ALPHAVANTAGE_KEY = "U9O7HQHLAAZGNV25"
    
    // MARK: - Security Fetch
    
    static func fetchSecurity(_ symbol: String) -> Security? {
        let url = URL(string: "https://sandbox.iexapis.com/stable/stock/\(symbol)/quote?token=\(IEX_SANDBOX_TOKEN)")!
        let semaphore = DispatchSemaphore(value: 0)
        var security: Security? = nil
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("\(TAG): error fetching data for security \(symbol): \(String(describing: error))")
                return
            }
            do {
                security = try JSONDecoder().decode(Security.self, from: data)
                semaphore.signal()
            } catch let jsonError {
                print("JSON error: \(jsonError)")
            }
        }.resume()
        
        semaphore.wait()
        return security
    }
    
    static func fetchBatchedSecurities(_ symbols: [String]) -> [Security] {
        var securities = [Security]()
        symbols.forEach { (symbol) in
            let security = fetchSecurity(symbol)
            if security != nil {
                securities.append(security!)
            }
        }

        return securities
    }
    
    // MARK: - Historical
    
    // TODO: - Add check to prevent running this if the security already has its data updated. i.e. check if it has today's value in its historicalData var
    static func fetchHistoricalData(for security: Security) -> HistoricData? {
        let symbol = security.symbol
        guard let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbol)&outputsize=full&apikey=\(ALPHAVANTAGE_KEY)") else { return nil }
        let semaphore = DispatchSemaphore(value: 0)
        var historicData = HistoricData(security: security)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("\(TAG): error fetching historical data for security \(symbol): \(String(describing: error))")
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonArray = jsonResponse as? [String: Any] else { return }
                guard let bothData = jsonArray["Time Series (Daily)"] else { return }
                guard let dailyData = bothData as? [String: Any] else { return }
                for (date, _) in dailyData {
                    guard let data = dailyData[date] else { continue }
                    guard let dataDict = data as? [String: Any] else { continue }
                    
                    guard let openString = dataDict[HistoricalDailyKeys.open.rawValue] as? String else { continue }
                    guard let open = Double(openString) else { continue }
                    guard let highString = dataDict[HistoricalDailyKeys.high.rawValue] as? String else { continue }
                    guard let high = Double(highString) else { continue }
                    guard let lowString = dataDict[HistoricalDailyKeys.low.rawValue] as? String else { continue }
                    guard let low = Double(lowString) else { continue }
                    guard let closeString = dataDict[HistoricalDailyKeys.close.rawValue] as? String else { continue }
                    guard let close = Double(closeString) else { continue }
                    guard let volumeString = dataDict[HistoricalDailyKeys.volume.rawValue] as? String else { continue }
                    guard let volume = Int(volumeString) else { continue }
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    guard let finalDate = formatter.date(from: date) else { continue }
                    let dailyData = HistoricDailyData(ticker: security.symbol, date: finalDate, open: open, close: close, volume: volume, low: low, high: high)
                    historicData.dailyData.append(dailyData)
                }
                semaphore.signal()
            } catch let jsonError {
                print("JSON error: \(jsonError)")
            }
        }.resume()
        
        semaphore.wait()
        security.historicalData = historicData
        DatabaseController.shared.updateHistoricalData(for: security)
        return historicData
    }
    
    // MARK: - Short
    
    static func fetchShortSqueezeData(for security: Security) -> ShortSqueezeDatasource? {
        return nil
    }
    
    /// Fetches all tickers available via the IEX API.
    static func getAllSymbols() -> [MinimalSecurity] {
        guard let url = URL(string: "https://api.iextrading.com/1.0/ref-data/symbols") else { return [] }
        let semaphore = DispatchSemaphore(value: 0)
        var minimals = [MinimalSecurity]()

        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            do {
                minimals = try JSONDecoder().decode([MinimalSecurity].self, from: data)
            } catch let jsonError {
                print("JSON error: \(jsonError)")
            }
            semaphore.signal()
        }.resume()

        semaphore.wait()
        return minimals
    }
    
}
