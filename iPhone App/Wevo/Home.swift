//
//  Home.swift
//  Wevo
//
//  Created by Gage Bachik on 8/11/14.
//  Copyright (c) 2014 Lee Tze Cheun. All rights reserved.
//

import UIKit

class Home: UIViewController, UITextFieldDelegate {
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
              var token: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("token")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
        self.navigationController.navigationBar.barStyle = UIBarStyle.Default;
        self.setNeedsStatusBarAppearanceUpdate()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        if (token !== nil){
            self.performSegueWithIdentifier("goToFreebase", sender: self)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: NSSet!, withEvent event: UIEvent!) {
        self.view.endEditing(true)
    }
    
    // exit keyboard on return or go to next if username
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        if (textField.secureTextEntry) {
            textField.resignFirstResponder()
        }else {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    // sign in and sign up tapped
    
    @IBAction func didSignIn(sender: AnyObject) {

        Alamofire.request(.POST, "http://107.170.6.117:49157/auth", parameters: ["username": usernameTextField.text, "password": passwordTextField.text])
            .responseJSON {(request, response, JSON, error) in
                println(error)
                println(JSON)
                var parsed = JSON as NSDictionary
                if (parsed["name"] as NSString == "MongoError"){
                    let alert = UIAlertView()
                    alert.title = "Error:"
                    alert.message = "Check Your Username/Password!"
                    alert.addButtonWithTitle("Okay")
                    alert.show()
                }else{
                    println("Went to Segue")
                    NSUserDefaults.standardUserDefaults().setObject(parsed["name"], forKey:"token")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.performSegueWithIdentifier("goToFreebase", sender: self)
                }
        }
    }
    
    @IBAction func didSignUp(sender: AnyObject) {
        
        Alamofire.request(.POST, "http://107.170.6.117:49157/auth", parameters: ["username": usernameTextField.text, "password": passwordTextField.text])
            .responseJSON {(request, response, JSON, error) in
                println(error)
                println(JSON)
                var parsed = JSON as NSDictionary
                if (parsed["name"] as NSString == "MongoError"){
                    let alert = UIAlertView()
                    alert.title = "Error:"
                    alert.message = "Check Your Username/Password!"
                    alert.addButtonWithTitle("Okay")
                    alert.show()
                }else{
                    println("Went to Segue")
                    NSUserDefaults.standardUserDefaults().setObject(parsed["name"], forKey:"token")
                    NSUserDefaults.standardUserDefaults().synchronize()
                    self.performSegueWithIdentifier("goToFreebase", sender: self)
                }
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
            return UIStatusBarStyle.LightContent;
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
