//
//  CoinGecko.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import Charts

class CoinGecko {
    static let shared = CoinGecko()
    
    var allCoins: [Coin] = []
    
    
    func fetch() async {
        let array = await array(from: "https://api.coingecko.com/api/v3/coins/list")
        for dict in array {
            guard let d = dict as? [String:Any] else { return }
            
            self.allCoins.append(Coin(id: d["id"] as? String, symbol: d["symbol"] as? String, name: d["name"] as? String))
        }
    }
    
    func coins(ids: [String] = [], sorting: Sorting = .market_cap_desc, perPage: Int = 250) async -> [Coin] {
        var coins:[Coin] = []
        var page = 1
        while ids.count != 0 {
            var url = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=\(sorting.rawValue)&per_page=\(perPage)&page=\(page)&sparkline=false"
            
            url.append("&ids=\(ids.joined(separator: ","))")
            
            let array = await array(from: url)
            for dict in array {
                guard let d = dict as? [String:Any] else { return [] }
                coins.append(Coin(id: d["id"] as? String, symbol: d["symbol"] as? String, name: d["name"] as? String, imageURL: d["image"] as? String, price: d["current_price"] as? Double, marketCap: d["market_cap"] as? Double, marketCapRank: d["market_cap_rank"] as? Double, totalVolume: d["total_volume"] as? Double, high24h: d["high_24h"] as? Double, low24h: d["low_24h"] as? Double, priceChange24h: d["price_change_24h"] as? Double, priceChangePercentage24h: d["price_change_percentage_24h"] as? Double, ath: d["ath"] as? Double))
                
            }
            page += 1
            if page > 10 {
                break
            }
        }
        return coins
        
    }
    
    func getRelevantToken(ids: String, symbols:String="", names:String="") -> String {
        var idsResults:[String] = []
        var symbolsResults:[String] = []
        var namesResults:[String] = []
        
        var rating:[String: Int] = [:]
        
        for coin in allCoins {
            //print("id: \(coin.id), name: \(coin.name), symbol: \(coin.symbol)")
            //print(string)
            if coin.id!.lowercased() == ids.lowercased() {
                idsResults.append(coin.id!)
                
            }
            if symbols != "" {
                if coin.symbol!.lowercased() == symbols.lowercased() {
                    symbolsResults.append(coin.id!)
                    rating[coin.id!] = 0
                }
            }
            if names != "" {
                if coin.name!.lowercased() == names.lowercased() {
                    namesResults.append(coin.id!)
                }
            }
        }
        
        
        for result in symbolsResults {
            if idsResults.contains(result) {
                rating[result] = rating[result]! + 1
            }
            if symbolsResults.contains(result) {
                rating[result] = rating[result]! + 1
            }
            if  namesResults.contains(result) {
                rating[result] = rating[result]! + 1
            }
        }
        
        var maxRate:(Int, String) = (0,"")
        for i in rating.keys {
            let rated = rating[i]!
            if rated > maxRate.0 {
                maxRate = (rated, i)
            }
        }
        
        return maxRate.1
    }
    
    func search(ids: [String], symbols:[String]=[], names:[String]=[]) async -> [Coin] {
        var idsToEvaluate:[String] = []
        for (index, value) in ids.enumerated() {
            let id = getRelevantToken(ids: value, symbols: symbols != [] ? symbols[index]:"", names: names != [] ? names[index]:"")
            idsToEvaluate.append(id)
        }
        return await coins(ids: idsToEvaluate)
    }
    
    func history(for coin:Coin, from date1:Date, to date2:Date) async -> [PricePoint] {
        guard let coinId = coin.id else { return [] }
        
        let dictionary = await dictionary(from: "https://api.coingecko.com/api/v3/coins/\(coinId)/market_chart/range?vs_currency=usd&from=\(date1.timeIntervalSince1970)&to=\(date2.timeIntervalSince1970)")
        let array = dictionary["prices"] as! [[Double]]
        
        var points:[PricePoint] = []
        for point in array {
            points.append(PricePoint(price: point[1], unixTimestamp: point[0]))
        }
        
        return points
    }
    
    func history(for cryptoID:String, daysAgo:String, interval:String) async -> [ChartDataEntry] {
        
        let dictionary = await dictionary(from: "https://api.coingecko.com/api/v3/coins/\(cryptoID)/market_chart?vs_currency=usd&days=\(daysAgo)&interval=\(interval)")
        let array = dictionary["prices"] as! [[Double]]
        
        var entries:[ChartDataEntry] = []
        for entry in array {
            entries.append(ChartDataEntry(x: entry[0], y: entry[1]))
        }
        return entries
    }
    
    private func dictionary(from url: String) async -> [String: Any] {
        let response = await text(from: url)
        return self.convertToDictionary(response)!
    }
    private func array(from url: String) async -> [Any] {
        let response = await text(from: url)
        return self.convertToArray(response)!
    }
    private func text(from url: String) async -> String {
        var jData:String = String()
        let headers = HTTPHeaders(arrayLiteral: HTTPHeader(name: "User-Agent", value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.100 Safari/537.36"))
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(URL(string: url)!, headers: headers).validate().responseJSON(completionHandler: { apiRequest in
                continuation.resume(returning: apiRequest)
            })
        }
        
        jData = String(data: apiRequest.data!, encoding: .utf8) ?? ""
        return jData
    }
    
    fileprivate func convertToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    fileprivate func convertToArray(_ text: String) -> [Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    enum Sorting: String {
        case gecko_desc, gecko_asc, market_cap_asc, market_cap_desc, volume_asc, volume_desc, id_asc, id_desc
    }
}

class PricePoint: Codable {
    //static var supportsSecureCoding: Bool = true
    
    var price: Double
    var unixTimestamp: TimeInterval
    
    var date: Date {
        get {
            return Date(timeIntervalSince1970: unixTimestamp)
        } set {
            unixTimestamp = newValue.timeIntervalSince1970
        }
    }
    
    init(price:Double, unixTimestamp:TimeInterval) {
        self.price = price
        self.unixTimestamp = unixTimestamp
    }
    
}


struct Coin: Codable {
    
    var id: String?
    var symbol: String?
    var name: String?
    var imageURL: String?
    
    var price: Double?
    
    var marketCap: Double?
    var marketCapRank: Double?
    var totalVolume: Double?
    
    var high24h: Double?
    var low24h: Double?
    
    var priceChange24h: Double?
    var priceChangePercentage24h: Double?
    
    var ath:Double?
}
