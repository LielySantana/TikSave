//
//  PostServices.swift
//  TikSave
//
//  Created by Christina Santana on 17/3/23.
//

import Foundation

struct PostServices{
    static var shared = PostServices()
    var delegate: PostListDelegate?
    var postList: [PostModel]{
        get{
            let posts = try? UserDefaults().getObject(forKey: "postList", castTo: [PostModel].self)
            return posts ?? []
        }
        set{
            try? UserDefaults.standard.setObject(newValue, forKey: "postList")
            
        }
        
    }
    
    mutating func addPost(_ post: PostModel) {
           var posts = postList
           posts.append(post)
           postList = posts
        delegate?.postListDidChange()

        
    }
    
 
}
