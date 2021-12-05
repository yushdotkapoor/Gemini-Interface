//
//  MakeOrder.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/4/21.
//

import Foundation
import UIKit

class MakeOrder: UIViewController {
    
    var crypto:Cryptocurrency?
    
    @IBOutlet weak var cryptoName: UILabel!
    @IBOutlet weak var cryptoID: UILabel!
    @IBOutlet weak var cryptoImage: UIImageView!
    @IBOutlet weak var usdHoldings: UILabel!
    @IBOutlet weak var coinHoldings: UILabel!
    @IBOutlet weak var buyOrSell: UISegmentedControl!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var approximation: UILabel!
    @IBOutlet weak var cost: UILabel!
    @IBOutlet weak var respectTag: UILabel!
    @IBOutlet weak var dollar: UILabel!
    @IBOutlet weak var sellAll: UIButton!
    @IBOutlet weak var typeBold: UILabel!
    
    var costApproximation: Double? {
        didSet {
            var tag = crypto!.coin.symbol!.uppercased()
            var prefix = ""
            if !isUSD {
                tag = "USD"
                prefix = "$"
            }
            DispatchQueue.main.async {
                self.approximation.text = "approx. \(prefix)\(self.costApproximation!) \(tag)"
            }
        }
    }
    
    var isUSD = true
    
    var respect:Int = 0 {
        didSet {
            if respect % 2 == 0 {
                //USD
                respectTag.text = "USD"
                isUSD = true
                dollar.alpha = 1
                //dollar.isHidden = false
            } else {
                //COIN
                respectTag.text = crypto!.coin.symbol!.uppercased()
                isUSD = false
                dollar.alpha = 0
                //dollar.isHidden = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CryptoData.shared.update = updateData
        cryptoName.text = crypto?.coin.name!
        cryptoID.text = crypto?.coin.symbol?.uppercased()
        let url = URL(string: (crypto?.coin.imageURL)!)
        cryptoImage.image = UIImage(data: try! Data(contentsOf: url!))
        
        costApproximation = 0.0
        
        orderButton.layer.cornerRadius = 10
        orderButton.backgroundColor = .label
        orderButton.tintColor = .systemBackground
        sellAll.layer.cornerRadius = sellAll.frame.height/2
        sellAll.backgroundColor = .label
        sellAll.tintColor = .systemBackground
        
        typeChanged(self)
        
    }
    
    func updateData() {
        crypto = CryptoData.shared.cryptocurrencies[crypto!.coin.symbol!]
        async {
            var dictionary:[String: Any] = [:]
            let balances = await Account.shared.CheckAvailableBalances().rawValue as! [[String:Any]]
            for balance in balances {
                if (balance["currency"] as! String).lowercased() == crypto!.coin.symbol!.lowercased() {
                    dictionary = balance
                }
            }
            let holdings = dictionary["amount"] as? String ?? "0"
            
            
            usdHoldings.text = "$\((Double(holdings)! * Double(crypto!.coin.price!)).roundToMinimum(minimum: crypto!.tickSize)) USD"
            coinHoldings.text = "\(holdings) \(crypto!.coin.symbol!.uppercased())"
            crypto?.holdings = holdings
        }
        updateApproximation()
    }
    
    @IBAction func orderTapped(_ sender: Any) {
        if Double(cost.text ?? "") == 0 {
            return
        }
        let type:Side?
        if buyOrSell.selectedSegmentIndex == 0 {
            type = .buy
        } else {
            type = .sell
        }
        
        var cuesta = (Double(cost.text!)! * 1.0035).roundToMinimum(minimum: 0.00001)
        var approx = costApproximation!
        if !isUSD {
            cuesta = costApproximation! * 1.0035
            approx = (Double(cost.text!)!).roundToMinimum(minimum: crypto!.minimum)
        }
        
        let alertController = UIAlertController(title: "Please Confirm \(type!.rawValue)", message: "Would you like to \(type!.rawValue.uppercased()) approximately \(approx) \(crypto!.coin.name!) for $\(cuesta) USD?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default, handler: {_ in
            async {
                await self.placeOrder(type: type!)
            }
        })
        let no = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(yes)
        alertController.addAction(no)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func placeOrder(type: Side) async {
        var approx = costApproximation!
        if !isUSD {
            approx = (Double(cost.text!)!).roundToMinimum(minimum: crypto!.minimum)
        }
        
        let order = await Orders.shared.Order(ticker: "\(crypto!.coin.symbol!.uppercased())USD", quantity: String(approx), side: type, options: ["fill-or-kill"])
        let result = order.rawValue as? [String:Any]
        if ((result?.keys.contains("is_cancelled"))! && (result?["is_cancelled"] as! Bool) == true) {
            print("Failed to order \(crypto!.coin.name!)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                async {
                    await self.placeOrder(type: type)
                }
            })
        } else if ((result?.keys.contains("result"))! && (result?["result"] as! String) == "error") {
            print("Failed to order \(crypto!.coin.name!)")
            
            let alertController = UIAlertController(title: "Failed to order \(crypto!.coin.name!)", message: result!["message"] as? String, preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Dimiss", style: .default, handler: nil)
            alertController.addAction(action)
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
            
        } else {
            DispatchQueue.main.async { [self] in
                print("Order placed successfully!")
                cost.text = "0"
                updateApproximation()
                
                let alertController = UIAlertController(title: "Success!", message: "Order for \(crypto!.coin.name!) completed successfully!", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Dimiss", style: .default, handler: nil)
                alertController.addAction(action)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
        print(result)
        
    }
    
    @IBAction func typeChanged(_ sender: Any) {
        if buyOrSell.selectedSegmentIndex == 0 {
            sellAll.isHidden = true
            typeBold.text = "BUY"
            typeBold.textColor = .systemGreen
        } else if buyOrSell.selectedSegmentIndex == 1 {
            sellAll.isHidden = false
            if isUSD {
                sellAll.isHidden = true
            }
            typeBold.text = "SELL"
            typeBold.textColor = .systemRed
        }
    }
    
    @IBAction func sellAllTapped(_ sender: Any) {
        cost.text = crypto?.holdings
    }
    
    
    @IBAction func deleteAll(_ sender: Any) {
        cost.text = "0"
        updateApproximation()
    }
    
    
    @IBAction func swap(_ sender: Any) {
        respect += 1
        cost.text = String(costApproximation!.roundToMinimum(minimum: 0.01))
        if Double(cost.text!) == 0 {
            cost.text = "0"
        }
        typeChanged(self)
        updateApproximation()
    }
    
    
    func updateApproximation() {
        DispatchQueue.main.async { [self] in
            if isUSD {
                costApproximation = (Double(cost.text!)! / Double(crypto!.coin.price!)).roundToMinimum(minimum: crypto!.tickSize)
            } else {
                costApproximation = (Double(cost.text!)! * Double(crypto!.coin.price!)).roundToMinimum(minimum: crypto!.minimum)
            }
        }
    }
    
    func removeZero() {
        if cost.text! == "0" {
            cost.text = ""
        }
    }
    
    @IBAction func zero(_ sender: Any) {
        if cost.text! != "0" {
            cost.text = cost.text! + "0"
            updateApproximation()
        }
    }
    @IBAction func one(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "1"
        updateApproximation()
    }
    @IBAction func two(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "2"
        updateApproximation()
    }
    @IBAction func three(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "3"
        updateApproximation()
    }
    @IBAction func four(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "4"
        updateApproximation()
    }
    @IBAction func five(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "5"
        updateApproximation()
    }
    @IBAction func six(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "6"
        updateApproximation()
    }
    @IBAction func seven(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "7"
        updateApproximation()
    }
    @IBAction func eight(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "8"
        updateApproximation()
    }
    @IBAction func nine(_ sender: Any) {
        removeZero()
        cost.text = cost.text! + "9"
        updateApproximation()
    }
    @IBAction func point(_ sender: Any) {
        if !cost.text!.contains(".") {
            cost.text = cost.text! + "."
        }
    }
    @IBAction func back(_ sender: Any) {
        if cost.text != "0" {
            cost.text?.removeLast()
            if cost.text == "" {
                cost.text = "0"
            }
            updateApproximation()
        }
    }
    
    
}
