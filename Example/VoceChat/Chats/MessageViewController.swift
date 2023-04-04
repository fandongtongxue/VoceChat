//
//  MessageViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/26.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import QMUIKit
import RxGesture

class MessageViewController: BaseViewController {
    
    var chat = VCMessageModel()
    var channel = VCChannelModel()
    var messages = [VCMessageModel]()
    
    var images = [VCMessageModel]()
    var imageCellIndexs = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        requestData()
        NotificationCenter.default.rx.notification(.chat).subscribe { noti in
            let jsonString = noti.element?.object as? String
            let message = VCMessageModel.deserialize(from: jsonString) ?? VCMessageModel()
            if (message.from_uid == self.chat.from_uid && self.channel.gid == 0) || self.channel.gid > 0 && message.from_uid != VCManager.shared.currentUser()?.user.uid {
                self.messages.append(message)
                if message.detail.properties.content_type == "image/jpeg" {
                    self.images = self.images + [message]
                    self.imageCellIndexs.append(self.messages.count - 1)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.tableView.scrollToRow(at: IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : self.messages.count, section: 0), at: .bottom, animated: true)
                }
            }
        }.disposed(by: disposeBag)
    }
    

    func requestData() {
        VCManager.shared.getHistoryMessage(uid: chat.from_uid, gid: channel.gid, limit: 100) { messages in
            let normals = messages.filter({ $0.detail.type == "normal" })
            let images = messages.filter({ $0.detail.properties.content_type == "image/jpeg" })
            self.images = self.images + images
            for image in self.images {
                let index = normals.firstIndex(where: { $0.mid == image.mid }) ?? 0
                self.imageCellIndexs.append(index)
            }
            self.messages = self.messages + normals
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.tableView.scrollToRow(at: IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : 0, section: 0), at: .bottom, animated: true)
            }
        } failure: { error in
            //do nothing
        }
    }
    
    func sendTextMsg(text: String) {
        VCManager.shared.sendMessage(uid: chat.from_uid, gid: channel.gid, msg: text, Content_Type: "text/plain", mid: messages.last?.mid ?? 0) { mid, imageModel in
            let messageModel = VCMessageModel()
            messageModel.mid = mid
            messageModel.from_uid = VCManager.shared.currentUser()?.user.uid ?? 0
            messageModel.created_at = Int(Date().timeIntervalSince1970 * 1000)
            let target = VCMessageModelTarget()
            target.uid = self.chat.from_uid
            target.gid = self.channel.gid
            messageModel.target = target
            let detail = VCMessageModelDetail()
            detail.type = "normal"
            detail.content = text
            detail.content_type = "text/plain"
            messageModel.detail = detail
            
            self.messages.append(messageModel)
            self.tableView.reloadData()
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : self.messages.count, section: 0), at: .bottom, animated: true)
            let sender_avatar = .ServerURL + "/api/avatar?uid=\(VCManager.shared.currentUser()?.user.uid ?? 0)&t=\(VCManager.shared.currentUser()?.user.avatar_updated_at ?? 0)"
            let url = "https://vocechat.xiaobingkj.com/jpush-api-php-client/examples/push_example.php?message=\(text)&sender=\(VCManager.shared.currentUser()?.user.name ?? "")&touid=\(self.chat.from_uid)&sender_avatar=\(sender_avatar)&sender_uid=\(VCManager.shared.currentUser()?.user.uid ?? 0)"
            guard let pushURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
            URLSession.shared.dataTask(with: pushURL) { data, response, error in
                debugPrint(response)
            }.resume()
        } failure: { error in
            //do nothing
        }
    }
    
    func sendImageMsg(imageURL: URL) {
        VCManager.shared.sendMessage(uid: chat.from_uid, gid: channel.gid, imageURL: imageURL, Content_Type: "image/jpeg", mid: messages.last?.mid ?? 0) { mid, imageModel in
            let messageModel = VCMessageModel()
            messageModel.mid = mid
            messageModel.from_uid = VCManager.shared.currentUser()?.user.uid ?? 0
            messageModel.created_at = Int(Date().timeIntervalSince1970 * 1000)
            let target = VCMessageModelTarget()
            target.uid = self.chat.from_uid
            target.gid = self.channel.gid
            messageModel.target = target
            let detail = VCMessageModelDetail()
            detail.type = "normal"
            detail.content = imageModel?.path ?? ""
            detail.content_type = "vocechat/file"
            
            let properties = VCMessageModelDetailProperties()
            properties.content_type = "image/jpeg"
            properties.width = imageModel?.image_properties.width ?? 0
            properties.height = imageModel?.image_properties.height ?? 0
            properties.size = imageModel?.size ?? 0
            detail.properties = properties
            
            messageModel.detail = detail
            
            self.messages.append(messageModel)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : self.messages.count, section: 0)], with: .automatic)
            self.tableView.scrollToRow(at: IndexPath(row: self.messages.count > 0 ? self.messages.count - 1 : self.messages.count, section: 0), at: .bottom, animated: true)
            let url = "https://vocechat.xiaobingkj.com/jpush-api-php-client/examples/push_example.php?message=\("[图片]")&sender=\(VCManager.shared.currentUser()?.user.name ?? "")&touid=\(self.chat.from_uid)"
            guard let pushURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
            URLSession.shared.dataTask(with: pushURL) { data, response, error in
                debugPrint(response)
            }.resume()
        } failure: { error in
            self.view.makeToast("\(error)")
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
    
    func clickImage(cell: MessageImageCell) {
        var fromView: UIView? = nil
        var items = [YYPhotoGroupItem]()
        let index = images.firstIndex(where: { $0.mid == cell.model.mid })
        for i in 0..<images.count {
            let model = images[i]
            let currentCell = tableView.cellForRow(at: IndexPath(row: imageCellIndexs[i], section: 0)) as! MessageImageCell
            
            let imgView = currentCell.imgView
            let item = YYPhotoGroupItem()
            item.thumbView = imgView
            item.largeImageURL = URL(string: .ServerURL + .resource_file + "?file_path=" + model.detail.content + "&thumbnail=" + "false")!
            item.largeImageSize = CGSize(width: model.detail.properties.width, height: model.detail.properties.height)
            items.append(item)
            if i == index {
                fromView = imgView
            }
        }
        let v = YYPhotoGroupView(groupItems: items)
        v?.present(fromImageView: fromView, toContainer: navigationController?.view, animated: true, completion: nil)
    }

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
            cell.contentLabel.rx.longPressGesture().when(.began).subscribe { element in
                debugPrint("长按了文本消息")
            }.disposed(by: cell.disposeBag)
            return cell
        }else if model.detail.properties.content_type.contains("image/") {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(MessageImageCell.classForCoder()), for: indexPath) as! MessageImageCell
            if indexPath.row < messages.count {
                cell.model = messages[indexPath.row]
            }
            cell.imgView.rx.tapGesture().when(.recognized).subscribe { element in
                debugPrint("点击了图片消息")
                self.clickImage(cell: cell)
            }.disposed(by: cell.disposeBag)
            cell.imgView.rx.longPressGesture().when(.began).subscribe { element in
                debugPrint("长按了图片消息")
            }.disposed(by: cell.disposeBag)
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
            return max(textSize.height + nameSize.height + 5 + 10 + 10 + 5 + 26, 62.0)
        }else if model.detail.properties.content_type.contains("image/") {
            let realImageHeight = CGFloat(model.detail.properties.height) * (.screenW - 80) / CGFloat(model.detail.properties.width)
            return max(realImageHeight / 3 + nameSize.height + 10 + 10 + 5, 62.0)
        }
        return 60
    }
    
    //Edit
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        UITableViewCellEditingStyle(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue)!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(actionProvider:  { (element) -> UIMenu? in
            let reply = UIAction(title: NSLocalizedString("Reply", comment: ""), image: UIImage(systemName: "arrowshape.turn.up.left")) { action in
                //do reply
            }
            let copy = UIAction(title: NSLocalizedString("Copy", comment: ""), image: UIImage(systemName: "doc.on.doc")) { action in
                //do copy
                let cell = tableView.cellForRow(at: indexPath) as! MessageListCell
                if cell.isKind(of: MessageTextCell.classForCoder()) {
                    let newCell = cell as! MessageTextCell
                    UIPasteboard.general.string = newCell.contentLabel.text
                }
            }
            let save = UIAction(title: NSLocalizedString("Save", comment: ""), image: UIImage(systemName: "square.and.arrow.down.fill")) { action in
                //do save
            }
            let forward = UIAction(title: NSLocalizedString("Forward", comment: ""), image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                //do forward
            }
            let select = UIAction(title: NSLocalizedString("Select", comment: ""), image: UIImage(systemName: "checkmark.circle.fill")) { action in
                //do select
                self.tableView.setEditing(true, animated: true)
            }
            let delete = UIAction(title: NSLocalizedString("Delete", comment: ""), image: UIImage(systemName: "trash"), attributes: [.destructive], state: .off) { action in
                //do delete
                let cell = tableView.cellForRow(at: indexPath) as! MessageListCell
                VCManager.shared.deleteMessage(mid: cell.model.mid) {
                    self.messages.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                } failure: { error in
                    self.view.makeToast("\(error)")
                }
            }
            let deleteMenu = UIMenu(title: "", options: .displayInline, children: [delete])
            return UIMenu(title: "", children: [reply, copy, save, forward, select, deleteMenu])
        })
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
