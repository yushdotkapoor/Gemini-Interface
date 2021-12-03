//
//  Cryptos.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import SwiftyJSON
import Alamofire

class Crypto:Decodable {
    static let shared = Crypto()
    
    func GetPubticker(ticker:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Pubticker(ticker: ticker)
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    func GetTicker(ticker:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Ticker(ticker: ticker)
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    func GetCoins() async -> [Coin] {
        let url = "https://www.gemini.com/prices"
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(URL(string: url)!).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        var symbols:[Coin] = []
        let response = String(data: apiRequest.data!, encoding: .utf8) ?? ""
        
        let dataArray = response.slice(from: "coinPriceOverviews\":", to: "},\"__N_SSG\"")!.convertToDictionary()
        
        for i in dataArray {
            if let cryptoInfo = i as? [String:Any] {
                let name = cryptoInfo["name"] as! String
                let slug = cryptoInfo["slug"] as! String
                let coin = cryptoInfo["coin"] as! String
                
                symbols.append(Coin(id: slug, symbol: coin.lowercased(), name: name))
            }
        }
        return symbols
    }
    
    func GetSymbols() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Symbols(())
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    
    func GetSymbolDetails(ticker:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.SymbolDetails(ticker: ticker)
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    
    func GetNotionalVolume() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.NotionalVolume(())
        
        let payload:[String : Any] = ["request": endpoint.path]
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, parameters: payload, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    
    func GetTradeVolume() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.TradeVolume(())
        
        let payload:[String : Any] = ["request": endpoint.path]
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, parameters: payload, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    func getPriceFeed() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.PriceFeed(())
        
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, headers: endpoint.headers).validate().responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error")
        }
        return jData
    }
    
    
    func GetPrice(ticker:String, side:Side) async -> JSON {
        let tickerData = await GetPubticker(ticker: ticker)
        if side.rawValue == "buy" {
            return tickerData["ask"]
        } else {
            return tickerData["bid"]
        }
    }
    
    
    
    
}
