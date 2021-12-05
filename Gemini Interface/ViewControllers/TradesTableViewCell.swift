//
//  TradesTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/3/21.
//

import UIKit

class TradesTableViewCell: UITableViewCell {

    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var pricePerUnit: UILabel!
    @IBOutlet weak var totalCost: UILabel!
    @IBOutlet weak var coins: UILabel!
    @IBOutlet weak var transactionDate: UILabel!
    @IBOutlet weak var fee: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
