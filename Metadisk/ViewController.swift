//
//  ViewController.swift
//  Metadisk
//
//  Created by Jan Potuznik on 10.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController, UITextFieldDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        usernameField.delegate = self
        usernameField.becomeFirstResponder()
        usernameField.tag = 0
        passwordField.tag = 1
        passwordField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name: UIKeyboardWillHideNotification, object: nil)
        
    }


    
    
    //MARK: - Login
    func login() {
        if usernameField.text?.characters.count > 0 && passwordField.text?.characters.count > 0 {
            General.user = usernameField.text!
            General.password = passwordField.text!
            print("user: \(General.user) pass: \(General.password)")
            
            Alamofire.request(.GET, "https://api.metadisk.org/keys", headers: General.headers).responseString
                { response in
                    if let httpError = response.result.error {
                        let statusCode = httpError.code
                        print("Some errors in login, code: \(statusCode)")
                    } else { //no errors
                        let statusCode = (response.response?.statusCode)!
                        if statusCode == 200 {
                            print("login succesful")
                            self.performSegueWithIdentifier("showBucketsTVC", sender: nil)
                        }
                    }
                    
                    
            }
        }
        
        
    }
    
    
    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    @IBAction func loginButton(sender: UIButton) {
        login()
    }
    
    
    @IBAction func useDemoAccount(sender: UIButton) {
        usernameField.text = "mazeltov3@sharklasers.com"
        passwordField.text = "mazeltov3@sharklasers.com"
        login()
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            if string == "\n" {
                usernameField.resignFirstResponder()
                passwordField.becomeFirstResponder()
                return true
            }
        } else if textField.tag == 1 {
            if string == "\n" {
                login()
                return true
            }
        }
        
        
        return true
    }
    
    
    

    
    
    
    
    //MARK: - Keyboard showing up, constraint
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    func keyboardWillAppear(notification: NSNotification){
        _ = UIApplication.sharedApplication()
        if let userInfo = notification.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                bottomConstraint.constant = keyboardHeight + 10
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    func keyboardWillDisappear(notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let _ = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size.height {
                bottomConstraint.constant = 0.0 + 10
                UIView.animateWithDuration(0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    
    
    
    
    
}

