//
//  ProfileTabBarController.swift
//  KakaoTalkCopyRe
//
//  Created by dindon on 2020/07/01.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: ViewController {
    
    @IBOutlet weak var cancelButton: UIImageView!
    @IBOutlet weak var topMenu2ImageView: UIImageView!
    @IBOutlet weak var topMenu3ImageView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var chatStackView: UIStackView!
    @IBOutlet weak var chatLabel: UILabel!
    
    @IBOutlet weak var bottomMenu2StackView: UIStackView!
    @IBOutlet weak var bottomMenu2ImageView: UIImageView!
    @IBOutlet weak var bottomMenu2Label: UILabel!
    
    var profileInfo: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancelButton.isUserInteractionEnabled = true
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonTapped)))
        
        cancelButton.isUserInteractionEnabled = true
        cancelButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelButtonTapped)))
        
        let url = URL(string: profileInfo!.profileImageURL!)
        profileImageView.kf.setImage(with: url)
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2
        profileImageView.clipsToBounds = true
        
        nameLabel.text = profileInfo?.name
        
        if let message = profileInfo?.message {
            messageLabel.text = message
        } else {
            messageLabel.text = ""
        }
        
        chatStackView.isUserInteractionEnabled = true
        chatStackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(chatStackViewTapped)))
        bottomMenu2StackView.isUserInteractionEnabled = true
        
        if profileInfo!.uid! == Auth.auth().currentUser?.uid {
            topMenu2ImageView.image = UIImage(systemName: "barcode.viewfinder")
            topMenu3ImageView.image = UIImage(systemName: "gear")
            
            chatLabel.text = "My Chatroom"
            bottomMenu2ImageView.image = UIImage(systemName: "pencil")
            bottomMenu2Label.text = "Edit Profile"
            
            bottomMenu2StackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editStackViewTapped)))
        } else {
            topMenu2ImageView.image = UIImage(systemName: "wonsign.circle")
            topMenu3ImageView.image = UIImage(systemName: "star.circle")
            
            chatLabel.text = "Free Chat"
            bottomMenu2ImageView.image = UIImage(systemName: "phone.fill")
            bottomMenu2Label.text = "Call"
        }
        
    }

    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func chatStackViewTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func editStackViewTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
