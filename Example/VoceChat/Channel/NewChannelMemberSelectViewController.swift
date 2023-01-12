//
//  ContactsViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import SnapKit
import RxCocoa
import RxSwift

class NewChannelMemberSelectViewController: BaseViewController {
    
    var name = ""
    var desc = ""
    
    lazy var searchRC : ContactsSearchResultViewController = {
        let searchRC = ContactsSearchResultViewController()
        searchRC.nav = navigationController
//        searchRC.delegate = self
        return searchRC
    }()
    
    lazy var searchC : UISearchController = {
        let searchC = UISearchController(searchResultsController: searchRC)
        searchC.searchBar.delegate = searchRC
        searchC.searchResultsUpdater = searchRC
        searchC.delegate = self
        searchC.view.addSubview(searchRC.view)
        return searchC
    }()
    
    var users = [VCUserModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.title = NSLocalizedString("Create New Private Channel", comment: "")
        navigationItem.searchController = searchC
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableView.setEditing(true, animated: true)
        //在线状态改变通知
        NotificationCenter.default.rx.notification(.users_state_changed)
            .subscribe { noti in
                let model = noti.element?.object as! VCSSEEventModel
                let filter_users = self.users.filter { user in
                    user.uid == model.uid
                }
                filter_users.first?.online = model.online
                let index = self.users.firstIndex { user in
                    user.uid == model.uid
                } ?? 0
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                }
            }
            .disposed(by: disposeBag)
        //在线状态通知
        NotificationCenter.default.rx.notification(.user_state)
            .subscribe { noti in
                let model = noti.element?.object as! VCSSEEventModel
                for xuser in model.users {
                    for yuser in self.users {
                        if xuser.uid == yuser.uid {
                            yuser.online = xuser.online
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }.disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestData()
    }
    
    @objc func doneAction() {
        let indexPaths = tableView.indexPathsForSelectedRows?.map({ indexPath in
            return indexPath.row
        }) ?? []
        VCManager.shared.createChannel(name: name, description: desc, is_public: false, members: indexPaths) { result in
            self.dismiss(animated: true)
        } failure: { error in
            self.view.makeToast("\(error)")
        }
    }

    func requestData() {
        VCManager.shared.getUsers { users in
            self.users = users
            guard let json = UserDefaults.standard.string(forKey: .users_state) else {
                self.searchRC.dataArray = users
                self.tableView.reloadData()
                return
            }
            let model = VCSSEEventModel.deserialize(from: json) ?? VCSSEEventModel()
            for xuser in model.users {
                for yuser in self.users {
                    if xuser.uid == yuser.uid {
                        yuser.online = xuser.online
                    }
                }
            }
            self.searchRC.dataArray = self.users
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let index = self.users.firstIndex(where: { $0.uid == VCManager.shared.currentUser()?.user.uid }) ?? 0
                self.tableView.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .none)
            }
        } failure: { error in
            //do nothing
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ContactListCell", bundle: Bundle.main), forCellReuseIdentifier: NSStringFromClass(ContactListCell.classForCoder()))
        return tableView
    } ()

}

extension NewChannelMemberSelectViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(ContactListCell.classForCoder()), for: indexPath) as! ContactListCell
        if indexPath.row < users.count {
            cell.model = users[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        UITableViewCellEditingStyle(rawValue: UITableViewCellEditingStyle.delete.rawValue | UITableViewCellEditingStyle.insert.rawValue)!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let index = self.users.firstIndex(where: { $0.uid == VCManager.shared.currentUser()?.user.uid }) ?? 0
        return indexPath.row != index
    }
    
}


extension NewChannelMemberSelectViewController : UISearchControllerDelegate{
    
}
