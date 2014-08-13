//
//  Play.swift
//  Wevo
//
//  Created by Gage Bachik on 8/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import Foundation

@objc class Play : UIViewController {
    
    @objc func postToServer(artists: NSArray, userId: NSString) {
        
        var postData = ["artists": artists]
        println("the post data is: \(postData)");
        println("the userId is: \(userId)");
        var postUrl = "http://192.168.1.120:1337/music/" + userId
        Alamofire.request(.POST, postUrl, parameters: postData)
            .responseJSON {(request, response, JSON, error) in
                println(error)
                println(JSON)
//                var parsed = JSON as NSDictionary
//                println(parsed)
//                self.performSegueWithIdentifier("startPlaylist", sender: self)
        }
    }
}