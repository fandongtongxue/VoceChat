//
//  MessageViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/26.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class MessageViewController: BaseViewController {
    
    var model = VCMessageModel()
    var messages = [VCMessageModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        requestData()
    }
    

    func requestData() {
        VCManager.shared.getHistoryMessage(uid: model.from_uid, limit: 100) { messages in
//            let reactions = messages.filter({ $0.detail.type == "reaction"})
            let normals = messages.filter({ $0.detail.type == "normal" })
            self.messages = self.messages + normals
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        } failure: { error in
            //do nothing
        }
    }
    
    func sendMsg(text: String) {
        VCManager.shared.sendMessage(uid: self.model.from_uid, msg: text, mid: messages.last?.mid ?? 0) { mid in
            let messageModel = VCMessageModel()
            messageModel.mid = mid
            messageModel.from_uid = VCManager.shared.currentUser()?.user.uid ?? 0
            messageModel.created_at = Int(Date().timeIntervalSince1970 * 1000)
            let target = VCMessageModelTarget()
            target.uid = self.model.from_uid
            messageModel.target = target
            let detail = VCMessageModelDetail()
            detail.type = "normal"
            detail.content = text
            detail.content_type = "text/plain"
            messageModel.detail = detail
            
            self.messages.append(messageModel)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        } failure: { error in
            //do nothing
        }

    }
    
    //键盘
    @objc func touchInside() {
        view.superview?.endEditing(true)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MessageTextCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(MessageTextCell.classForCoder()))
        tableView.register(MessageListCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(MessageListCell.classForCoder()))
        tableView.register(MessageImageCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(MessageImageCell.classForCoder()))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchInside))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
        return tableView
    } ()

}

extension MessageViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = messages[indexPath.row]
        if model.detail.content_type == "text/plain" {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MessageTextCell.classForCoder()), for: indexPath) as! MessageTextCell
            if indexPath.row < messages.count {
                cell.model = messages[indexPath.row]
            }
            return cell
        }else if model.detail.properties.content_type.contains("image/") {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MessageImageCell.classForCoder()), for: indexPath) as! MessageImageCell
            if indexPath.row < messages.count {
                cell.model = messages[indexPath.row]
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MessageListCell.classForCoder()), for: indexPath) as! MessageListCell
        if indexPath.row < messages.count {
            cell.model = messages[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = messages[indexPath.row]
        let user = VCManager.shared.getUserFromTable(uid: model.from_uid)
        let nameSize = (user.name as NSString).boundingRect(with: CGSize(width: .screenW / 2, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 17)], context: nil)
        if model.detail.content_type == "text/plain" {
            let textSize = (model.detail.content as NSString).boundingRect(with: CGSize(width: .screenW - 80, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 15)], context: nil).size
            return max(textSize.height + nameSize.height + 5 + 10 + 10 + 5, 62.0)
        }else if model.detail.properties.content_type.contains("image/") {
            let realImageHeight = CGFloat(model.detail.properties.height) * (.screenW - 80) / CGFloat(model.detail.properties.width)
            return max(realImageHeight / 3 + nameSize.height + 10 + 10 + 5, 62.0)
        }
        return 60
    }
    
    //键盘
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        view.superview?.endEditing(true)
        return indexPath
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.superview?.endEditing(true)
    }
    
}
