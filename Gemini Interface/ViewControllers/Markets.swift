//
//  Markets.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit

class Markets: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    @IBOutlet weak var tableView: UITableView!
    var data:[Cryptocurrency]?
    
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CryptoData.shared.update = updateData
        
        updateData()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "buffer")
        tableView.layer.masksToBounds = false
        
        setupRefreshControl()
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView?.refreshControl = refreshControl
   }

    @objc func refreshData(_ refreshControl: UIRefreshControl) {
        DataGuzzler.shared.priceFeed()
    }
    
    func updateData() {
        data = Array(CryptoData.shared.cryptocurrencies.values)
        data = data?.sorted(by: {$0.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count) < $1.coin.marketCapRank ?? Double(CoinGecko.shared.allCoins.count)})
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl?.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
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
            //This is the buffer at the bottom of the tableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "buffer")
            //height cannot be 0 :(
            cell?.heightAnchor.constraint(equalToConstant: 1).isActive = true
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MarketsTableViewCell
        let indexedCell = data?[indexPath.section]
        cell.cryptoName.text = indexedCell?.coin.name
        cell.cryptoID.text = indexedCell?.coin.symbol?.uppercased()
        cell.price.text = "$\((indexedCell?.coin.price?.string)!)"
        cell.currency.text = "USD"
        let minimumFactor = round(1/Double(indexedCell!.minimum)!)
        let priceChange24h = Double((indexedCell?.coin.priceChange24h!.string)!)! * Double(minimumFactor)
        let priceChangePercentage24h = Double((indexedCell?.coin.priceChangePercentage24h!.string)!)!
        let priceChangeDisplay = round(priceChange24h) / Double(minimumFactor)
        cell.priceChange.text = "$\(String(round(priceChange24h) / Double(minimumFactor)))"
        cell.percentageChange.text = "(\(round(priceChangePercentage24h * 100) / 100.0)%)"
        
        if priceChangeDisplay > 0 {
            cell.priceChange.textColor = UIColor.systemGreen
            cell.percentageChange.textColor = UIColor.systemGreen
            cell.priceChange.text = "+\(cell.priceChange.text!)"
            cell.percentageChange.text = "\(cell.percentageChange.text!)"
        } else if priceChangeDisplay < 0 {
            cell.priceChange.textColor = UIColor.systemRed
            cell.percentageChange.textColor = UIColor.systemRed
        }
        
        let url = URL(string: (indexedCell?.coin.imageURL)!)
        cell.imgView.image = UIImage(data: try! Data(contentsOf: url!))
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
