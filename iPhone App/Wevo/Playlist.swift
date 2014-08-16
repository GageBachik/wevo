//
//  Playlist.swift
//  Wevo
//
//  Created by Gage Bachik on 8/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import UIKit

class Playlist: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let cSelector : Selector = "newMusicSearch:"
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func newMusicSearch(sender: AnyObject) {
        self.navigationController.popViewControllerAnimated(true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
