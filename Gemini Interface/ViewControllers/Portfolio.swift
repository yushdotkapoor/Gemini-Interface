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
import OrderedCollections

class Portfolio: UIViewController, ChartViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var currencyBalances:OrderedDictionary<String, portfolioInfo> = [:]
    var usdTotal = "0.0"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CryptoData.shared.update = updateData
        
        updateData()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        tabBarController?.tabBar.isHidden = false
        CryptoData.shared.update = updateData
    }
    
    func updateData() {
        usdTotal = "0.0"
        async {
            let availableBalances = await Account.shared.CheckNotionalBalances().rawValue as! [[String:String]]
            
            for i in availableBalances {
                let curr = i["currency"]!
                let notionalAmount = i["amountNotional"]!
                let amount = i["amount"]!
                usdTotal = String(Double(usdTotal)! + Double(notionalAmount)!)
                
                
                let coin = CryptoData.shared.cryptocurrencies[curr.lowercased()]?.coin ?? Coin(name: "U.S. Dollar", imageURL: "https://pic.onlinewebfonts.com/svg/img_452062.png")
                
                let structure = portfolioInfo(coin: coin, notionalAmount: notionalAmount, amount: amount)
                
                if curr == "USD" {
                    let roundedAmount = String(Double(structure.notionalAmount)!.roundToMinimum(minimum:0.0001))
                    structure.notionalAmount = roundedAmount
                    structure.amount = roundedAmount
                }
                
                currencyBalances[curr] = structure
                
            }
            
            usdTotal = String(Double(usdTotal)!.roundToMinimum(minimum:0.0001))
            
            
            let balanciagas = currencyBalances.sorted(by: {Double($0.value.notionalAmount)! > Double($1.value.notionalAmount)!})
            currencyBalances = [:]
            for i in balanciagas {
                currencyBalances[i.key] = i.value
            }
            
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyBalances.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "value") as! ValueTableViewCell
            cell.currency.text = "USD"
            cell.total.text = "$\(usdTotal)"
            
            return cell
        }
        else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "chart") as! ChartTableViewCell
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PortfolioTableViewCell
            let key = Array(currencyBalances.keys)[indexPath.row - 2]
            cell.currency.text = "USD"
            cell.holdingsID.text = key
            cell.ID.text = key
            cell.name.text = currencyBalances[key]!.coin.name
            cell.price.text = "$\(currencyBalances[key]!.notionalAmount)"
            cell.holdings.text = currencyBalances[key]!.amount
            
            let url = URL(string: (currencyBalances[key]!.coin.imageURL!))
            cell.imgView.image = UIImage(data: try! Data(contentsOf: url!))
            
            
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row >= 2 {
            let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(identifier: "MarketsLandingPage") as! MarketsLandingPage
            
            let indexedCell = CryptoData.shared.cryptocurrencies[Array(currencyBalances.keys)[indexPath.row - 2].lowercased()]
            vc.crypto = indexedCell
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


class portfolioInfo {
    var coin: Coin
    var notionalAmount: String
    var amount: String
    
    init(coin: Coin, notionalAmount: String, amount: String) {
        self.coin = coin
        self.notionalAmount = notionalAmount
        self.amount = amount
    }
}
