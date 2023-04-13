//
//  DashboardVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer
import Photos
import Foundation
import SwiftUI

protocol CollectionDelegate{
    func fillCollections()
    func fillHistory()
}


@available(iOS 15.0, *)
class DashboardVC: UIViewController, UITextFieldDelegate, CollectionDelegate{
    var delegate: CollectionDelegate?
    
    @IBOutlet weak var addCollectionBtn: UIButton!
    @IBOutlet var bgView: UIView!
    @IBOutlet weak var collectionV: UICollectionView!
    var currentSection = 0
    @IBOutlet weak var searchTF: UITextField!
    var numberOfVideos = 0
    let userDefaults = UserDefaults.standard
    var usersData: UserModel!
    var history: [UserModel] = []
    var videoData: downModel!
    var videoDict: [downModel] = []
    var collectionList:[CollectionModel] = []
    var userNamesHistory: String!

    
    func getData(){
        fillCollections()
        fillHistory()
        collectionV.reloadData()
    }
    
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        
        
        delegate = self

        
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            // Redirect the user to the ProVC inside the Main storyboard
            let proVC = self.storyboard?.instantiateViewController(withIdentifier: "ProVC") as! ProVC
            present(proVC, animated: true)
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
     
        self.hideKeyboardWhenTappedAround()
        bgView.frame = collectionV.frame
        collectionV.backgroundView = bgView
        
        collectionV.register(UINib(nibName: "VideoCVC", bundle: nil), forCellWithReuseIdentifier: "VideoCVC")
        collectionV.register(UINib(nibName: "CollectionCVC", bundle: nil), forCellWithReuseIdentifier: "CollectionCVC")
        collectionV.register(UINib(nibName: "UserCVC", bundle: nil), forCellWithReuseIdentifier: "UserCVC")
        
        addCollectionBtn.isHidden = true
        searchTF.isHidden = true

        searchTF.layer.cornerRadius = 20
        
        let v = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 40))
        
        let imgV = UIImageView(frame: CGRect(x: 8, y: 10, width: 20, height: 20))
        imgV.image =  UIImage(named: "search")
        v.addSubview(imgV)
        
        searchTF.leftViewMode = .always
        searchTF.leftView = v
        
        NotificationCenter.default.addObserver(self, selector: #selector(checkClipboard), name: Notification.Name("foreground"), object: nil)

        self.checkClipboard()
        self.searchTF.delegate = self
        
    }
     
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        delegate?.fillHistory()
        fillVid()
        delegate?.fillCollections()
        
        
    }
    
    @objc func checkClipboard(){
        let urlModel: String = "https://vm.tiktok.com/"
       if let url = UIPasteboard.general.string{
           print("Url: \(url)")
           if url.contains(urlModel){
               videoMedia(text: url.trimmingAllSpaces())
               bgView.isHidden = true
            } else {
                bgView.isHidden = false
                return
            }
            numberOfVideos += 1
            self.collectionV.reloadData()
        }
    }
    
    func loadDownloads(videoInfo:String)->Bool{
        var recentDict: [String:Any] = userDefaults.object(forKey: "videoSaved") as? [String:Any] ?? [:]
        var exist = recentDict[videoInfo]
        if(exist == nil){
            return false
        }
        return true
    }
    
    
    func videoMedia(text: String){
        let loader = self.loader()
        let contentSearch = VideoVM()
        contentSearch.getSearch(query: text){
            data in
            if data != nil {
                DispatchQueue.main.async { [self] in
                    self.videoData = data!
                    print(data!)
                    self.userNamesHistory = videoData.userId
                    self.getUserInfo(userName: self.userNamesHistory)
                    videoData.downDate = getDate()
                    self.videoDict.append(self.videoData)
                    self.videosHistory(videoData: self.videoData)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "VideoDetailVC") as? VideoDetailVC
                    vc?.videoData = self.videoData
                    self.stopLoader(loader: loader)
                    self.navigationController?.pushViewController(vc!, animated: true)
                    print("Here goes the data")
                }
            } else {
                let alertVC = UIAlertController(title: "Oops!", message: "Something went wrong, please check if the link is a Tiktok valid one and try again!", preferredStyle: .actionSheet)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                  print("Handle Ok logic here")
                  }))
                self.present(alertVC, animated: true)
                return
            }
        }
    }
    
    
    func videosHistory(videoData: downModel){
        var videosData : [String:Any] = self.userDefaults.object(forKey: "videoSaved") as? [String:Any] ?? [:]
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(videoData)
            videosData[videoData.videoId] = data
            userDefaults.set(videosData, forKey: "videoSaved")
            print("Video added")
            print(videosData.keys.count)
        }catch{
            print(error)
        }
    }
    
    func getDate() -> String{
        var date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"
        let activeDate = dateFormatter.string(from: date)
        return activeDate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchUser()
        return true
    }
    
    func searchUser(){
        guard let searchText = self.searchTF.text, !searchText.isEmpty else {
               print("Empty text")
               return
           }
        let loader = self.loader()
            switch searchText {
               case let text where text.contains("https://vm.tiktok.com/"):
                  let loader = self.loader()
                   self.videoMedia(text: searchText)
                stopLoader(loader: loader)
               default:
                  let loader = self.loader()
                   getUserInfo(userName: searchText.lowercased())
                    stopLoader(loader: loader)
               }
        stopLoader(loader: loader)
        
    }
    
    func history(userData: UserModel){
        var historyData : [String:Any] = self.userDefaults.object(forKey: "history") as? [String:Any] ?? [:]
        do{
            let encoder = JSONEncoder()
            let data = try encoder.encode(userData)
            historyData[userData.nickname] = data
            userDefaults.set(historyData, forKey: "history")
            print("history search added")
            print(historyData.keys.count)
        }catch{
            print(error)
        }
    }
    
    
    func getUserInfo(userName:String){
        let loader = self.loader()
        var userVM = UsersVM()
        userVM.getUserId(userName: userName){
            id in
            DispatchQueue.main.async {
                if(id != nil){
                    userVM.getUserData(userId: id){
                        data in
                        DispatchQueue.main.async {
                            self.usersData = data
                            self.history.append(data)
                            self.history(userData: data)
                            self.collectionV.reloadData()
                            self.stopLoader(loader: loader)
                        }
                    }
                }else {
                    let alert = UIAlertController(title: "Oops! Something went wrong", message: "Please try again.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { (action: UIAlertAction!) in
                      print("Handle Ok logic here")
                      }))
                    self.present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
        
}
    func fillVid(){
        videoDict = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM dd,yyyy, hh:mm a"

        var savedDict: [String:Any] = userDefaults.object(forKey: "videoSaved") as? [String: Any] ?? [:]
        print(savedDict.keys.count)

        var newDict = [String: Any]()
        for (key, value) in savedDict {
            if let data = value as? Data, let decodedVideo = try? JSONDecoder().decode(downModel.self, from: data) {
                var expDate = Date()
                if let date = dateFormatter.date(from: decodedVideo.downDate) {
                    expDate = date.dateByAddingDays(days: 3)
                }
                let lastDay = dateFormatter.string(from: expDate)
                if decodedVideo.downDate != lastDay {
                    newDict[key] = value
                    videoDict.append(decodedVideo)
                    collectionV.reloadData()
                }
                
            } else {
                newDict[key] = value
            }
        }
        savedDict = newDict

        userDefaults.set(savedDict, forKey: "videoSaved")
        print("Recent viewed loaded")
        if videoDict.isEmpty{
            bgView.isHidden = false
        } else{
            bgView.isHidden = true
            collectionV.reloadData()
        }
    }


    
    func fillCollections(){
        let collections: [String:Any] = self.userDefaults.object(forKey: "collections") as? [String:Any] ?? [:]
        collectionList = []
        for (_,value) in collections {
            do {
                
                var collection = try JSONDecoder().decode(CollectionModel.self, from: value as! Data)
                var alreadyExists = false
                for existingCollection in collectionList {
                    if existingCollection.name == collection.name{
                        alreadyExists = true
                        break
                    }
                }
                if !alreadyExists {
                collectionList.append(collection)
                            }
            }catch{
                print(error)
            }
        }
        collectionV.reloadData()
    }
    
    func fillHistory(){
        history = []
        let userhistory: [String:Any] = userDefaults.object(forKey: "history") as? [String:Any] ?? [:]
        for (_, value) in userhistory{
            do{
                let unData = try JSONDecoder().decode(UserModel.self, from: value as! Data)
                if history.contains(where: {  $0 == unData }) {
                       print("already exists")
                   } else {
                       history.append(unData)
                   }
                
            }catch{
                print(error)
            }
        }
        print("History loaded")
        collectionV.reloadData()
    }

            
       
  
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        currentSection = sender.selectedSegmentIndex
        collectionV.reloadData()
        addCollectionBtn.isHidden = !(currentSection == 1)
        searchTF.isHidden = !(currentSection == 2)
    }
    
    @IBAction func addCollectionBtnPress(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateCollectionVC") as! CreateCollectionVC
        vc.delegate = self
        present(vc, animated: true)
    }
    
    
    
    
    
}

@available(iOS 15.0, *)

extension DashboardVC:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentSection == 0{
            if videoDict.count > 0{
              return videoDict.count
            } else {
                return 0
            }

        }
        if currentSection == 2{
            if history.count > 0{
              return history.count
            } else {
                return 0
            }
        }
        
        if collectionList.count > 0 {
            return collectionList.count
        } else {
            return 0
        }
//        collectionV.backgroundView = nil
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentSection == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCVC", for: indexPath) as! VideoCVC
            cell.imgV.load(urlString: videoDict[indexPath.row].videoCover)
            cell.countLbl.text = "\(videoDict[indexPath.row].playCount.roundedWithAbbreviations)"
            cell.videoData = videoDict[indexPath.row]
            return cell
        }
        
        if currentSection == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCVC", for: indexPath) as! CollectionCVC
                cell.titleLbl.text = collectionList[indexPath.row].name
                if(!collectionList[indexPath.row].videoList.isEmpty){
                    cell.descLbl.text = "\(collectionList[indexPath.row].videoList.count) Videos"
                    cell.imgV.load(urlString: collectionList[indexPath.row].videoList[0].videoCover)
                } else{
                    cell.descLbl.text = "0 Videos"
                    cell.imgV.image = UIImage(named: "collection_temp_bg.png")
                }
            return cell
          
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCVC", for: indexPath) as! UserCVC
        cell.imgV.load(urlString: history[indexPath.row].profilePicUrl)
        cell.imgV.setRounded()
        cell.titleLbl.text = "@\(history[indexPath.row].nickname)"
        cell.userData = history[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if currentSection == 0{
            return CGSize(width: (collectionView.frame.size.width - 42)/2, height: ((collectionView.frame.size.width - 42)/2)*1.6)
        }
        return CGSize(width: collectionView.frame.size.width - 32, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if currentSection == 0{
            let vc = storyboard?.instantiateViewController(withIdentifier: "VideoDetailVC") as? VideoDetailVC
            vc?.videoData = videoDict[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        if currentSection == 1{
            let vc = storyboard?.instantiateViewController(withIdentifier: "CollectionVC") as? CollectionVC
            vc?.collectionName = "\(collectionList[indexPath.row].name)"
            self.navigationController?.pushViewController(vc!, animated: true)
            print(collectionList[indexPath.row].name)
            
        }
        if currentSection == 2{
            if let url =  NSURL(string: "https://www.tiktok.com/@\(self.history[indexPath.row].nickname)"){
                UIApplication.shared.openURL(url as URL)
                print(url)
        }
        }
     
    }
}

