//
//  ChatsViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import AudioToolbox

class ChatsViewController: BaseViewController {
    
    var chats = [VCMessageModel]()
    var channels = [VCChannelModel]()
    
    var unread = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Chats", comment: "") + NSLocalizedString("(Connecting)", comment: "")
//        navigationItem.titleView =
        let newChannel = UIAction(title: NSLocalizedString("New Channel", comment: ""), image: UIImage(systemName: "number")) { action in
            let newVC = NewChannelViewController()
            let nav = UINavigationController(rootViewController: newVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        let send = UIAction(title: NSLocalizedString("New Send", comment: ""), image: UIImage(systemName: "text.bubble")) { action in
            let newVC = NewChatViewController()
            let nav = UINavigationController(rootViewController: newVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        let invite = UIAction(title: NSLocalizedString("Invite", comment: ""), image: UIImage(systemName: "person.fill.badge.plus")) { action in
            let inviteVC = InviteViewController()
            let nav = UINavigationController(rootViewController: inviteVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        let menu = UIMenu(children: [newChannel, send, invite])
        if #available(iOS 14.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, menu: menu)
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let temp = VCManager.shared.getAllMsg()
        
        for msg in temp {
            operateMessage(message: msg, isFromDB: true)
        }

        // Do any additional setup after loading the view.
        //Ready通知
        NotificationCenter.default.rx.notification(.ready)
            .subscribe { noti in
                DispatchQueue.main.async {
                    self.navigationItem.title = NSLocalizedString("Chats", comment: "")
                }
            }.disposed(by: disposeBag)
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
            
            if message.from_uid != VCManager.shared.currentUser()?.user.uid {
                AudioServicesPlaySystemSound(1007)
            }
            //存入数据库
            VCManager.shared.insertMessage(message: message)
            
            self.operateMessage(message: message)
            
        }.disposed(by: disposeBag)
        //群组消息
        NotificationCenter.default.rx.notification(.joined_group).subscribe { noti in
            let model = noti.element?.object as! VCSSEEventModel
            let index = self.channels.firstIndex(where:  { $0.gid == model.gid } ) ?? -1
            guard index == -1 else { return }
            self.channels.append(model.group)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
        //关联群组消息
        NotificationCenter.default.rx.notification(.related_groups).subscribe { noti in
            let model = noti.element?.object as! VCSSEEventModel
            self.channels = model.groups
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
        //被踢出群组
        NotificationCenter.default.rx.notification(.kick_from_group).subscribe { noti in
            let model = noti.element?.object as! VCSSEEventModel
            self.channels.removeAll(where: { $0.gid == model.gid })
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }.disposed(by: disposeBag)
    }
    
    func operateMessage(message: VCMessageModel, isFromDB: Bool = false) {
        
        if message.target.uid > 0 {
            //C2C
            //如果是删除消息的通知就
            guard message.detail.detail.type != "delete" else { return }
            
            let from = self.chats.contains(where: {$0.from_uid == message.from_uid})
            let index = self.chats.firstIndex(where: {$0.from_uid == message.from_uid}) ?? 0
            if from{
                self.chats[index].detail = message.detail
                if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                    self.chats[index].unread = self.chats[index].unread + 1
                    unread = unread + 1
                }
            }else {
                if VCManager.shared.currentUser()?.user.uid == message.from_uid {
                    let target = self.chats.contains(where: {$0.from_uid == message.target.uid})
                    let newIndex = self.chats.firstIndex(where: {$0.from_uid == message.target.uid}) ?? 0
                    //替换这个元素
                    if target {
                        self.chats[newIndex].detail = message.detail
                        self.chats[newIndex].created_at = message.created_at
                        self.chats[newIndex].mid = message.mid
                        if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                            self.chats[newIndex].unread = self.chats[newIndex].unread + 1
                            unread = unread + 1
                        }
                        
                    }
                }else {
                    if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                        message.unread = 1
                        unread = unread + 1
                    }
                    self.chats.append(message)
                }
            }
            
            guard let json = UserDefaults.standard.string(forKey: .users_state) else {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.setBadgeValue(unread: self.unread)
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
                self.setBadgeValue(unread: self.unread)
            }
        }else if message.target.gid > 0 {
            //群组消息
            let index = channels.firstIndex(where: { $0.gid == message.target.gid }) ?? -1
            if index != -1 {
                channels[index].content_type = message.detail.content_type
                if message.detail.content_type == "text/plain" {
                    channels[index].content = message.detail.content
                }else if message.detail.content_type == "vocechat/file" {
                    if message.detail.properties.content_type == "image/jpeg" {
                        channels[index].content = "[图片]"
                    }else {
                        channels[index].content = "[文件]"
                    }
                }
                if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                    channels[index].unread = channels[index].unread + 1
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }else {
                let channel = VCChannelModel()
                channel.gid = message.target.gid
                channel.content = message.detail.content
                if message.detail.content_type == "text/plain" {
                    channel.content = message.detail.content
                }else if message.detail.content_type == "vocechat/file" {
                    if message.detail.properties.content_type == "image/jpeg" {
                        channel.content = "[图片]"
                    }else {
                        channel.content = "[文件]"
                    }
                }
                if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                    channel.unread = 1
                }
                channels.append(channel)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            if !isFromDB && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                unread = unread + 1
            }
            DispatchQueue.main.async {
                self.setBadgeValue(unread: self.unread)
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        VCManager.shared.getChannels { channels in
//            self.channels = channels
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                
//            }
//        } failure: { error in
//            //do nothing
//        }
    }

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ChatListCell", bundle: Bundle.main), forCellReuseIdentifier: NSStringFromClass(ChatListCell.classForCoder()))
        return tableView
    }()
    
    func setBadgeValue(unread: Int) {
        if unread == 0 {
            navigationController?.tabBarItem.badgeValue = nil
        }else{
            navigationController?.tabBarItem.badgeValue = "\(unread)"
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
    }

}

extension ChatsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return chats.count
        }
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ChatListCell.classForCoder()), for: indexPath) as! ChatListCell
        if indexPath.section == 0 {
            if indexPath.row < chats.count {
                cell.chat = chats[indexPath.row]
            }
        }else {
            if indexPath.row < channels.count {
                cell.channel = channels[indexPath.row]
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            setBadgeValue(unread: unread - chats[indexPath.row].unread)
            unread = unread - chats[indexPath.row].unread
            chats[indexPath.row].unread = 0
            
            let chatVC = ChatViewController()
            chatVC.chat = chats[indexPath.row]
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }else {
            setBadgeValue(unread: unread - channels[indexPath.row].unread)
            unread = unread - channels[indexPath.row].unread
            channels[indexPath.row].unread = 0
            
            let chatVC = ChatViewController()
            chatVC.channel = channels[indexPath.row]
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }
        UIApplication.shared.applicationIconBadgeNumber = unread
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}
