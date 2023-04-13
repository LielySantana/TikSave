//
//  AddToCollectionVC.swift
//  TikSave
//
//  Created by Christina Santana on 23/3/23.
//

import Foundation
import UIKit

class AddToCollectionVC: UIViewController, CollectionDelegate{
    func fillHistory() {
        //none
    }
    
    @IBOutlet weak var collectionV: UICollectionView!
    
    @IBOutlet weak var newBtn: UIButton!
    var userDefaults = UserDefaults.standard
    var collectionList: [CollectionModel] = []
    var videoData: downModel!
    var delegate: CollectionDelegate?
    
    
    func setup(){
        fillCollections()
        collectionV.delegate = self
        collectionV.dataSource = self
        collectionV.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        delegate = self
        
        newBtn.setTitle("", for: .normal)
        print(collectionList.count, videoData)
    }
    
   

    
    @IBAction func createBtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateCollectionVC") as! CreateCollectionVC
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func fillCollections(){
        let collections: [String:Any] = self.userDefaults.object(forKey: "collections") as? [String:Any] ?? [:]
        collectionList = []
        for (_,value) in collections {
            do {
                
                var collection = try JSONDecoder().decode(CollectionModel.self, from: value as! Data)
                collectionList.append(collection)
            }catch{
                print(error)
            }
        }
        collectionV.reloadData()
    }
    

}

extension AddToCollectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if collectionList.count > 0{
                return collectionList.count
            }
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionListCell", for: indexPath) as! CollectionListCell
            if(!collectionList[indexPath.row].videoList.isEmpty){
                collectionList[indexPath.row].imageUrl = collectionList[indexPath.row].videoList[0].videoCover
                cell.imgV.load(urlString: collectionList[indexPath.row].imageUrl)
            }
            cell.cellNameLbl.text = collectionList[indexPath.row].name
                
            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            let encoder = JSONEncoder()
            let decoder = JSONDecoder()
            var selectedCol = collectionList[indexPath.row]
            selectedCol.videoList.append(videoData)
            do {
                var renewCol = userDefaults.object(forKey: "collections") as? [String: Data] ?? [:]
                if let encodedSelectedCol = try? encoder.encode(selectedCol) {
                    if let colData = renewCol[selectedCol.name], let decodedCol = try? decoder.decode(CollectionModel.self, from: colData) {
                        if decodedCol.videoList.contains(where: { $0 == videoData }) {
                            
                            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "CollectionVC") as? CollectionVC else {return}
                            vc.collectionName = collectionList[indexPath.row].name
                            self.navigationController?.pushViewController(vc, animated: true)
                            return
                        }
                    }
                    renewCol[selectedCol.name] = encodedSelectedCol
                    userDefaults.set(renewCol, forKey: "collections")
                    
                     let vc = self.storyboard?.instantiateViewController(withIdentifier: "CollectionVC") as? CollectionVC
                    vc!.collectionName = "\(collectionList[indexPath.row].name)"
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            } catch {
                print(error)
            }
            
            
            
        }
        

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 5
        let cellWidth = collectionView.frame.size.width - 250
        let cellHeight = cellWidth + 40 + padding * 2 // Add padding to top and bottom
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    
}

class CollectionListCell: UICollectionViewCell{
    @IBOutlet weak var cellNameLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var cellView: UIView!
    override func awakeFromNib() {
        self.layer.cornerRadius = 12.0
        self.imgV.layer.cornerRadius = 12.0
        self.cellView.layer.cornerRadius = 12.0
    }
}


