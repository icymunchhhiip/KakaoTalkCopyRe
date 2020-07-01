//
//  FriendsViewController.swift
//  KakaoTalkCopyRe
//
//  Created by dindon on 2020/06/30.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var array: [UserModel] = []
    var selectedIndex: Int?
    
    @objc func printTestItem() {
        print("clickckckckckck")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendsViewTableCell
        
        let url = URL(string: array[indexPath.row].profileImageURL!)
        
        cell.imageview.layer.cornerRadius = 50/2 // imageView.frame.size.width/2 이거는 그려지기 전에 연산하기 때문에 정상적으로 출력이 안돼서 상수로 넣어줬다
        cell.imageview.clipsToBounds = true
        
        cell.imageview.kf.setImage(with: url)
        
        cell.nameLabel.text = array[indexPath.row].name
        
        if let message = array[indexPath.row].message {
            cell.messageLabel.text = message
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let view = self.storyboard?.instantiateViewController(identifier: "ProfileTabBarController") as? ProfileTabBarController {
            view.modalPresentationStyle = .fullScreen
            self.present(view, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Custom navigation-bar
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Friends"
        label.textAlignment = .left
        navigationItem.titleView = label
        if let navigationBar = navigationController?.navigationBar {
            
            label.leadingAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
            label.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor, constant: 0).isActive = true
            //            label.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0).isActive = true
            //            label.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
            
            let searchFriendButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(printTestItem))
            let addFriendButton = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"), style: .plain, target: self, action: #selector(printTestItem))
            let playMusicButton = UIBarButtonItem(image: UIImage(systemName: "music.note"), style: .plain, target: self, action: #selector(printTestItem))
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [settingButton, playMusicButton, addFriendButton, searchFriendButton]
            
        }
        
        // MARK: Load Friends-List
        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            
            self.array.removeAll()
            
            //            let myUid = Auth.auth().currentUser?.uid
            
            //MARK: Read user info
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                if let dicItem = fchild.value as? [String : Any]{
                    userModel.setValuesForKeys(dicItem)
                    //                    if userModel.uid != myUid {
                    self.array.append(userModel)
                    //                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        }
        
    }
    
    
    
}

class FriendsViewTableCell: UITableViewCell {
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
}
