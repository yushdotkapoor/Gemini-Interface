//
//  Account.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import SwiftyJSON
import Alamofire

class Account:Decodable {
    static let shared = Account()
    
    func GetAccountDetail() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.AccountDetail(())
        
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
    
    
    func CheckAvailableBalances() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Balances(())
        
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
    
    
    func CheckNotionalBalances() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.NotionalBalances(())
        
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
    
    
    func CheckTransfers(LimitTransfers:Int?=20, ShowCompleteDepositAdvances:Bool?=false) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Transfers(())
        
        let payload:[String : Any] = ["request": endpoint.path,
                                      "show_completed_deposit_advances": ShowCompleteDepositAdvances!]
        
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
    
    
    func GetDepositAddresses(network:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.DepositAddresses(network: network)
        
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
    
    
    func GetApprovedAddresses(network:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.ApprovedAddresses(network: network)
        
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
    
    
    func WithdrawCryptoFunds(currencyCode:String, address:String, amount:String) async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.WithdrawalCrypto(currencyCode: currencyCode)
        
        let payload:[String : Any] = ["request": endpoint.path,
                                      "address": address,
                                      "amount": amount]
        
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
    
}
