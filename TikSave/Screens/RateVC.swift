//
//  RateVC.swift
//  TikSave
//
//  Created by Christina Santana on 13/4/23.
//

import Foundation
import UIKit

class RateVC: UIViewController{
    @IBOutlet weak var rateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rateButton.setTitle("", for: .normal)
    }
    
    @IBAction func rateBtn(_ sender: UIButton) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") {
            if #available(iOS 15.0, *) {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
