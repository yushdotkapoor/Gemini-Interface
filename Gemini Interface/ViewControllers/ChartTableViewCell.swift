//
//  ChartTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/8/21.
//

import UIKit
import Charts

class ChartTableViewCell: UITableViewCell {

    @IBOutlet weak var chart: LineChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
