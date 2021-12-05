//
//  Cryptocurrency.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation

class Cryptocurrency: Codable {
    var coin: Coin
    var holdings: String
    var averageBuyPrice: String
    var availableForWithdrawal: String
    var minimum: Double
    var tickSize: Double
    var profit: String
    
    init(coin: Coin, holdings: String, averageBuyPrice: String, availableForWithdrawal: String, minimum: Double, tickSize: Double, profit: String) {
        self.coin = coin
        self.holdings = holdings
        self.averageBuyPrice = averageBuyPrice
        self.availableForWithdrawal = availableForWithdrawal
        self.minimum = minimum
        self.tickSize = tickSize
        self.profit = profit
    }
}
