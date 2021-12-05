//
//  DataGuzzler.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import SwiftyJSON

class CryptoData {
    static let shared = CryptoData()
    var coins:[String: Coin] = [:]
    var tickers: [String] = []
    var update: (() -> Void)?
    
    var cryptocurrencies: [String: Cryptocurrency] = [:] {
        didSet {
            UserDefaults.standard.setValue(try! PropertyListEncoder().encode(cryptocurrencies), forKey: "currencyCache")
            update?()
        }
    }
}

class DataGuzzler {
    static let shared = DataGuzzler()
    
    func one(geminiCoins: [Coin]) async {
        print("alternate Activated")
        
        var ids:[String] = []
        var symbols:[String] = []
        var names:[String] = []
        
        for i in geminiCoins {
            ids.append(i.id!)
            symbols.append(i.symbol!)
            names.append(i.name!)
        }
        
        var relevantCoins = await CoinGecko.shared.search(ids: ids, symbols: symbols, names: names)
        for i in geminiCoins {
            if let foo = relevantCoins.enumerated().first(where: {$0.element.symbol! == i.symbol!}) {
                relevantCoins[foo.offset].name = i.name
            }
        }
        
        var tickers:[String] = []
        for i in relevantCoins {
            tickers.append(i.symbol! + "usd")
            CryptoData.shared.coins[i.symbol!] = i
        }
        CryptoData.shared.tickers = tickers
        
        await getCryptocurrencies()
    }
    
    func oneTime() async {
        let geminiCoins = await Crypto.shared.GetCoins()
        
        await CoinGecko.shared.fetch()
        
        if let currencyCache = UserDefaults.standard.data(forKey: "currencyCache") {
            do {
                let cache = try PropertyListDecoder().decode([String: Cryptocurrency].self, from: currencyCache)
                CryptoData.shared.cryptocurrencies = cache
            } catch {
                print(error)
                await self.one(geminiCoins: geminiCoins)
                return
            }
        }
        
        var t:[String] = []
        for i in CryptoData.shared.cryptocurrencies {
            t.append(i.value.coin.name!)
        }
        
        var tempGemini:[Coin] = []
        for i in geminiCoins {
            if t.contains(i.name!) {
                tempGemini.append(i)
            }
        }
        if tempGemini.count == CryptoData.shared.cryptocurrencies.count && tempGemini.count != 0 {
            
            var tickers:[String] = []
            
            let currency = CryptoData.shared.cryptocurrencies
            let symbols = currency.keys
            for i in symbols {
                tickers.append(i + "usd")
                CryptoData.shared.coins[i] = currency[i]?.coin
            }
            
            CryptoData.shared.tickers = tickers
            
            await getCryptocurrencies()
            
        } else {
            await self.one(geminiCoins: geminiCoins)
            return
        }
    }
    
    func getCryptocurrencies() async {
        let balances = await Account.shared.CheckAvailableBalances().rawValue as! [[String: Any]]
        let trades = await Orders.shared.GetTradesForCrypto().rawValue as! [[String:Any]]
        var cryptos:[String: Cryptocurrency] = [:]
        for i in CryptoData.shared.tickers {
            let shorti = i.substring(from: 0, to: i.count-3)
            print(shorti)
            
            let coin = CryptoData.shared.coins[shorti]!
            
            var dictionary:[String: Any] = [:]
            balances.forEach({balance in
                if (balance["currency"] as! String).lowercased() == coin.symbol!.lowercased() {
                    dictionary = balance
                }
            })
            let holdings = dictionary["amount"] as? String ?? "0"
            let available = dictionary["availableForWithdrawal"] as? String ?? "0"
            let averageBuyPrice = getAverageBuyPrice(trades: trades, ticker: i)
            let profits = getProfit(trades: trades, ticker: i, averageBuyPrice: Double(averageBuyPrice)!)
            let minimum = await Crypto.shared.GetSymbolDetails(ticker: i).rawValue as! [String: Any]
            let quoteIncrement = Double("\(minimum["quote_increment"] ?? "0.001")")!
            let tickSize = Double("\(minimum["tick_size"] ?? "0.000001")")!
            let cryptocurrency = Cryptocurrency(coin: coin, holdings: holdings, averageBuyPrice: averageBuyPrice, availableForWithdrawal: available, minimum: quoteIncrement, tickSize: tickSize, profit: profits)
            cryptos[coin.symbol!] = cryptocurrency
        }
        CryptoData.shared.cryptocurrencies = cryptos
        
        priceFeed()
    }
    
    @objc func priceFeed() {
        async {
            if let newData = await Crypto.shared.getPriceFeed().rawValue as? [[String:String]] {
                var cryptos:[String: Cryptocurrency] = [:]
                for datum in newData {
                    let pair = datum["pair"] ?? ""
                    let price = Double(datum["price"] ?? "")
                    let percentChange24h = Double(datum["percentChange24h"] ?? "")
                    let last = pair.substring(from: pair.count-3, to: pair.count).lowercased()
                    if last == "usd" {
                        let formattedPair = pair.substring(from: 0, to: pair.count-3).lowercased()
                        let coin = CryptoData.shared.cryptocurrencies[formattedPair]
                        coin?.coin.price = price
                        coin?.coin.priceChangePercentage24h = percentChange24h! * 100
                        if percentChange24h! > 0 {
                            coin?.coin.priceChange24h = price! - (price!/(percentChange24h! + 1))
                        } else if percentChange24h! < 0 {
                            coin?.coin.priceChange24h = price! - (-price!/(percentChange24h! - 1))
                        } else {
                            coin?.coin.priceChange24h = 0.0
                        }
                        
                        cryptos[formattedPair] = coin
                    }
                }
                CryptoData.shared.cryptocurrencies = cryptos
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            self.priceFeed()
        })
    }
    
    func getProfit(trades: [[String:Any]], ticker: String, averageBuyPrice: Double) -> String {
        var totalEarned:[Double] = []
        var totalHoldings:[Double] = []
        for trade in trades {
            let price = trade["price"] as! String
            let amount = trade["amount"] as! String
            let type = trade["type"] as! String
            let symbol = trade["symbol"] as! String
            let moneySpent = Double(amount)! * Double(price)!
            
            if type == "Sell" && symbol.lowercased() == (ticker) {
                totalEarned.append(moneySpent)
                totalHoldings.append(Double(amount)!)
            }
            
        }
        
        let spendingSum = totalEarned.reduce(.zero, +)
        let holdingsSum = totalHoldings.reduce(.zero, +)
        
        if holdingsSum == 0 {
            return "0.0"
        }
        
        let averageSellPrice = spendingSum / holdingsSum
        
        return String((averageSellPrice - averageBuyPrice) * holdingsSum)
    }
    
    func getAverageBuyPrice(trades: [[String:Any]], ticker: String) -> String {
        var totalSpent:[Double] = []
        var totalHoldings:[Double] = []
        for trade in trades {
            let price = trade["price"] as! String
            let amount = trade["amount"] as! String
            let type = trade["type"] as! String
            let symbol = trade["symbol"] as! String
            let moneySpent = Double(amount)! * Double(price)!
            
            if type == "Buy" && symbol.lowercased() == (ticker) {
                totalSpent.append(moneySpent)
                totalHoldings.append(Double(amount)!)
            }
        }
        
        let spendingSum = totalSpent.reduce(.zero, +)
        let holdingsSum = totalHoldings.reduce(.zero, +)
        
        if holdingsSum == 0 {
            return "0.0"
        }
        return String(spendingSum / holdingsSum)
    }
}

