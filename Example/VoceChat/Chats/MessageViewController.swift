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
    
    var model = VCUserModel()
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
        VCManager.shared.getHistoryMessage(uid: model.uid, limit: 100) { messages in
            self.messages = self.messages + messages
            self.tableView.reloadData()
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
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MessageListCell.classForCoder()), for: indexPath) as! MessageListCell
        if indexPath.row < messages.count {
            cell.model = messages[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = messages[indexPath.row]
        if model.detail.content_type == "text/plain" {
            let textSize = (model.detail.content as NSString).boundingRect(with: CGSize(width: .screenW - 80, height: CGFloat(MAXFLOAT)), attributes: [.font: UIFont.systemFont(ofSize: 14)], context: nil).size
            return max(textSize.height + 20.33 + 5 + 10 + 10, 60)
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
