//
//  ProfileViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/16.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ProfileViewController: BaseViewController {
    
    var model = VCUserModel()
    var isDirectSend: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    private func requestData() {
        VCManager.shared.getUserFromServer(uid: model.uid) { user in
            self.model = user
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } failure: { error in
            self.view.makeToast("\(error)")
        }

    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(SettingListCell.classForCoder(), forCellReuseIdentifier: "SettingListCell")
        tableView.register(UINib(nibName: "SettingProfileCell", bundle: Bundle.main), forCellReuseIdentifier: "SettingProfileCell")
        tableView.sectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .init(top: .statusBarHeight + 10, left: 0, bottom: 0, right: 0)
        return tableView
    } ()

}

extension ProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileCell", for: indexPath) as! SettingProfileCell
            cell.editBtn.isHidden = true
            cell.model = model
            cell.avatarImgView.rx.tapGesture().when(.recognized).subscribe { element in
                debugPrint("cell.avatarImgView.rx.tapGesture().when(.recognized).subscribe")
                var fromView: UIView? = nil
                var items = [YYPhotoGroupItem]()
                let imgView = cell.avatarImgView
                let item = YYPhotoGroupItem()
                item.thumbView = imgView
                item.largeImageURL = URL(string: .ServerURL + .resource_avatar + "?uid=\(cell.model.uid)" + "&t=\(cell.model.avatar_updated_at)")!
                items.append(item)
                fromView = imgView
                let v = YYPhotoGroupView(groupItems: items)
                v?.present(fromImageView: fromView, toContainer: self.navigationController?.view, animated: true, completion: nil)
            }.disposed(by: disposeBag)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingListCell", for: indexPath)
        if isDirectSend {
            cell.textLabel?.text = NSLocalizedString("Send Message", comment: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.01 : 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 1 ? 20 : 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let chatVC = ChatViewController()
            let chat = VCMessageModel()
            chat.from_uid = model.uid
            chatVC.chat = chat
            chatVC.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}
