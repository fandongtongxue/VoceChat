//
//  ChatsViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ChatsViewController: BaseViewController {
    
    var chats = [VCMessageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Chats", comment: "")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Do any additional setup after loading the view.
        //在线状态通知
        NotificationCenter.default.rx.notification(.user_state)
            .subscribe { noti in
                let model = noti.element?.object as! VCSSEEventModel
                for xuser in model.users {
                    for ychat in self.chats {
                        if xuser.uid == ychat.from_uid {
                            ychat.online = xuser.online
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }.disposed(by: disposeBag)
        //在线状态改变通知
        NotificationCenter.default.rx.notification(.users_state_changed)
            .subscribe { noti in
                let model = noti.element?.object as! VCSSEEventModel
                let models = self.chats.filter { message in
                    message.from_uid == model.uid
                }
                models.first?.online = model.online
                let index = self.chats.firstIndex { message in
                    message.from_uid == model.uid
                } ?? 0
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
            .disposed(by: disposeBag)
        //消息通知
        NotificationCenter.default.rx.notification(.chat).subscribe { noti in
            let jsonString = noti.element?.object as? String
            let message = VCMessageModel.deserialize(from: jsonString) ?? VCMessageModel()
            let from = self.chats.contains(where: {$0.from_uid == message.from_uid})
            let index = self.chats.firstIndex(where: {$0.from_uid == message.from_uid}) ?? 0
            if from{
                self.chats[index] = message
            }else {
                let target = self.chats.contains(where: {$0.from_uid == message.target.uid})
                //替换这个元素
                if target {
                    self.chats[index].detail.content = message.detail.content
                    self.chats[index].created_at = message.created_at
                }else {
                    self.chats.append(message)
                }
            }
            
            guard let json = UserDefaults.standard.string(forKey: .users_state) else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                return
            }
            let model = VCSSEEventModel.deserialize(from: json) ?? VCSSEEventModel()
            for xuser in model.users {
                for ychat in self.chats {
                    if xuser.uid == ychat.from_uid {
                        ychat.online = xuser.online
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
    }
    

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatListCell", bundle: Bundle.main), forCellReuseIdentifier: NSStringFromClass(ChatListCell.classForCoder()))
        return tableView
    }()

}

extension ChatsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ChatListCell.classForCoder()), for: indexPath) as! ChatListCell
        if indexPath.row < chats.count {
            cell.model = chats[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let chatVC = ChatViewController()
        let user = VCUserModel()
        user.uid = chats[indexPath.row].from_uid
        chatVC.model = user
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
