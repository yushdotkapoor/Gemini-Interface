//
//  ArrayExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/5/21.
//

import Foundation
import UIKit

extension Array where Element == CGFloat {
    func sum() -> CGFloat {
        var sum:CGFloat = 0
        for i in self {
            sum += i
        }
        return sum
    }
}
