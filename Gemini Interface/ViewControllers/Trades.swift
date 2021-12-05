//
//  Trades.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/3/21.
//

import Foundation
import UIKit

class Trades: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var crypto: Cryptocurrency?
    var transactions:[TradesObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Trades for \(crypto!.coin.name!)"
        tableView.delegate = self
        tableView.dataSource = self
        async {
            await fetchData()
        }
       
        
    }
    
    func fetchData() async {
        let trades = await Orders.shared.GetTradesForCrypto().rawValue as! [[String:Any]]
        for trade in trades {
            let price = trade["price"] as! String
            let fee = trade["fee_amount"] as! String
            let amount = trade["amount"] as! String
            let type = trade["type"] as! String
            let symbol = trade["symbol"] as! String
            let timestamp = trade["timestamp"] as! Double
            let transactionDate = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(abbreviation: "EST")
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
            let formattedDate = dateFormatter.string(from: transactionDate)
            if (crypto!.coin.symbol!.lowercased() + "usd") == symbol.lowercased() {
                transactions.append(TradesObject(type: type, pricePerUnit: "$\(price)", totalCost: String(Double(amount)! * Double(price)!), coins: "\(amount) \(crypto!.coin.symbol!.uppercased())", fee: "$-\(fee)", transactionDate: formattedDate))
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath) as! TradesTableViewCell
        let trade = transactions[indexPath.row]
        cell.type.text = trade.type
        cell.pricePerUnit.text = trade.pricePerUnit
        
        cell.coins.text = trade.coins
        cell.fee.text = trade.fee
        
        cell.transactionDate.text = trade.transactionDate
        
        if trade.type == "Sell" {
            cell.totalCost.text = "$+\(trade.totalCost)"
            cell.backgroundColor = UIColor(red: 200, green: 0, blue: 0, alpha: 0.2)
        } else if trade.type == "Buy" {
            cell.totalCost.text = "$-\(trade.totalCost)"
            cell.backgroundColor = UIColor(red: 0, green: 200, blue: 0, alpha: 0.2)
        }
        
        return cell
    }
    
    
}

class TradesObject {
    var type:String
    var pricePerUnit:String
    var totalCost:String
    var coins:String
    var fee: String
    var transactionDate:String
    
    init(type:String, pricePerUnit:String, totalCost:String, coins:String, fee: String, transactionDate:String) {
        self.type = type
        self.pricePerUnit = pricePerUnit
        self.totalCost = totalCost
        self.coins = coins
        self.fee = fee
        self.transactionDate = transactionDate
    }

}
