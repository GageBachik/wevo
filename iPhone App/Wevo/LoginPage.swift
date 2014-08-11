//
//  LoginPage.swift
//  TCKnowledgeGraph
//
//  Created by Gage Bachik on 8/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import UIKit

class LoginPage: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func FreebaseButton(sender: AnyObject) {
        println("Went to Segue")
        self.performSegueWithIdentifier("goToFreebase", sender: self)

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
