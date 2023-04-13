//
//  postModel.swift
//  TikSave
//
//  Created by Christina Santana on 17/3/23.
//

import Foundation
import UIKit

struct PostModel: Codable, Equatable{
    var picData: Data!
    var date: Date!
    var caption: String!
    var uniqueID: String
}
