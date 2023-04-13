//
//  CollectionVC.swift
//  TikSave
//
//  Created by Christina Santana on 20/3/23.
//

import Foundation
import UIKit

class CollectionVC: UIViewController{
    
    @IBOutlet weak var collectionV: UICollectionView!
    @IBOutlet weak var collectionNamelbl: UILabel!
  
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    var userDefaults = UserDefaults.standard
    
    var videoList: [downModel] = []
    var collectionName: String!
    var collectionData: [CollectionModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        fillVideos()
        if (collectionName != nil){
            collectionNamelbl.text = collectionName
        } else {
            return
        }
     
    }
    
    func setup(){
        collectionV.register(UINib(nibName: "ColVideoCVC", bundle: nil), forCellWithReuseIdentifier: "ColVideoCVC")
        collectionV.dataSource = self
        collectionV.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    @IBAction func bac(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    

    
    func fillVideos() {
        videoList = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"

        var savedCollections = userDefaults.object(forKey: "collections") as? [String: Any] ?? [:]
        var collection = savedCollections[collectionName]
        var updatedCollection = [String: Any]()
        let decoder = JSONDecoder()

        do {
            var collectionData = try decoder.decode(CollectionModel.self, from: collection as! Data)
            var expDate = Date()
            if let videoData = collectionData.videoList.first {
                if let date = dateFormatter.date(from: videoData.downDate) {
                    expDate = date.dateByAddingDays(days: 3)
                }
            }
            let lastDay = dateFormatter.string(from: expDate)
            let filteredVideos = collectionData.videoList.filter({ $0.downDate != lastDay })
            if filteredVideos.count > 0 {
                updatedCollection[collectionName] = filteredVideos
                videoList = filteredVideos
                collectionV.reloadData()
            } else {
                videoList = collectionData.videoList
            }
            print(videoList.count)
        } catch {
            print(error)
        }
        print("History loaded")
        collectionV.reloadData()
    }



}

    
    


extension CollectionVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if videoList.count > 0 {
            return videoList.count
        } else {
            return 0
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColVideoCVC", for: indexPath) as! ColVideoCVC
        cell.videoCoverImg.load(urlString: videoList[indexPath.row].videoCover)
        cell.profilePicImg.load(urlString: videoList[indexPath.row].profilePic)
        cell.profilePicImg.setRounded()
        cell.userNameLbl.text = videoList[indexPath.row].userId
        cell.playedLbl.text = "\(videoList[indexPath.row].playCount.roundedWithAbbreviations)"
        cell.commentsLbl.text = "\(videoList[indexPath.row].commentCount.roundedWithAbbreviations)"
        cell.likesLbl.text = "\(videoList[indexPath.row].likesCount.roundedWithAbbreviations)"
        cell.sharedLbl.text = "\(videoList[indexPath.row].shareCount.roundedWithAbbreviations)"
        cell.videoData = videoList[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //pan
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width - 60), height: ((collectionView.frame.size.width - 130)/2)*1.6)
        
    }
}
