//
//  CreateCollectionVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit

class CreateCollectionVC: UIViewController {
    var delegate: CollectionDelegate?
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var nameTF: UITextField!
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var userDefaults = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        bgView.layer.cornerRadius = 12.0

        cancelBtn.layer.cornerRadius = 5.0
        createBtn.layer.cornerRadius = 5.0
        cancelBtn.layer.borderWidth = 1.0
        cancelBtn.layer.borderColor = UIColor.black.cgColor
    }
   
    @IBAction func createBtnPress(_ sender: UIButton) {
        if(nameTF.text != ""){
            let newCollection = CollectionModel(name: nameTF.text!, imageUrl: "", videoList: [])
            var collections: [String:Any] = userDefaults.object(forKey: "collections") as? [String:Any] ?? [:]
            
            do{
                let encoder = JSONEncoder()
                let data = try encoder.encode(newCollection)
                collections[newCollection.name] = data
                userDefaults.set(collections, forKey: "collections")
                nameTF.text = ""
                print("Collection added")
                
                //Getting collections
                var collectionsList: [String:Any] = userDefaults.object(forKey: "collections") as? [String:Any] ?? [:]
                for (_,value) in collectionsList {
                    var collectionData =  try JSONDecoder().decode(CollectionModel.self, from: value as! Data)
                    print(collectionData.name)
                }
                self.dismiss(animated: true)
                delegate?.fillCollections()
            }catch{
                print(error)
            }
        }
    }
    
    
    @IBAction func cancelBtnPress(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
}
