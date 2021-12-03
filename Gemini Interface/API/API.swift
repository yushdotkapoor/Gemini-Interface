//
//  API.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 11/30/21.
//

import Foundation
import Alamofire
import SwiftyJSON

class API {
    
    static let base = "https://api.gemini.com"
    
    static let apiKey = Keys().apiKey
    static let apiSecret = Keys().apiSecret
    
    /**
     * An abstraction layer on top of the Gemini API to allow for simple handeling of API
     * calls in a more standard way.
     *
     * - property method: the HTTP method (post, get, ...) of the request
     * - property path: The path of the request
     */
    public enum Endpoints {
        
        case AccountDetail(Void)
        case Balances(Void)
        case NotionalBalances(Void)
        case Transfers(Void)
        case DepositAddresses(network: String)
        case ApprovedAddresses(network: String)
        case WithdrawalCrypto(currencyCode: String)
        case Heartbeat(Void)
        case Pubticker(ticker: String)
        case Ticker(ticker: String)
        case Symbols(Void)
        case SymbolDetails(ticker: String)
        case NotionalVolume(Void)
        case TradeVolume(Void)
        case MyTrades(Void)
        case CancelSessionOrders(Void)
        case CancelOrder(Void)
        case OrderStatus(Void)
        case ActiveOrders(Void)
        case CancelActiveOrders(Void)
        case OrderNew(Void)
        case PriceFeed(Void)
        
        public var method: HTTPMethod {
            switch self {
            case .Heartbeat, .AccountDetail, .Balances, .NotionalBalances, .Transfers, .DepositAddresses, .ApprovedAddresses, .WithdrawalCrypto, .MyTrades, .CancelSessionOrders, .CancelActiveOrders, .CancelOrder, .OrderStatus, .ActiveOrders, .OrderNew:
                return .post
            case  .Pubticker, .Ticker, .Symbols, .SymbolDetails, .NotionalVolume, .TradeVolume, .PriceFeed:
                return .get
            }
        }
        
        public var path: String {
            switch self {
            case .AccountDetail:
                return "/v1/account"
            case .Balances:
                return "/v1/balances"
            case .NotionalBalances:
                return "/v1/notionalbalances/usd"
            case .Transfers:
                return "/v1/transfers"
            case .DepositAddresses(let network):
                return "/v1/addresses/\(network)"
            case .ApprovedAddresses(let network):
                return "/v1/approvedAddresses/account/\(network)"
            case .WithdrawalCrypto(let currencyCode):
                return "/v1/withdraw/\(currencyCode)"
            case .Heartbeat:
                return "/v1/heartbeat"
            case .Pubticker(let ticker):
                return "/v1/pubticker/\(ticker)"
            case .Ticker(let ticker):
                return "/v1/ticker/\(ticker)"
            case .Symbols:
                return "/v1/symbols"
            case .SymbolDetails(let ticker):
                return "/v1/symbols/details/\(ticker)"
            case .NotionalVolume:
                return "/v1/notionalvolume"
            case .TradeVolume:
                return "/v1/tradevolume"
            case .MyTrades:
                return "/v1/mytrades"
            case .CancelSessionOrders:
                return "/v1/order/cancel/session"
            case .CancelOrder:
                return "/v1/order/cancel"
            case .OrderStatus:
                return "/v1/order/status"
            case .ActiveOrders:
                return "/v1/orders"
            case .CancelActiveOrders:
                return "/v1/order/cancel/all"
            case .OrderNew:
                return "/v1/order/new"
            case .PriceFeed:
                return "/v1/pricefeed"
            }
        }
        
        public var url: String {
            return base + self.path
        }
        
        public var headers: HTTPHeaders {
            return createHeaders(request: self.path)
        }
        
    }
    
    
    /**
     Create HTTP Headers for a gemini request
     
     - parameter request: the path, ex: "/v1/order/status", of the request.
     - parameter additionalData: the additional payload data requested by the API
     
     - returns: the http headers for the request
    */
    private static func createHeaders(request: String, withAdditionalData additionalData: JSON? = nil) -> HTTPHeaders {
        
        var payload = additionalData ?? JSON()
        let nonce = Int64(Date().timeIntervalSince1970 * 1000)
        payload["request"] = JSON(request)
        payload["nonce"]  = JSON(String(nonce))
        let payloadb64 = payload.serialize().toBase64()
        
        var headerArray:[HTTPHeader] = []
        headerArray.append(HTTPHeader(name: "Content-Type", value: "text/plain"))
        headerArray.append(HTTPHeader(name: "Content-Length", value: "0"))
        headerArray.append(HTTPHeader(name: "X-GEMINI-APIKEY", value: apiKey))
        headerArray.append(HTTPHeader(name: "X-GEMINI-PAYLOAD", value: payloadb64))
        headerArray.append(HTTPHeader(name: "X-GEMINI-SIGNATURE", value: payloadb64.hmac(algorithm: .SHA384, key: apiSecret)))
        headerArray.append(HTTPHeader(name: "Cache-Control", value: "no-cache"))
        
        let headers:HTTPHeaders = HTTPHeaders(headerArray)
        
        
        return headers
    }
}


extension JSON {
    
    // serialize the json into a standard JSON string
    func serialize() -> String {
        let s0: String = self.rawString() ?? ""
        let s1: String = s0.replacingOccurrences(of: "\\/", with: "/")
        return s1
    }
    
}
