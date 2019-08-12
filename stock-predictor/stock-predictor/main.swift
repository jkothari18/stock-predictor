//
//  main.swift
//  stock-predictor
//
//  Created by Ryan Elliott on 8/12/19.
//  Copyright © 2019 Ryan Elliott. All rights reserved.
//

import Foundation

let url = URL(string: "https://sandbox.iexapis.com/stable/stock/aapl/quote?token=Tsk_c4ac493e5fce4aab9e71f9e911e5f482")!

URLSession.shared.dataTask(with: url) {(data, response, error) in
    guard let data = data else { return }
    print(String(data: data, encoding: .utf8)!)
}.resume()

sleep(1)
