//
//  ViewController.swift
//  Wevo
//
//  Created by Gage Bachik on 8/10/14.
//  Copyright (c) 2014 Gage Bachik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var filePath = NSBundle.mainBundle().pathForResource("croptest", ofType: "gif")
        var gif = NSData(contentsOfFile: filePath)
        
        var webViewBG = UIWebView(frame: self.view.frame)
        webViewBG.loadData(gif, MIMEType: "image/gif", textEncodingName: nil, baseURL: nil)
        webViewBG.userInteractionEnabled = false;
        self.view.addSubview(webViewBG)
        
        var filter = UIView()
        filter.frame = self.view.frame
        filter.backgroundColor = UIColor.blackColor()
        filter.alpha = 0.05
        self.view.addSubview(filter)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

