//
//  ColVideoCVC.swift
//  TikSave
//
//  Created by Christina Santana on 30/3/23.
//

import UIKit

class ColVideoCVC: UICollectionViewCell{
    
    @IBOutlet weak var videoCoverImg: UIImageView!
    @IBOutlet weak var profilePicImg: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var playedLbl: UILabel!
    @IBOutlet weak var commentsLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var sharedLbl: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    var videoData: downModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        videoCoverImg.layer.cornerRadius = 8.0
        


        
        
        
    }
}
