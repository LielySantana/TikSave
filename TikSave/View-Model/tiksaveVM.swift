//
//  tiksaveVM.swift
//  TikSave
//
//  Created by Christina Santana on 16/3/23.
//

import Foundation
import UIKit

struct UsersVM{
    func getUserId(userName: String, comp:@escaping(String)->()){
        
        let headers = [
            "X-RapidAPI-Key": "",
            "X-RapidAPI-Host": "tokapi-mobile-version.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://tokapi-mobile-version.p.rapidapi.com/v1/user/username/\(userName)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 30.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        print("https://tokapi-mobile-version.p.rapidapi.com/v1/user/username/\(userName)")
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
                do{
                    var jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    
                    
                    var userId = jsonData.value(forKey: "uid") as? String
                    
                    //                      //print(userId)
                    //                        print("======================USER ID VM===================================")
                    comp(userId!)
                }catch{
                    print(error)
                    comp("")
                }
            }
        })
        
        dataTask.resume()
        
    }
    
    
    
    @available(iOS 15.0.0, *)
    func getUserData(userId: String, comp:@escaping(UserModel)->()){
        
        let headers = [
            "X-RapidAPI-Key": "",
            "X-RapidAPI-Host": "tokapi-mobile-version.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://tokapi-mobile-version.p.rapidapi.com/v1/user/\(userId)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        print("https://tokapi-mobile-version.p.rapidapi.com/v1/user/\(userId)")
        let session = URLSession.shared
        var userDataArray: UserModel!
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
            } else {
            
            do{
                var jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                
                var userInfo = jsonData.value(forKey: "user") as? NSDictionary
                var profilePic = userInfo!.value(forKey: "avatar_168x168") as? NSDictionary
                var picUrl: [String] = profilePic!.value(forKey: "url_list") as! [String]
                
                var userId = userInfo!.value(forKey: "uid") as? String
                var nickname = userInfo!.value(forKey: "unique_id") as? String
                
                
                var followers = userInfo!.value(forKey: "follower_count") as? Int
                var following = userInfo!.value(forKey: "following_count") as? Int
                var likes = userInfo!.value(forKey: "total_favorited") as? Int
                
                var topUserData: UserModel = UserModel(profilePicUrl: picUrl[0], nickname: nickname!, userId: userId!, follower: followers!, following: following!, likes: likes!)
                userDataArray = topUserData
                //                print(topUserData)
                print("======================USER DATA VM===================================")
                comp(userDataArray)
            }catch{
                print(error)
               
            }
        }
    })
    
    dataTask.resume()
    }
}
    
