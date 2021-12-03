//
//  MarketsLandingPage.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/3/21.
//

import Foundation
import UIKit

class MarketsLandingPage: UIViewController {
    
    var crypto: Cryptocurrency?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = crypto?.coin.name
        
    }
}
