//
//  Play.swift
//  Wevo
//
//  Created by Gage Bachik on 8/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import Foundation

@objc class Play : UIViewController {
    
    @objc func postToServer(artists: NSArray, userId: NSString, context: UIViewController) {
        var hud = MBProgressHUD.showHUDAddedTo(context.view, animated: true)
        hud.labelText = "Forging User Experience"
        
        var postData = ["artists": artists];
        println("the post data is: \(postData)");
        println("the userId is: \(userId)");
        var postUrl = "http://107.170.6.117:49158/music/" + userId
        Alamofire.request(.POST, postUrl, parameters: postData)
            .responseJSON {(request, response, JSON, error) in
                println("Error: \(error)")
//                println(JSON)
                var parsed = JSON as NSDictionary
                NSUserDefaults.standardUserDefaults().setObject(parsed["videoIds"], forKey:"videoIds")
                NSUserDefaults.standardUserDefaults().setObject(parsed["count"], forKey:"count")
                NSUserDefaults.standardUserDefaults().synchronize()
                MBProgressHUD.hideHUDForView(context.view, animated: true);
                context.performSegueWithIdentifier("startPlaylist", sender: context)
        }
    }
}