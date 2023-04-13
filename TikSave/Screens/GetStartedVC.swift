//
//  GetStartedVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit

@available(iOS 15.0, *)
class GetStartedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func startBtnPress(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "Main")
        appDel.window?.rootViewController = vc!
    }
    

}
