//
//  VideoDetailVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit
import AVFoundation
import Foundation
import SwiftUI


@available(iOS 15.0, *)
class VideoDetailVC: UIViewController{
    var delegate: CollectionDelegate?
  
    @IBOutlet weak var repostBtn: UIButton!
    @IBOutlet weak var calendarBtn: UIButton!
    @IBOutlet weak var lineV: UIView!
    @IBOutlet weak var videoCover: UIImageView!
    @IBOutlet weak var bottomV: UIView!
    @IBOutlet weak var tableV: UITableView!
    var vidId: String!
    var player: AVPlayer!
    var link: String!
    var cover: String!
    var played: Bool!
    var hashtags: [String] = []
    var videoData: downModel!
    var userDefaults = UserDefaults.standard
    var collectionList: [CollectionModel] = []

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarBtn.setTitle("", for: .normal)
        repostBtn.setTitle("", for: .normal)
        self.hideKeyboardWhenTappedAround()
        
        setBorder(sender: repostBtn)
        setBorder(sender: calendarBtn)
        
     
        videoCover.load(urlString: self.videoData.videoCover)
        videoCover.alpha = 0.7
         hashtags = self.videoData.hashtag.map { "#\($0)" }
        print(hashtags)

        tableV.dataSource = self
        tableV.delegate = self
        

        
        self.navigationController?.navigationBar.isHidden = false
        
        bottomV.clipsToBounds = true
        bottomV.layer.cornerRadius = 10
        bottomV.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    
        
        print(collectionList.count, videoData)
        
        
    }
    
    
    
    func setBorder(sender:UIButton){
        sender.layer.borderColor = UIColor(displayP3Red: 41.0/255.0, green: 240.0/255.0, blue: 242.0/255.0, alpha: 1.0).cgColor
        sender.layer.borderWidth = 1.0
        sender.layer.cornerRadius = 5.0
    }
    
    @IBAction func calendarBtnPress(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddPostVC") as? AddPostVC else {return}
        vc.imageFromVideo = videoData.videoCover
        self.navigationController?.pushViewController(vc, animated: true)
        print(videoData.videoCover)
        
    }
    
 
    func repost() {
        let loader = self.loader()
        
        // Use URLSession for asynchronous downloading instead of NSData(contentsOf:)
        URLSession.shared.dataTask(with: URL(string: videoData.videoUrlNoWaterMarked)!) { data, response, error in
            guard let urlData = data else {
                print("No video found")
                return
            }
            
            //Share case for videos
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docDirectory = paths[0]
            let filePath = docDirectory.appendingPathComponent("tmpVideo.mov")
            do {
                try urlData.write(to: filePath)
                // File Saved
                let videoLink = NSURL(fileURLWithPath: filePath.path)
                let objectToShare = [videoLink] // comment!, imageData!, myWebsite!]
                let activitysVC = UIActivityViewController(activityItems: objectToShare, applicationActivities: nil)
                activitysVC.setValue("Video", forKey: "subject")
                self.stopLoader(loader: loader)
                DispatchQueue.main.async {
                    self.present(activitysVC, animated: true, completion: nil)
                }
            } catch let error {
                print("Error saving video file: \(error.localizedDescription)")
                self.stopLoader(loader: loader)

            }
        }.resume()
        
            }


    func play(url:NSURL) {
           do {
               let playerItem = AVPlayerItem(url: url as URL)
               player = try AVPlayer(playerItem: playerItem)
//               player!.prepareToPlay()
               player!.volume = 2.0
               player!.play()
           } catch let error as NSError {
               print(error.localizedDescription)
           } catch {
               self.player = nil
               print("AVAudioPlayer init failed")
           }
           
       }
    
    @IBAction func repostVideo(_ sender: UIButton) {
        if(!SharedService.shared.isPremium){
            guard let pro = self.storyboard?.instantiateViewController(withIdentifier: "ProVC") as? ProVC else {return}
            present(pro, animated: true)
        } else{
            if !UserDefaults.standard.bool(forKey: "hasRepostBefore") {
                // Redirect the user to the ProVC inside the Main storyboard
                UserDefaults.standard.set(true, forKey: "hasRepostBefore")
                let rateVC = self.storyboard?.instantiateViewController(withIdentifier: "RateVC") as! RateVC
                self.present(rateVC, animated: true)
            }
            repost()
        }
    }
    

    
}

@available(iOS 15.0, *)
extension VideoDetailVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableVCell", for: indexPath) as! TableVCell
        switch(indexPath.row){
        case 0:
            let newImage = UIImage(named: "play_fill")
            cell.optionslbl.text = videoData.musicAuthor
            cell.imgV.image = newImage
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
            break
        case 1:
            let newImage = UIImage(named: "bookmark_fill")
            cell.optionslbl.text = "Add to collection"
            cell.imgV.image = newImage
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
            break
        case 2:
            let newImage = UIImage(named: "play_fill")
            cell.optionslbl.text = "Go to video"
            cell.imgV.image = newImage
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true
            break
        case 3:
            if !hashtags.isEmpty{
                cell.optionslbl.text = hashtags.joined(separator: "")
                cell.optionslbl.numberOfLines = 0
                cell.optionslbl.lineBreakMode = .byWordWrapping
                if let image = UIImage(named: "copy_btn")?.withRenderingMode(.alwaysOriginal).resize(to: CGSize(width: 18, height: 18)) {
                    cell.imgV.image = image
                }
            } else {
                cell.optionslbl.text = "#TikSaver"
            }
            cell.layer.borderWidth = 4
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.cornerRadius = 10.0
            cell.layer.masksToBounds = true

        default:
            return cell
        }
        let separatorView = UIView()
            separatorView.backgroundColor = .black
            separatorView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(separatorView)
            separatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor).isActive = true
            separatorView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor).isActive = true
            separatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor).isActive = true
            separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
            
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//
        switch(indexPath.row){
        case 0:
            play(url: NSURL(string: videoData.musicLink)!)
            break
        case 1:
            let collections: [String:Any] = self.userDefaults.object(forKey: "collections") as? [String:Any] ?? [:]
                if collections.isEmpty{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "CreateCollectionVC") as! CreateCollectionVC
                    vc.delegate = self.delegate
                    present(vc, animated: true)
                } else {
                    delegate?.fillCollections()
                    let vc = storyboard?.instantiateViewController(withIdentifier: "AddToCollectionVC") as! AddToCollectionVC
                    vc.videoData = videoData
                    self.present(vc, animated: true)
                }
            break
        case 2:
            if let url = NSURL(string: videoData.shareUrl){
                UIApplication.shared.openURL(url as URL)
            }
            break
        case 3:
            let pb = UIPasteboard.general
            pb.string = hashtags.joined(separator: "")
            showAlert(title: "Success", msg: "Information copied", vc: self)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 3{
            return 100
        }
        return 60
    }

}



class TableVCell: UITableViewCell{
    @IBOutlet weak var optionslbl: UILabel!
    @IBOutlet weak var cellV: UIView!
    @IBOutlet weak var imgV: UIImageView!

}


