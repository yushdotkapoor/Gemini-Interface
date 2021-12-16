//
//  UILabelExtension.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/5/21.
//

import Foundation
import UIKit

extension UILabel {
    func textHeight(withWidth width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.height(usingFont: font)
    }
    
    func textWidth(withHeight height: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.width(usingFont: font)
    }
    
    //initializes label with many properties to save space
    func initLabel(textLbl:String="", size:CGFloat=17, font:UIFont=UIFont.systemFont(ofSize: 16), color:UIColor=UIColor.label, textAlignment:NSTextAlignment=NSTextAlignment.left) -> UILabel {
        self.numberOfLines = 0
        self.textAlignment = textAlignment
        self.font = font
        self.font = self.font.withSize(size)
        self.textColor = color
        self.text = textLbl
        return self
    }
    
}
