//
//  ChannelInfoViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/16.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ChannelInfoViewController: BaseViewController {

    var model = VCChannelModel()
    var titles = [["Pinned", "Saved Messages"],["Auto Delete Message"], ["Members"], ["Public Channel"], ["Delete Channel"], ["Leave Channel"]]
    
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
        VCManager.shared.getChannel(gid: model.gid) { channel in
            self.model = channel
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
        tableView.register(UINib(nibName: "ChannelProfileCell", bundle: Bundle.main), forCellReuseIdentifier: "ChannelProfileCell")
        tableView.sectionFooterHeight = 0
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentInset = .init(top: .statusBarHeight + 10, left: 0, bottom: 0, right: 0)
        return tableView
    } ()

}

extension ChannelInfoViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if model.is_public {
            return 6
        }
        return 7
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 1 ? 2 : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelProfileCell", for: indexPath) as! ChannelProfileCell
            cell.model = model
            cell.editBtn.rx.tap.subscribe { element in
                debugPrint("点击了编辑按钮")
            }.disposed(by: disposeBag)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingListCell", for: indexPath)
        cell.textLabel?.text = NSLocalizedString(titles[indexPath.section - 1][indexPath.row], comment: "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 140
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.01 : 20
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
