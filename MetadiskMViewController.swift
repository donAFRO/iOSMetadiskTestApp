//
//  ViewController.swift
//  Metadisk
//
//  Created by Jan Potuznik on 10.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


    @IBOutlet weak var usernameField: UITextField!

    @IBOutlet weak var passwordField: UITextField!
    @IBAction func loginButton(sender: UIButton) {
        
        
        self.performSegueWithIdentifier("showBucketsTVC", sender: nil)
        
    }
}

