//
//  Portfolio.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit
import Charts
import Firebase

class Portfolio: UIViewController {
    
    var data:[Cryptocurrency]?
    
    var dataEntries:[String:[ChartDataEntry]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CryptoData.shared.update = updateData
        
        updateData()
        updateChartData()
        
        
    }
    
    func updateChartData() {
        async {
            for i in data! {
                let cryptoName = i.coin.symbol!.lowercased() + "usd"
                let historicalData = try await Database.database().reference().child(cryptoName).getData().value as! [String:String]
                
                var entries:[ChartDataEntry] = []
                for entry in historicalData.keys {
                    entries.append(ChartDataEntry(x: Double(entry)!, y: Double(historicalData[entry]!)!))
                }
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        CryptoData.shared.update = updateData
    }
    
    func updateUI() {
        
    }
    
    func updateData() {
        data = Array(CryptoData.shared.cryptocurrencies.values)
        data = data?.sorted(by: {$0.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count) < $1.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count)})
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
