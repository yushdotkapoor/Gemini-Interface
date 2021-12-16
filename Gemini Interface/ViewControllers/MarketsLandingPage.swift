//
//  MarketsLandingPage.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/3/21.
//

import Foundation
import UIKit
import Charts
import Firebase

class MarketsLandingPage: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //CHART
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var cryptoID: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var priceChange: UILabel!
    @IBOutlet weak var percentageChange: UILabel!
    @IBOutlet weak var chart: LineChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var crypto: Cryptocurrency?
    
    let daysAgo = ["1", "1", "30", "30", "30", "60", "max"]
    let interval = ["minute", "minute", "hourly", "hourly", "hourly", "daily", "daily"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CryptoData.shared.update = updatePriceLabels
        doForCharts()
        doForGeneral()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true
        CryptoData.shared.update = updatePriceLabels
    }
    
    func doForCharts() {
        setupLabels()
        
        getData()
        
        chart.delegate = self
        
        chart.setViewPortOffsets(left: 0, top: 20, right: 0, bottom: 20)
        chart.backgroundColor = .secondarySystemBackground
        
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = false
        chart.maxHighlightDistance = 300
        chart.highlightPerDragEnabled = true
        chart.highlightPerTapEnabled = true
        
        chart.xAxis.enabled = false
        
        let yAxis = chart.leftAxis
        yAxis.labelFont = yAxis.labelFont.withSize(12)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = .black
        yAxis.labelPosition = .insideChart
        yAxis.axisLineColor = .black
        
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        
        chart.layer.cornerRadius = 20
        chart.layer.masksToBounds = true
    }
    
    func getData() {
        let index = segmentedControl.selectedSegmentIndex
        async {
            var historicalData = await CoinGecko.shared.history(for: crypto!.coin.id!, daysAgo: daysAgo[index], interval: interval[index])
            
            let count = historicalData.count - 1
            switch index {
            case 0:
                historicalData = Array(historicalData[count-count/24...count])
            case 2:
                historicalData = Array(historicalData[count-count*7/30...count])
            case 3:
                historicalData = Array(historicalData[count-count*14/30...count])
            default:
                break
            }
            
            let set1 = LineChartDataSet(entries: historicalData, label: "DataSet 1")
            set1.mode = LineChartDataSet.Mode.cubicBezier
            set1.drawCirclesEnabled = false
            set1.lineWidth = 1.8
            set1.circleRadius = 4
            set1.setCircleColor(UIColor.black)
            set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
            set1.fillColor = UIColor.black
            set1.fillAlpha = 1
            set1.drawHorizontalHighlightIndicatorEnabled = false
            //set1.fillFormatter = CubicLineSampleFillFormatter()
            
            let data = LineChartData(dataSet: set1)
            data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9)!)
            data.setDrawValues(false)
            
            chart.data = data
            
            chart.animate(xAxisDuration: 1.25)
        }
    }
    
    func updatePriceLabels() {
        crypto = CryptoData.shared.cryptocurrencies[(crypto?.coin.symbol)!]
        DispatchQueue.main.async {
            self.setupLabels()
        }
    }
    
    func setupLabels() {
        cryptoName.text = crypto?.coin.name
        cryptoID.text = crypto?.coin.symbol?.uppercased()
        price.text = "$\((crypto?.coin.price?.string)!)"
        currency.text = "USD"
        let minimumFactor = round(1/crypto!.minimum)
        let priceChange24h = Double((crypto?.coin.priceChange24h!.string)!)! * Double(minimumFactor)
        let priceChangePercentage24h = Double((crypto?.coin.priceChangePercentage24h!.string)!)!
        priceChange.text = "$\(String(round(priceChange24h) / Double(minimumFactor)))"
        percentageChange.text = "(\(round(priceChangePercentage24h * 100) / 100.0)%)"
        
        if priceChangePercentage24h > 0 {
            priceChange.textColor = UIColor.systemGreen
            percentageChange.textColor = UIColor.systemGreen
            priceChange.text = "+\(priceChange.text!)"
            percentageChange.text = "\(percentageChange.text!)"
        } else if priceChangePercentage24h < 0 {
            priceChange.textColor = UIColor.systemRed
            percentageChange.textColor = UIColor.systemRed
        }
        
        let url = URL(string: (crypto?.coin.imageURL)!)
        imgView.image = UIImage(data: try! Data(contentsOf: url!))
    }
    
    @IBAction func segmentChanged(_ sender: Any) {
        getData()
    }
    
    
    //General Information and tableView
    
    
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var tbusd: UILabel!
    @IBOutlet weak var tbhold: UILabel!
    @IBOutlet weak var atihold: UILabel!
    @IBOutlet weak var atiusd: UILabel!
    @IBOutlet weak var avbuyusd: UILabel!
    @IBOutlet weak var profusd: UILabel!
    @IBOutlet weak var markcap: UILabel!
    @IBOutlet weak var volume: UILabel!
    @IBOutlet weak var ath: UILabel!
    
    @IBOutlet weak var tradeButton: UIButton!
    
    let buttonTable = ["Transaction history"]
    let imgTable = ["line.3.horizontal"]
    
    func doForGeneral() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        let minimum = crypto!.minimum
        let price = Double(crypto!.coin.price!)
        let usdHoldings = Double(crypto!.holdings)! * price
        let idHoldings = Double(crypto!.holdings)!
        let usdprofit = Double(crypto!.profit)!.roundToMinimum(minimum: minimum)
        let tickSize = crypto!.tickSize
        
        
        tbhold.text = "\(idHoldings) \(crypto!.coin.symbol!.uppercased())"
        tbusd.text = "$\(String(usdHoldings)) USD"
        
        atihold.text = "$0.00 USD"
        atiusd.text = "0 \(crypto!.coin.symbol!.uppercased())"
        avbuyusd.text = "$\(Double(crypto!.averageBuyPrice)!.roundToMinimum(minimum: minimum)) USD"
        profusd.text = "$\(String(usdprofit)) USD"
        
        markcap.text = "$\(crypto!.coin.marketCap!) USD"
        volume.text = "$\(crypto!.coin.totalVolume!) USD"
        ath.text = "$\(crypto!.coin.ath!) USD"
        
        tradeButton.layer.cornerRadius = 10
        tradeButton.backgroundColor = .label
        tradeButton.tintColor = .systemBackground
    }
    
    @IBAction func tradeButtonPressed(_ sender: Any) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "MakeOrder") as! MakeOrder
        
        vc.crypto = crypto
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        buttonTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = buttonTable[indexPath.row]
        content.image = UIImage(systemName: imgTable[indexPath.row])
        
        cell.accessoryType = .disclosureIndicator
        cell.contentConfiguration = content
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if buttonTable[indexPath.row] == "Transaction history" {
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "Trades") as! Trades
            
            vc.crypto = crypto
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}


extension Double {
    func roundToMinimum(minimum: Double) -> Double {
        let noDecMin = (1/minimum).rounded()
        let target = self * noDecMin
        return target.rounded() / noDecMin
    }
}
