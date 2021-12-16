//
//  UIStackViewExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/5/21.
//

import Foundation
import UIKit

extension UIStackView {
    
    func refactor(reference:UIView, top:CGFloat=0, bottom:CGFloat=0, leading:CGFloat=0, trailing:CGFloat=0) {
        var heights:[CGFloat] = []
        var horizontalHeights:[CGFloat] = []
        var widths:[CGFloat] = []
        var verticalWidths:[CGFloat] = []
        
        let textFieldHeightConstant = 0.8379705401
        
        for subview in arrangedSubviews {
            var ht:CGFloat = subview.frame.height
            var wt:CGFloat = subview.frame.width

            if let sub = subview as? UILabel {
                ht = sub.textHeight(withWidth: UIScreen.main.bounds.width)
                wt = sub.textWidth(withHeight: ht)
//                subview.heightAnchor.constraint(equalToConstant: ht).isActive = true
//                subview.widthAnchor.constraint(equalToConstant: wt).isActive = true
                if axis == .horizontal {
                    constrain(reference: self, top: 0, bottom: 0)
                } else {
                    constrain(reference: self, leading: 0, trailing: 0)
                }
            }
            if axis == .horizontal {
                horizontalHeights.append(ht)
                widths.append(wt)
            } else {
                heights.append(ht)
                verticalWidths.append(wt)
            }
        }
        
        if let _ = reference as? UIStackView {} else {
            constrain(reference: reference, top: top, bottom: bottom, leading: leading, trailing: trailing)
        }
        
//        let spaces = CGFloat(arrangedSubviews.count - 1) * spacing
//        axis == .horizontal ? widths.append(spaces):heights.append(spaces)
//
//
//        let maxHorizontalHeight = horizontalHeights.max()
//        if maxHorizontalHeight != nil && maxHorizontalHeight != 0 {
//            heights.append(maxHorizontalHeight!)
//        }
//
//        let maxVerticalWidth = verticalWidths.max()
//        if maxVerticalWidth != nil && maxVerticalWidth != 0 {
//            widths.append(maxVerticalWidth!)
//        }
//
//        for i in constraints {
//            i.isActive = true
//        }
//
//
//        heightAnchor.constraint(equalToConstant: heights.sum()).isActive = true
//        if width == 1 {
//            widthAnchor.constraint(equalToConstant: widths.sum()).isActive = true
//        } else {
//            widthAnchor.constraint(equalToConstant: width).isActive = true
//        }
        
        translatesAutoresizingMaskIntoConstraints = false
        layoutIfNeeded()
    }
    
    func refactors(withWidth width:CGFloat=1, constraints:[NSLayoutConstraint]=[]) {
        var heights:[CGFloat] = []
        var horizontalHeights:[CGFloat] = []
        var widths:[CGFloat] = []
        var verticalWidths:[CGFloat] = []
        
        let textFieldHeightConstant = 0.8379705401
        
        for subview in arrangedSubviews {
            var ht:CGFloat = subview.frame.height
            var wt:CGFloat = subview.frame.width

            if let sub = subview as? UILabel {
                ht = sub.textHeight(withWidth: UIScreen.main.bounds.width)
                wt = sub.textWidth(withHeight: ht)
                subview.heightAnchor.constraint(equalToConstant: ht).isActive = true
                subview.widthAnchor.constraint(equalToConstant: wt).isActive = true
            }
            if axis == .horizontal {
                horizontalHeights.append(ht)
                widths.append(wt)
            } else {
                heights.append(ht)
                verticalWidths.append(wt)
            }
        }
        
        let spaces = CGFloat(arrangedSubviews.count - 1) * spacing
        axis == .horizontal ? widths.append(spaces):heights.append(spaces)
        
        
        let maxHorizontalHeight = horizontalHeights.max()
        if maxHorizontalHeight != nil && maxHorizontalHeight != 0 {
            heights.append(maxHorizontalHeight!)
        }
        
        let maxVerticalWidth = verticalWidths.max()
        if maxVerticalWidth != nil && maxVerticalWidth != 0 {
            widths.append(maxVerticalWidth!)
        }
        
        for i in constraints {
            i.isActive = true
        }
        
        
        heightAnchor.constraint(equalToConstant: heights.sum()).isActive = true
        if width == 1 {
            widthAnchor.constraint(equalToConstant: widths.sum()).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        layoutIfNeeded()
    }
    
  
}
