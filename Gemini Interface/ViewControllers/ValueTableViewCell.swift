//
//  ValueTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/8/21.
//

import UIKit

class ValueTableViewCell: UITableViewCell {

    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var change: UILabel!
    @IBOutlet weak var percChange: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
