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
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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

extension SettingsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        VCManager.shared.currentUser()?.user.is_admin ?? false ? 6 : 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingProfileCell", for: indexPath) as! SettingProfileCell
            cell.model = VCManager.shared.currentUser()?.user
            cell.editBtn.rx.controlEvent(.touchUpInside).subscribe(onNext: {
                let editVC = ProfileEditViewController()
                editVC.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(editVC, animated: true)
            }).disposed(by: disposeBag)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingListCell", for: indexPath)
        if indexPath.section == 1 {
            cell.textLabel?.text = NSLocalizedString("Overview", comment: "")
        }else if indexPath.section == 2 {
            cell.textLabel?.text = NSLocalizedString("Language", comment: "")
        }else if indexPath.section == 3 {
            cell.textLabel?.text = NSLocalizedString("About", comment: "")
        }else if indexPath.section == 4 {
            cell.textLabel?.text = NSLocalizedString("Log Out", comment: "")
        }else if indexPath.section == 5 {
            cell.textLabel?.text = NSLocalizedString("Clear Local Data", comment: "")
        }else if indexPath.section == 6 {
            cell.textLabel?.text = NSLocalizedString("Delete Account", comment: "")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let editVC = OrganizationEditViewController()
            editVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(editVC, animated: true)
        }else if indexPath.section == 2{
            guard let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                return
            }
            UIApplication.shared.open(url)
        }else if indexPath.section == 4{
            let alert = UIAlertController(title: NSLocalizedString("Log Out?", comment: ""), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { action in
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
                VCManager.shared.logout {
                    
                } failure: { error in
                    if error == 401 {
                        self.view.makeToast(NSLocalizedString("Illegal token", comment: ""))
                    }
                }
            }))
            present(alert, animated: true)
        }else if indexPath.section == 5 {
            
        }else if indexPath.section == 6{
            let alert = UIAlertController(title: NSLocalizedString("Delete Account?", comment: ""), message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: { action in
                let vc = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
                UIApplication.shared.keyWindow?.rootViewController = vc
                VCManager.shared.deleteUser {
                    
                } failure: { error in
                    
                }
            }))
            present(alert, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 || section == 2 ? 0.01 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        section == 1 ? 30 : 0.01
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? NSLocalizedString("Server info set", comment: "") : ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        section == 1 ? NSLocalizedString("Please use pc manage members", comment: "") : ""
    }
}
