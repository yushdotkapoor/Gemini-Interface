//
//  MarketsTableViewCell.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit
import Charts

class MarketsTableViewCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var percentageChange: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var cryptoID: UILabel!
    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var chart: LineChartView!
    
    var chartData:[ChartDataEntry]?
    
    var animated = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 20
        selectedBackgroundView?.layer.cornerRadius = 20
        
        UserDefaults.standard.addObserver(self, forKeyPath: "chartsEnabled", options: NSKeyValueObservingOptions.new, context: nil)
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
    
    func getData() {
        if chartData != nil {
            let set1 = LineChartDataSet(entries: chartData!, label: "DataSet 1")
            set1.mode = LineChartDataSet.Mode.cubicBezier
            set1.drawCirclesEnabled = false
            set1.lineWidth = 1.8
            set1.circleRadius = 4
            set1.setCircleColor(UIColor.black)
            set1.fillColor = UIColor.black
            set1.fillAlpha = 1
            
            let data = LineChartData(dataSet: set1)
            
            chart.data = data
            
            if !animated {
                chart.animate(xAxisDuration: 1.25)
            }
            animated = true
        }
    }
    
    func setCharts() {
        print("soi")
        let chartStatus = UserDefaults.standard.bool(forKey: "chartsEnabled")
        if chartStatus {
            chart.isHidden = false
        } else {
            chart.isHidden = true
        }
        
        getData()
        
        chart.delegate = self
        chart.isUserInteractionEnabled = false
        
        chart.backgroundColor = .secondarySystemBackground
        chart.xAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.leftAxis.enabled = false
        chart.legend.enabled = false
        
        chart.layer.cornerRadius = 20
        chart.layer.masksToBounds = true
    }

deinit {
    UserDefaults.standard.removeObserver(self, forKeyPath: "chartsEnabled")
}
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "chartsEnabled" {
            let newValue = change![NSKeyValueChangeKey.newKey]! as! Bool
            if newValue {
                chart.isHidden = false
            } else {
                chart.isHidden = true
            }
        }
    }
    
}
