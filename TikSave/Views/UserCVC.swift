//
//  UserCVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit

class UserCVC: UICollectionViewCell {

    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    var userData: UserModel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
    }

}
