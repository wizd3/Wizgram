//
//  LoginViewController.swift
//  Wizgram
//
//  Created by Dhiaa Bantan on 2/23/22.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var UserNameTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    // When Sign In Button gets pressed:
    @IBAction func SignInPressed(_ sender: UIButton) {
        
        // Get the username and password from the textfields:
        if let userName = UserNameTF.text, let pass = PasswordTF.text {
            
            // Parse - Login method:
            PFUser.logInWithUsername(inBackground: userName, password: pass) { user, error in
                
                if user != nil {
                    // If it is a successful login, navigate to the Feed screen:
                    self.performSegue(withIdentifier: "loginSegue", sender: nil)
                } else {
                    // If there is an error, print it:
                    print(error?.localizedDescription)
                }
            }
        }
        
    }
    
    // When Sign Up Button gets pressed:
    @IBAction func SignUpPressed(_ sender: UIButton) {
        
        // Create user account:
        let user = PFUser()
        user.username = UserNameTF.text
        user.password = PasswordTF.text
        
        // Parse - Sign up method:
        user.signUpInBackground { success, error in
            if success {
                
                // If it is a successful signing up, navigate to the Feed screen:
                self.performSegue(withIdentifier: "loginSegue", sender: nil)

            } else {
                // If there is an error, print it:
                print(error?.localizedDescription)
            }
            
        }
    }
    
    
    
}
