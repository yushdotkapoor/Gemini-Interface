//
//  Orders.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import SwiftyJSON
import Alamofire

class Orders: Decodable {
    static let shared = Orders()
    
    func GetTradesForCrypto(ticker:String="BTCUSD", limit_trades:Int?=50) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.MyTrades(())
        let payload:[String : Any] = ["request": endpoint.path,
                                      "symbol": ticker,
                                      "limit_trades": limit_trades!]
        
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
    
    func CancelAllSessionOrders() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.CancelSessionOrders(())
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
    
    func CancelAllActiveOrders() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.CancelActiveOrders(())
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
    
    
    func CancelOrder(orderId:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.CancelOrder(())
        let payload:[String : Any] = ["request": endpoint.path,
                                      "order_id": orderId]
        
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
    
    
    func OrderStatus(orderId:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.OrderStatus(())
        let payload:[String : Any] = ["request": endpoint.path,
                                      "order_id": orderId]
        
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
    
    func ActiveOrders() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.ActiveOrders(())
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
    
    
    func Order(ticker:String, quantity:String, side:Side, price:String?=nil, stopLimitPrice:String?=nil, minAmount:String?=nil, options:[String]?=nil) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.OrderNew(())
        print(ticker)
        var payload:[String : Any] = [  "client_order_id": GenerateOrderID(),
                                        "request": endpoint.path,
                                        "symbol": ticker,
                                        "amount": quantity,
                                        "side": side.rawValue
        ]
        
        if (price != nil) {
            payload["price"] = price
        } else {
            payload["price"] = await Crypto.shared.GetPrice(ticker: ticker, side: side).rawValue
        }
        if (stopLimitPrice != nil) {
            payload["type"] = "exchange stop limit"
            payload["stop_price"] = stopLimitPrice
        } else {
            payload["type"] = "exchange limit"
        }
        if (minAmount != nil) {
            payload["min_amount"] = minAmount
        }
        if (options != nil) {
            payload["options"] = options
        }
        
        let headers = API.createHeaders(request: endpoint.path, withAdditionalData: try! JSON(data: try! JSONSerialization.data(withJSONObject: payload)))
        let apiRequest = await withCheckedContinuation { continuation in
            AF.request(endpoint.url, method: endpoint.method, parameters: payload, headers: headers).responseData { apiRequest in
                continuation.resume(returning: apiRequest)
            }
        }
        
        do {
            let data = try JSONDecoder().decode(JSON.self, from: apiRequest.data!)
            jData = data
        } catch {
            print("error \(error)")
        }
        return jData
    }
}


