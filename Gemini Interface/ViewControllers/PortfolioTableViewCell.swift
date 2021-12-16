//
//  PortfolioTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/8/21.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var holdings: UILabel!
    @IBOutlet weak var holdingsID: UILabel!
    @IBOutlet weak var ID: UILabel!
    @IBOutlet weak var name: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
