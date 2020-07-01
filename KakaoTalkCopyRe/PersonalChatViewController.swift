//
//  PersonalChatViewController.swift
//  KakaoTalkCopyRe
//
//  Created by dindon on 2020/07/01.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class PersonalChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var uid: String?
    var chatroomUid: String?
    var destinationUid: String?
    
    var destinationUserModel: UserModel?
    var comments: [ChatModel.Comment] = []
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var peopleCount: Int?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var keyboardHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid

        DidCreateChatroom()
        
        self.tabBarController?.tabBar.isHidden = true // 탭바 사라짐
        
        // MARK: 바깥을 누르면 키보드가 사라짐
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        // NotificationCenter가 동작하는 방식
        // 1. 특정 객체가 NotificationCenter에 등록된 Event를 발생 (=Post)
        // 2. 해당 Event 처리가 등록된 Observer들이 등록된 행동을 취함
        self.tabBarController?.tabBar.isHidden = false
        
        // 읽은 표시를 지켜보는 observe가 채팅방을 나가면 없어짐
        databaseRef?.removeObserver(withHandle: observe!)
    }
    
    @objc func keyboardWillAppear(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.keyboardHeightConstraint.constant = keyboardSize.height
        }
        
        UIView.animate(withDuration: 0, animations: {
            self.view.layoutIfNeeded()
        }) { (complete) in
            // MARK: 키보드 올라올 때 채팅방 내용을 맨 아래로 보여주기
            if self.comments.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification)  {
        self.keyboardHeightConstraint.constant = 0
        self.view.layoutIfNeeded() // view의 변화를 동기적으로, 즉시 반영 요청
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.comments[indexPath.row].uid == uid {
            let view = tableView.dequeueReusableCell(withIdentifier: "myMessageCell", for: indexPath) as! MyMessageCell
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0 // MARK: 이렇게 해야 여러 줄 나올 수 있다?
            
            if let time = self.comments[indexPath.row].timestamp {
                view.timestampLabel.text = time.toDayTime
            }
            
            setReadCount(label: view.readCounterLabel, position: indexPath.row)
            
            return view
        } else {
            let view = tableView.dequeueReusableCell(withIdentifier: "destinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.nameLabel.text = self.destinationUserModel?.name
            view.messageLabel.text = self.comments[indexPath.row].message
            view.messageLabel.numberOfLines = 0
            
            let url = URL(string: (self.destinationUserModel?.profileImageURL)!)!
            view.profileImageView.layer.cornerRadius = view.profileImageView.frame.width/2
            view.profileImageView.clipsToBounds = true
            view.profileImageView.kf.setImage(with: url)
            URLSession.shared.dataTask(with: url) { (data, response, err) in
                DispatchQueue.main.async {
                    view.profileImageView.image = UIImage(data: data!)
                }
            }.resume()
            
            if let time = self.comments[indexPath.row].timestamp {
                view.timestampLabel.text = time.toDayTime
            }
            
            setReadCount(label: view.readCounterLabel, position: indexPath.row)
            
            return view
        }
        
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true) // 키보드 내리기
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @IBAction func createChatroom(_ sender: Any) {
        //        debugPrint("debugPrint 46")
        let chatroomInfo: Dictionary<String,Any> = [
            "users": [
                uid!: true,
                destinationUid!: true
            ]
        ]

        // MARK: 방 생성
        // FIXME: else일 때만 comment 넘겨짐. nil일 때도 넘겨줘야.
        if chatroomUid == nil {
            self.sendButton.isEnabled = false
            Database.database().reference().child("chats").childByAutoId().setValue(chatroomInfo, withCompletionBlock: { err,ref in
                if err == nil {
                    self.DidCreateChatroom()
                }
                self.sendButton.isEnabled = true
            })
        } else {
            let value: Dictionary<String,Any> = [
                "uid": uid!,
                "message": messageTextField.text!,
                "timestamp": ServerValue.timestamp()
            ]

            Database.database().reference().child("chats").child(chatroomUid!).child("comments").childByAutoId().setValue(value) { (err, ref) in
                // MARK: 메세지 보내고 나서 알람보내고 입력창 초기화
                self.messageTextField.text = ""
            }
            
        }
    }
    
    func DidCreateChatroom() {
        Database.database().reference().child("chats").queryOrdered(byChild: "users/"+uid!).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                if let chatroomDic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatroomDic);
                    if chatModel?.users[self.destinationUid!] == true {
                        self.chatroomUid = item.key
                        self.getDestinationInfo()
                    }
                }
            }
        }
    }
    
    // 안 읽은 사람 인원 수
    func setReadCount(label: UILabel?, position: Int?) {
        let readCount = self.comments[position!].readUsers.count // 읽은 사람 수
        
        // 서버에 무리를 줄이기 위함
        if peopleCount == nil {
            Database.database().reference().child("chats").child(chatroomUid!).child("users").observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
                let dic = datasnapshot.value as! [String:Any]
                self.peopleCount = dic.count
                let noReadCount = self.peopleCount! - readCount
                
                if noReadCount > 0 {
                    label?.isHidden = false
                    label?.text = String(noReadCount)
                } else {
                    label?.isHidden = true
                }
            }
        } else {
            let noReadCount = self.peopleCount! - readCount
            
            if noReadCount > 0 {
                label?.isHidden = false
                label?.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
        }
    }
    
    func getMessageList() {
        databaseRef = Database.database().reference().child("chats").child(self.chatroomUid!).child("comments")
        observe = databaseRef?.observe(DataEventType.value){ (datasnapshot) in
            self.comments.removeAll() // 누적 방지
            
            var readUserDic: Dictionary<String,AnyObject> = [:]
            for item in datasnapshot.children.allObjects as! [DataSnapshot] {
                
                let key = item.key as String
                // 마지막 메세지 읽었는지 보고.  comment 분기 처리. 1: comments. 2: readuserdic
                let comment = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                let comment_motify = ChatModel.Comment(JSON: item.value as! [String:AnyObject])
                comment_motify?.readUsers[self.uid!] = true
                readUserDic[key] = (comment_motify?.toJSON())! as NSDictionary // firebase는 NSDictionary를 지원
                self.comments.append(comment!)
            }
            let nsDic = readUserDic as NSDictionary
            
            if self.comments.last?.readUsers.keys == nil {
                return
            }
            
            if !(self.comments.last?.readUsers.keys.contains(self.uid!))! { // 읽는 것 체크인데 채팅방을 방금 만들어서 코멘트 없을 때 에러날 수 있으므로 바로 위 if문에서 nil 체크.
                // 업데이트
                datasnapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any]) { (err, ref) in
                    // 업데이트 성공하면 데이터 리로드
                    self.tableView.reloadData()
                    
                    // MARK: 메세지 내용 가져올 때 채팅방 내용을 맨 아래로 보여주기
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                
                }
            } else {
                // 업데이트 된 거 표현만 해줌
                self.tableView.reloadData()
                
                // MARK: 메세지 내용 가져올 때 채팅방 내용을 맨 아래로 보여주기
                if self.comments.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
            
        }
    }
    
    func getDestinationInfo() {
        Database.database().reference().child("users").child(self.destinationUid!).observeSingleEvent(of: DataEventType.value) { datasnapshot in
            self.destinationUserModel = UserModel()
            self.destinationUserModel?.setValuesForKeys(datasnapshot.value as! [String:Any])
            self.getMessageList()
        }
    }

}

extension Int {
    var toDayTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
        let date = Date(timeIntervalSince1970: Double(self)/1000)
        return dateFormatter.string(from: date)
    }
}

class MyMessageCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var readCounterLabel: UILabel!
}

class DestinationMessageCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var readCounterLabel: UILabel!
}
