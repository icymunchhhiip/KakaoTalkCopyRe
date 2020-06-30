//
//  SignInViewController.swift
//  KakaoTalkCopyRe
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        try? Auth.auth().signOut()
        self.autoSignIn()
    }
    
    enum SignInAlertMsg : String {
        case emptyEmail = "Email is empty"
        case emptyPassword = "Password is empty"
        case failedSignIn = "Sign-in failed"
        case loadUid = "User cannot be loaded"
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignInAlertMsg.emptyEmail.rawValue); return }
        guard let password = passwordTextField.text, !password.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignInAlertMsg.emptyPassword.rawValue); return }
        Auth.auth().signIn(withEmail: email, password: password) { (user, err) in
            if let err = err {
                self.displayOKAlert(err: err, title: SignInAlertMsg.failedSignIn.rawValue, msg: err.localizedDescription)
            } else {
                self.autoSignIn()
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        
        self.present(view, animated: true, completion: nil)
    }
    
    func autoSignIn() {
        if Auth.auth().currentUser != nil {
            let view = self.storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            view.modalPresentationStyle = .fullScreen
            self.present(view, animated: true, completion: nil)
        }
    }
    
}
