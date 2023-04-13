//
//  CollectionCVC.swift
//  TikSave
//
//  Created by krunal on 25/02/23.
//

import UIKit

class CollectionCVC: UICollectionViewCell {

    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8.0
    }

}
