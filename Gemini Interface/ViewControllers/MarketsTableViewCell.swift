//
//  MarketsTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit

class MarketsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var percentageChange: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cryptoID: UILabel!
    @IBOutlet weak var cryptoName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        selectedBackgroundView?.layer.cornerRadius = 20
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addShadows(uiview: imgView)
    }
    
    func addShadows(uiview:UIView) {
        uiview.layer.cornerRadius = uiview.frame.height/3
        addShadow(uiview: uiview)
        uiview.layer.shadowOffset = CGSize(width: 1, height: 1)
        uiview.layer.shadowRadius = 3
        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: uiview.frame.width, height: uiview.frame.height))
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = imgView.frame.height/4
        uiview.addSubview(imgView)
        
        addShadow(uiview: self)
        layer.shadowOffset = CGSize(width: 2, height: 2)
        layer.shadowRadius = 6
    }
    
    func addShadow(uiview:UIView) {
        uiview.layer.masksToBounds = false
        uiview.layer.shadowColor = UIColor.secondaryLabel.cgColor
        uiview.layer.shadowOpacity = 1
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
    }
    
}
