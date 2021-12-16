//
//  UIViewExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/5/21.
//

import Foundation
import UIKit

extension UIView {
    func constrain(reference:UIView, top:CGFloat?=nil, bottom:CGFloat?=nil, leading:CGFloat?=nil, trailing:CGFloat?=nil) {
        if let topConstant = top {
            topAnchor.constraint(equalTo: reference.topAnchor, constant: topConstant).isActive = true
        }
        if let bottomConstant = bottom {
            bottomAnchor.constraint(equalTo: reference.bottomAnchor, constant: -bottomConstant).isActive = true
        }
        if let leadingConstant = leading {
            leadingAnchor.constraint(equalTo: reference.leadingAnchor, constant: leadingConstant).isActive = true
        }
        if let trailingConstant = trailing {
            trailingAnchor.constraint(equalTo: reference.trailingAnchor, constant: -trailingConstant).isActive = true
        }
    }
}
