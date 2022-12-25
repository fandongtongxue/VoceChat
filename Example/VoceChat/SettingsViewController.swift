//
//  SettingsViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/12.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class SettingsViewController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingListCell.classForCoder(), forCellReuseIdentifier: "SettingListCell")
        tableView.register(UINib(nibName: "SettingProfileCell", bundle: Bundle.main), forCellReuseIdentifier: "SettingProfileCell")
        return tableView
    } ()

}

extension SettingsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileCell", for: indexPath) as! SettingProfileCell
            cell.model = VCManager.shared.currentUser()?.user
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingListCell", for: indexPath)
        if indexPath.section == 1 {
            cell.textLabel?.text = NSLocalizedString("Favorite", comment: "")
        }else if indexPath.section == 2 {
            cell.textLabel?.text = NSLocalizedString("Log Out", comment: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            VCManager.shared.getFavorites { result in
                debugPrint(result)
            } failure: { error in
                self.view.makeToast(error)
            }
        }else if indexPath.section == 2{
            let alert = UIAlertController(title: NSLocalizedString("Log Out?", comment: ""), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { action in
                VCManager.shared.logout {
                    let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                    UIApplication.shared.keyWindow?.rootViewController = vc
                } failure: { error in
                    self.view.makeToast(error)
                }
            }))
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 160 + .statusBarHeight
        }
        return 40
    }
}
