//
//  SignUpViewController.swift
//  KakaoTalkCopyRe
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imagePicker)))
        
        cancelButton.addTarget(self, action: #selector(cancelEvent), for: .touchUpInside)
    }
    
    enum SignUpAlertMsg : String {
        case emptyEmail = "Email is empty"
        case emptyPassword = "Password is empty"
        case emptyName = "Name is empty"
        case completedSignUp = "sign-up completed"
        case loadUid = "User cannot be loaded"
    }
    
    @objc func imagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func OKButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyEmail.rawValue); return }
        guard let password = passwordTextField.text, !password.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyPassword.rawValue); return }
        guard let name = nameTextField.text, !name.isEmpty else { self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.emptyName.rawValue); return }
        
        if email != "" && password != "" && name != "" {
            Auth.auth().createUser(withEmail: email, password: password) { (user, err) in
                if let err = err {
                    self.displayOKAlert(err: err, title: nil, msg: err.localizedDescription)
                }
                else {
                    if let uid = user?.user.uid {
                        if let profile = self.profileImageView.image, let selectedProfile = profile.jpegData(compressionQuality: 0.1) {
                            
                            let storageRef = Storage.storage().reference().child("userImages").child(uid)
                            storageRef.putData(selectedProfile, metadata: nil, completion: { (data,err) in
                                
                                storageRef.downloadURL { url, err in
                                    if err == nil, url == nil {
                                        Database.database().reference().child("users").child(uid).setValue(["name":name])
                                    } else {
                                        Database.database().reference().child("users").child(uid).setValue(["uid": Auth.auth().currentUser?.uid, "name":name, "profileImageURL": url?.absoluteString])
                                    }
                                }
                                
                                let alert = UIAlertController(title: "Welcome!", message: SignUpAlertMsg.completedSignUp.rawValue, preferredStyle: UIAlertController.Style.alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                                    self.cancelEvent()
                                }))
                                
                                self.present(alert, animated: true)
                                
                            })
                            
                        }
                    } else {
                        self.displayOKAlert(err: nil, title: nil, msg: SignUpAlertMsg.loadUid.rawValue)
                    }
                    
                }
            }
        }
    }
    
    @objc func cancelEvent() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
