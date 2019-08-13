//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

let url = URL(string: "https://sandbox.iexapis.com/stable/stock/sq/quote?token=Tsk_c4ac493e5fce4aab9e71f9e911e5f482")!

URLSession.shared.dataTask(with: url) {(data, response, error) in
    guard let data = data else { return }
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
        print(json)
        let security = try JSONDecoder().decode(Security.self, from: data)
        print(security)
    } catch let jsonError {
        print(jsonError)
    }
}.resume()

sleep(1)
