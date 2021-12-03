//
//  UIButtonExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 11/30/21.
//

import Foundation
import UIKit

extension UIButton {
    func roundAndFill() {
        layer.cornerRadius = frame.height/2
        backgroundColor = .label
        layer.masksToBounds = true
    }
}
