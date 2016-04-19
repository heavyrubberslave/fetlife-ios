//
//  LoginViewController.swift
//  FetLife
//
//  Created by Jose Cortinas on 2/5/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit
import p2_OAuth2

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var devilHeartImage: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func login(sender: UIButton) {
        sender.setTitle("Authorizing...", forState: .Normal)
        
        API.authorizeInContext(self,
            onAuthorize: { parameters in self.didAuthorizeWith(parameters) },
            onFailure: { error in self.didCancelOrFail(error) }
        )
    }
    
    func didAuthorizeWith(parameters: OAuth2JSON) {
        if let window = UIApplication.sharedApplication().delegate?.window! {
            window.rootViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("chatSplitView")
        }
    }
    
    func didCancelOrFail(error: ErrorType?) {
        if let error = error {
            print("Failed to auth with error: \(error)")
        }
        
        loginButton.setTitle("Login with your FetLife account", forState: .Normal)
        loginButton.enabled = true
    }
}