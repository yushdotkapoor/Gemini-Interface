//
//  Markets.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit
import Firebase
import Charts

class Markets: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    var data:[Cryptocurrency]?
    
    var dataEntries:[String:[ChartDataEntry]] = [:]
    
    var isInitialized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CryptoData.shared.update = updateData
        
        updateData()
        updateChartData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "buffer")
        tableView.layer.masksToBounds = false
        
    }
    
    func updateChartData() {
        async {
            let allData = try await Database.database().reference().getData().value as! NSDictionary
            
            for i in data! {
                let cryptoName = i.coin.symbol!.lowercased() + "usd"
                let historicalData = allData[cryptoName] as! [String:String]
                
                var entries:[ChartDataEntry] = []
                for entry in historicalData.keys {
                    entries.append(ChartDataEntry(x: Double(entry)!, y: Double(historicalData[entry]!)!))
                }
                entries = entries.sorted(by: {$0.x < $1.x})
                
                dataEntries[cryptoName] = entries
            }
        }
    }
    
    @IBAction func toggleCharts(_ sender: Any) {
        let prevSetting = UserDefaults.standard.bool(forKey: "chartsEnabled")
        if prevSetting {
            UserDefaults.standard.setValue(false, forKey: "chartsEnabled")
        } else {
            UserDefaults.standard.setValue(true, forKey: "chartsEnabled")
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        CryptoData.shared.update = updateData
        if isInitialized {
            updateChartData()
        }
        isInitialized = true
    }
    
    func updateData() {
        data = Array(CryptoData.shared.cryptocurrencies.values)
        data = data?.sorted(by: {$0.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count) < $1.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count)})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (data?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = UIColor.clear
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if data?.count == indexPath.section {
            let cell = tableView.dequeueReusableCell(withIdentifier: "buffer")
            cell?.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MarketsTableViewCell
        let indexedCell = data?[indexPath.section]
        cell.cryptoName.text = indexedCell?.coin.name
        cell.cryptoID.text = indexedCell?.coin.symbol?.uppercased()
        cell.price.text = "$\((indexedCell?.coin.price?.string)!)"
        cell.currency.text = "USD"
        let minimumFactor = round(1/indexedCell!.minimum)
        let priceChange24h = Double((indexedCell?.coin.priceChange24h!.string)!)! * Double(minimumFactor)
        let priceChangePercentage24h = Double((indexedCell?.coin.priceChangePercentage24h!.string)!)!
        cell.priceChange.text = "$\(String(round(priceChange24h) / Double(minimumFactor)))"
        cell.percentageChange.text = "(\(round(priceChangePercentage24h * 100) / 100.0)%)"
        
        cell.chartData = dataEntries[(indexedCell?.coin.symbol!.lowercased())! + "usd"]
        
        if priceChangePercentage24h > 0 {
            cell.priceChange.textColor = UIColor.systemGreen
            cell.percentageChange.textColor = UIColor.systemGreen
            cell.priceChange.text = "+\(cell.priceChange.text!)"
            cell.percentageChange.text = "\(cell.percentageChange.text!)"
        } else if priceChangePercentage24h < 0 {
            cell.priceChange.textColor = UIColor.systemRed
            cell.percentageChange.textColor = UIColor.systemRed
        }
        
        let url = URL(string: (indexedCell?.coin.imageURL)!)
        cell.imgView.image = UIImage(data: try! Data(contentsOf: url!))
        
        let chartStatus = UserDefaults.standard.bool(forKey: "chartsEnabled")
        if chartStatus {
            cell.chart.isHidden = false
        } else {
            cell.chart.isHidden = true
        }
        cell.setCharts()
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "MarketsLandingPage") as! MarketsLandingPage

        let indexedCell = data?[indexPath.section]
        vc.crypto = indexedCell
        navigationController?.pushViewController(vc, animated: true)
        }
}


extension LosslessStringConvertible {
    var string: String { .init(self) }
}
