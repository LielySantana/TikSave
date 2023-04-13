//
//  downloadModel.swift
//  TikSave
//
//  Created by Christina Santana on 17/3/23.
//

import Foundation

struct downModel: Codable, Equatable{
    var videoId: String
    var musicLink: String
    var musicAuthor: String
    var playCount: Int
    var commentCount: Int
    var likesCount: Int
    var shareCount: Int
    var videoUrlNoWaterMarked: String
    var videoCover: String
    var videoURLWaterMarked: String
    var shareUrl: String
    var userId: String
    var profilePic: String
    var hashtag: [String]
    var downDate: String
    
}
