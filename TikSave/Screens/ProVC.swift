//
//  ProVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit
import StoreKit
@available(iOS 15.0, *)
class ProVC: UIViewController {

    @IBOutlet weak var trialView: UIView!
    @IBOutlet weak var offerView: UIView!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var price1Btn: UIButton!
    @IBOutlet weak var price2Btn: UIButton!
    @IBOutlet weak var price3Btn: UIButton!
    @IBOutlet weak var stackV: UIButton!
    @IBOutlet weak var trialImgV: UIImageView!
    @IBOutlet weak var price1View: UIView!
    var otherPlanClicked = false
    @IBOutlet weak var featureSV: UIStackView!
    @IBOutlet weak var startFreeBtnPress: UIButton!

    var onEnd: () -> Void = {}
    var selectedType: SubscriptionType = .weekly
    var monthlySelected: SubscriptionType = .monthly
    var yearlySelected: SubscriptionType = .yearly
    
    override func viewDidLoad() {
        super.viewDidLoad()
        closeBtn.isHidden = true
        price1View.isHidden = true
        price2Btn.isHidden = true
        price3Btn.isHidden = true
        
        for v in featureSV.subviews{
            v.layer.borderColor = UIColor.red.cgColor
            v.layer.borderWidth = 1.0
        }
        purchaseView.backgroundColor = UIColor.clear
        
        startFreeBtnPress.layer.borderColor = UIColor(displayP3Red: 41.0/255.0, green: 240.0/255.0, blue: 242.0/255.0, alpha: 1.0).cgColor
        startFreeBtnPress.layer.borderWidth = 1.0
        startFreeBtnPress.layer.cornerRadius = 5.0

        setBorder(v: price1View)
        setBorder(v: price2Btn)
        setBorder(v: price3Btn)
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
       
        //no code
        
        
    }
    
    func setBorder(v:UIView){
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 1.0
        v.layer.cornerRadius = 5.0

    }
    
    @IBAction func otherPlanBtnPress(_ sender: UIButton) {
        price1View.isHidden = otherPlanClicked
        price2Btn.isHidden = otherPlanClicked
        price3Btn.isHidden = otherPlanClicked
        trialImgV.isHidden = !otherPlanClicked
        otherPlanClicked = !otherPlanClicked
    }
    
    func weeklySubs(){
        Task {
            try? await StoreKitManager.shared.loadProducts()
            
            StoreKitManager.shared.onFinish = {
                self.dismiss(animated: true)
                self.onEnd()
            }
            
            let products = StoreKitManager.shared.products
            if let prod = products.first(where: { $0.id == selectedType.identifier }) {
                try? await StoreKitManager.shared.purchase(prod)
            }
        }
    }
    
    @IBAction func startFree(_ sender: UIButton) {
        weeklySubs()
    }
    
    @IBAction func weekly(_ sender: UIButton) {
        weeklySubs()
    }
    @IBAction func montly(_ sender: UIButton) {
        Task {
            try? await StoreKitManager.shared.loadProducts()
            
            StoreKitManager.shared.onFinish = {
                self.dismiss(animated: true)
                self.onEnd()
            }
            
            let products = StoreKitManager.shared.products
            if let prod = products.first(where: { $0.id ==
                monthlySelected.identifier }) {
                try? await StoreKitManager.shared.purchase(prod)
            }
        }
    }
    
    @IBAction func yearly(_ sender: UIButton) {
        Task {
            try? await StoreKitManager.shared.loadProducts()
            
            StoreKitManager.shared.onFinish = {
                self.dismiss(animated: true)
                self.onEnd()
            }
            
            let products = StoreKitManager.shared.products
            if let prod = products.first(where: { $0.id == yearlySelected.identifier }) {
                try? await StoreKitManager.shared.purchase(prod)
            }
        }
    }
    
    
}
