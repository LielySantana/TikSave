//
//  collectionModel.swift
//  TikSave
//
//  Created by Christina Santana on 20/3/23.
//

import Foundation

struct CollectionModel: Codable{
    var name: String
    var imageUrl:String
    var videoList: [downModel]
}
