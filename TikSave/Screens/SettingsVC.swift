//
//  SettingsVC.swift
//  TikSave
//
//  Created by krunal on 19/02/23.
//

import UIKit
import StoreKit
@available(iOS 15.0, *)
class SettingsVC: UIViewController {
    
    let settingArr = ["Subscribe to Pro Account","Restore Purchase","EULA","Privacy Policy","Review Us", "Contact Us"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    func reviewUs() {
        let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RateVC") as! RateVC
        present(rateVC, animated: true)
    }
    
    func privPolicy() {
        if let url = NSURL(string: "https://docs.google.com/document/d/1v6s9qBJjhZO74-GaPr2ajjK2Sxa9PNLLZ-7tVcO9QnY/edit"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    

    
    func eula() {
        if let url = NSURL(string: "https://docs.google.com/document/d/1YYBjZRZ74EBSHPeD12o4UCp9Ru8s6Bjn3zrgIANCAgc/edit"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    func contactUs() {
        if let url = NSURL(string: "https://docs.google.com/document/d/1hZnrNySlDgbgwlKEdpi7z9EBsHhU3m0b5lHXWtBDIdg/edit"){
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    func Subscribe(){
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
        }
    }
    
    
    func restorePurchase(){
        print("Restoring Purchases")
        StoreKitManager.shared.restorePurchase()
    }
    
    
}

@available(iOS 15.0, *)
extension SettingsVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1{
            return settingArr.count
        }
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCVC", for: indexPath) as! SettingCVC
            cell.lbl.text = settingArr[indexPath.row]
            cell.arrowImgV.isHidden = false
            
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AppCVC", for: indexPath) as! AppCVC
        cell.layer.borderWidth = 2.0
        cell.layer.cornerRadius = 8.0
        cell.layer.borderColor = indexPath.row == 0 ? UIColor(displayP3Red: 41/255.0, green: 240/255.0, blue: 242/255.0, alpha: 1.0).cgColor : UIColor.red.cgColor
        if indexPath.row == 0{
            cell.imgV.image = UIImage(named: "hashertag")
            cell.lbl.text = "Get unlimited hashtag\nto boost your instagram"
        }else{
            cell.imgV.image = UIImage(named: "reports_ins")
            cell.lbl.text = "Get your latest account\nstats anytime"
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SettingCVC", for: indexPath) as! SettingCVC
            
            switch(indexPath.row){
            case 0:
                Subscribe()
                break
            case 1:
                restorePurchase()
                break
            case 2:
                eula()
                break
            case 3:
                privPolicy()
                break
            case 4:
                reviewUs()
                break
            case 5:
                contactUs()
            default:
                print("Empty")
            }
        }
        else{
            return
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 1{
            return CGSize(width: collectionView.frame.width, height: 48)
        }
        return CGSize(width: collectionView.frame.width-40, height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingHeader", for: indexPath) as! SettingHeader
        if indexPath.section == 0{
            header.titleLbl.text = "MORE USEFUL APPS"
            header.titleLbl.textAlignment = .center
            header.subtitleLbl.text = "Get more apps to increase your audience \nand public, all from partner developers."
        }else{
            header.titleLbl.text = "SETTINGS"
            header.titleLbl.textAlignment = .left
            header.subtitleLbl.text = ""
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0{
            return CGSize(width: collectionView.frame.width, height: 85)
        }
        return CGSize(width: collectionView.frame.width, height: 45)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0{
            return UIEdgeInsets(top: 15, left: 20, bottom: 0, right: 20)
        }
        return UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
    }
}

class AppCVC:UICollectionViewCell{
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var lbl: UILabel!
}

@available(iOS 15.0, *)
class SettingCVC:UICollectionViewCell{
    @IBOutlet weak var lbl: UILabel!
    @IBOutlet weak var arrowImgV: UIImageView!
    
}


class SettingHeader:UICollectionReusableView{
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var subtitleLbl: UILabel!
}
