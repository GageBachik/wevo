//
//  Playlist.swift
//  Wevo
//
//  Created by Gage Bachik on 8/12/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import UIKit

var firstPlay: Bool = true;
var videoIds: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("videoIds")
var count: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("count");
var currentIndex = 0;
var currentImage = 0;
var playImage = UIImage(named: "Play.png")
var pauseImage = UIImage(named: "pause 2.png")
var parsedVideoIds = videoIds as NSArray;
var currentVideo = parsedVideoIds[currentIndex] as NSString
var videoPlayerViewController: XCDYouTubeVideoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: currentVideo);

class Playlist: UIViewController {
    
    @IBOutlet var pauseplayButton: UIButton!
    @IBOutlet var customControls: UIView!
    var token: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey("token")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let cSelector : Selector = "newMusicSearch:"
        let rightSwipe = UISwipeGestureRecognizer(target: customControls, action: cSelector)
        rightSwipe.direction = UISwipeGestureRecognizerDirection.Right
        // Do any additional setup after loading the view.
        
        //notify me when video has ended
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoEnded:", name: MPMoviePlayerPlaybackDidFinishNotification, object: nil)
        
        //end
//        videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = true;
//        videoPlayerViewController.presentInView(self.view);
//        videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyle.None
//        self.view.bringSubviewToFront(customControls);
//        videoPlayerViewController.moviePlayer.play()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController.setNavigationBarHidden(true, animated: false)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.None);
        if (!firstPlay){
            currentIndex = 0;
            currentImage = 0;
            videoIds = NSUserDefaults.standardUserDefaults().objectForKey("videoIds")
            count = NSUserDefaults.standardUserDefaults().objectForKey("count");
            parsedVideoIds = videoIds as NSArray;
            currentVideo = parsedVideoIds[currentIndex] as NSString
            videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: currentVideo);
        }else{
            firstPlay = false;
        }
        videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = true;
        videoPlayerViewController.presentInView(self.view);
        videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyle.None
        self.view.bringSubviewToFront(customControls);
        videoPlayerViewController.moviePlayer.play()
        currentImage = 0
        pauseplayButton.setImage(pauseImage, forState: UIControlState.Normal)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func newMusicSearch(sender: AnyObject) {
        self.navigationController.popViewControllerAnimated(true);
    }
    
    //playback changed
    
    @IBAction func didPressPausePlay(sender: AnyObject) {
        if (currentImage == 0){
            currentImage = 1
            videoPlayerViewController.moviePlayer.pause()
            pauseplayButton.setImage(playImage, forState: UIControlState.Normal)
        }else{
            currentImage = 0
            videoPlayerViewController.moviePlayer.play()
            pauseplayButton.setImage(pauseImage, forState: UIControlState.Normal)
        }
    }

    @IBAction func didPressNext(sender: AnyObject) {
        if (currentIndex < count as NSInteger){
            currentIndex++
            println("current index \(currentIndex)")
            currentVideo = parsedVideoIds[currentIndex] as NSString
            videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: currentVideo);
            videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = true;
            videoPlayerViewController.presentInView(self.view);
            videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyle.None
            self.view.bringSubviewToFront(customControls);
            videoPlayerViewController.moviePlayer.play()
            currentImage = 0
            pauseplayButton.setImage(pauseImage, forState: UIControlState.Normal)
        }else{
            currentIndex = 0
            println("hit 11 currint index:\(currentIndex)")
            var postData = ["userId": token];
            var postUrl = "http://107.170.6.117:49154/user/getNextTen"
            Alamofire.request(.POST, postUrl, parameters: postData)
                .responseJSON {(request, response, JSON, error) in
                    println("Error: \(error)")
                    var parsed = JSON as NSDictionary
                    count = parsed["count"] as NSInteger
                    parsedVideoIds = parsed["videoIds"] as NSArray
                    currentVideo = parsedVideoIds[currentIndex] as NSString
                    videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: currentVideo);
                    videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = true;
                    videoPlayerViewController.presentInView(self.view);
                    videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyle.None
                    self.view.bringSubviewToFront(self.customControls);
                    videoPlayerViewController.moviePlayer.play()
                    currentImage = 0
                    self.pauseplayButton.setImage(pauseImage, forState: UIControlState.Normal)
            }

        }

    }

    @IBAction func didPressPrevious(sender: AnyObject) {
        if (currentIndex != 0){
            currentIndex--
            currentVideo = parsedVideoIds[currentIndex] as NSString
            videoPlayerViewController = XCDYouTubeVideoPlayerViewController(videoIdentifier: currentVideo);
            videoPlayerViewController.moviePlayer.backgroundPlaybackEnabled = true;
            videoPlayerViewController.presentInView(self.view);
            videoPlayerViewController.moviePlayer.controlStyle = MPMovieControlStyle.None
            self.view.bringSubviewToFront(customControls);
            videoPlayerViewController.moviePlayer.play()
            currentImage = 0
            pauseplayButton.setImage(pauseImage, forState: UIControlState.Normal)
        }
    }
    
    //Notification recieved
    
    func videoEnded(notification: NSNotification){

        let userInfo = notification.userInfo as [String:NSNumber]
        let reason = userInfo[MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
        let finishReason = MPMovieFinishReason.fromRaw(reason!.integerValue)
        if (finishReason == MPMovieFinishReason.PlaybackEnded){
            didPressNext(self);
        }
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
