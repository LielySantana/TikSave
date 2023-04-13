//
//  VideoCVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit

class VideoCVC: UICollectionViewCell {

    @IBOutlet weak var countLbl: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    var videoData: downModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
        imgV.alpha = 0.75
    }

}
