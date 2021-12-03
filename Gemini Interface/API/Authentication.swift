//
//  Authentication.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import SwiftyJSON
import Alamofire

class Authentication:Decodable {
    static let shared = Authentication()
    
    func Heartbest() async -> JSON {
        var jData:JSON = JSON()
        let endpoint = API.Endpoints.Heartbeat(())
        
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
    
}
