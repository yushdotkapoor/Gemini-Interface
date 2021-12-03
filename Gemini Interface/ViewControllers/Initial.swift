//
//  Initial.swift
//  Gemini Interface
//
//  Created by Yush Raj Kapoor on 12/1/21.
//

import Foundation
import UIKit
import LocalAuthentication


class Initial: UIViewController {
    
    @IBOutlet weak var enter: UIButton!
    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        enter.roundAndFill()
        async {
            await DataGuzzler.shared.oneTime()
        }
        authenticate()
        
    }
    
    @IBAction func enterTapped(_ sender: Any) {
        authenticate()
    }
    
    
    func authenticate() {
        context = LAContext()

        context.localizedCancelTitle = "Enter Password"

        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            let reason = "Log in to your account"
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason ) { success, error in

                if success {
                    DispatchQueue.main.async { [unowned self] in
                        self.performSegue(withIdentifier: "initialSegue", sender: self)
                    }
                } else {
                    print(error?.localizedDescription ?? "Failed to authenticate")
                }
            }
        } else {
            print(error?.localizedDescription ?? "Can't evaluate policy")
        }
    }
    
    
}
