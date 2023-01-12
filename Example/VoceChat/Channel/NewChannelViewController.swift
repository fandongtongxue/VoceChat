//
//  NewChannelViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/4.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class NewChannelViewController: BaseViewController {
    
    @IBOutlet private weak var nameTF: UITextField!
    @IBOutlet private weak var descTV: UITextView!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet private weak var privateSwitch: UISwitch!
    @IBOutlet private weak var privateTipLabel: UILabel!
    @IBOutlet private weak var lockImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemGroupedBackground
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 44))
        nameTF.leftView = leftView
        nameTF.leftViewMode = .always
        
        descTV.textContainerInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let ret = VCManager.shared.currentUser()?.user.is_admin ?? false
        privateView.isHidden = !ret
        privateTipLabel.isHidden = !ret
        
        privateSwitch.rx.isOn.subscribe { value in
            self.nameTF.placeholder = value ? NSLocalizedString("New Private Channel", comment: "") : NSLocalizedString("New Public Channel", comment: "")
            self.privateTipLabel.text = value ? NSLocalizedString("Only designated users can view this channel, and only administrators can create public channels", comment: "") : NSLocalizedString("All users can view this channel. Only administrators can create public channels", comment: "")
            self.lockImgView.isHidden = !value
            self.navigationItem.rightBarButtonItem = value ? UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .plain, target: self, action: #selector(self.nextAction)) : UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction))
        }.disposed(by: disposeBag)
        
        navigationItem.title = NSLocalizedString("Create Channel", comment: "")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeAction))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Next", comment: ""), style: .plain, target: self, action: #selector(nextAction))
    }
    
    @objc private func closeAction() {
        dismiss(animated: true)
    }
    
    @objc private func nextAction() {
        let selectVC = NewChannelMemberSelectViewController()
        selectVC.name = (nameTF.text?.count ?? 0 > 0) ? nameTF.text! : NSLocalizedString("New Private Channel", comment: "")
        selectVC.desc = descTV.text ?? ""
        navigationController?.pushViewController(selectVC, animated: true)
    }
    
    @objc private func doneAction() {
        VCManager.shared.createChannel(name: nameTF.text?.count ?? 0 > 0 ? nameTF.text : "新公有频道", description: descTV.text, is_public: true) { result in
            self.dismiss(animated: true)
        } failure: { error in
            //do nothing
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
