//
//  StringExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 11/30/21.
//

import Foundation


extension String {
    
    func toBase64()->String{
        let data = self.data(using: .utf8)
        return data!.base64EncodedString()
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func substring(from: Int, to: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        let end = index(start, offsetBy: to - from)
        return String(self[start ..< end])
    }
    
    func substring(range: NSRange) -> String {
        return substring(from: range.lowerBound, to: range.upperBound)
    }
    
    func convertToDictionary() -> NSArray {
        let data = Data(utf8)
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSArray
            return json!
        } catch {
            print("Something went wrong \(error)")
        }
        
        return NSArray()
    }
    
    mutating func appendPath(path: String) {
        self.append((self.last == "/" || path.first == "/" ? "":"/") + path + (path.last == "/" ? "" : "/"))
    }
}
