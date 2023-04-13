//
//  userModel.swift
//  TikSave
//
//  Created by Christina Santana on 16/3/23.
//
import Foundation

struct UserModel: Codable, Equatable{
    var profilePicUrl: String
    var nickname: String
    var userId: String
    var follower: Int
    var following: Int
    var likes: Int
}

