//
//  downloadVM.swift
//  TikSave
//
//  Created by Christina Santana on 17/3/23.
//

import Foundation
import UIKit
struct VideoVM{
    
    func getSearch(query: String, comp:@escaping(downModel?)->()){
        
        let headers = [
            "X-RapidAPI-Key": "",
            "X-RapidAPI-Host": "tiktok-full-video-info-without-watermark.p.rapidapi.com"
        ]
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://tiktok-full-video-info-without-watermark.p.rapidapi.com/?url=https://vm.tiktok.com/ZMYxhYMt8/\(query)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in

            if (error != nil) {
                comp(nil)
                return
            } else {
                
                do{
                    var hashtags: [String] = []
                    var videoModel: downModel!
                    var jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    let okValue = jsonData["ok"]
                    if ((okValue) != nil){
                        return
                    } else{
                        var videoInfo = jsonData.value(forKey: "aweme_detail") as! NSDictionary
                        var videoId = videoInfo.value(forKey: "aweme_id") as? String
                        var userInfo = videoInfo.value(forKey: "author") as! NSDictionary
                        var uniqueId = userInfo.value(forKey: "unique_id") as? String
                        var profilePic = userInfo.value(forKey: "avatar_larger") as! NSDictionary
                        var profilePicUrl = profilePic.value(forKey: "url_list") as? [String]
                        var musicInfo = videoInfo.value(forKey: "music") as! NSDictionary
                        var musicAuthor = musicInfo.value(forKey: "author") as? String
                        var musicPlay = musicInfo.value(forKey: "play_url") as! NSDictionary
                        var musicLink = musicPlay.value(forKey: "uri") as? String
                        var videoData = videoInfo.value(forKey: "video") as! NSDictionary
                        var vidNoWM = videoData.value(forKey: "play_addr") as! NSDictionary
                        var urlNoWM = vidNoWM.value(forKey: "url_list") as? [String]
                        var videoCover = videoData.value(forKey: "origin_cover") as! NSDictionary
                        var coverUrl = videoCover.value(forKey: "url_list") as? [String]
                        var vidWM = videoData.value(forKey: "download_addr") as! NSDictionary
                        var urlWM = vidWM.value(forKey: "url_list") as? [String]
                        var vidLink = videoInfo.value(forKey: "share_url") as? String
                        var stats = videoInfo.value(forKey: "statistics") as! NSDictionary
                        var playCount = stats.value(forKey: "play_count") as? Int
                        var commentCount = stats.value(forKey: "comment_count") as? Int
                        var likesCount = stats.value(forKey: "digg_count") as? Int
                        var shareCount = stats.value(forKey: "share_count") as? Int
                        var hashtagArray = videoInfo.value(forKey: "text_extra") as! [NSDictionary]
                        for hashtag in hashtagArray{
                            var hash = hashtag.value(forKey: "hashtag_name") as? String
                            if (hash != nil){
                                hashtags.append(hash!)
                            } else{
                                hashtags.append("")
                            }
                        }
                        
                        videoModel = downModel(videoId: videoId!, musicLink: musicLink!, musicAuthor: musicAuthor!, playCount: playCount!, commentCount: commentCount!, likesCount: likesCount!, shareCount: shareCount!, videoUrlNoWaterMarked: urlNoWM![2], videoCover: coverUrl![0], videoURLWaterMarked: urlWM![2], shareUrl: vidLink!, userId: uniqueId!, profilePic: profilePicUrl![0], hashtag: hashtags, downDate: "")
                    }
                    comp(videoModel)
                }catch{
                    comp(nil)
                  
                }
                
            }
        })
        
        dataTask.resume()
    
        
        
    }
}
