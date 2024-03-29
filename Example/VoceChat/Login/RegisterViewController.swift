//
//  RegisterViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import QMUIKit
import RxCocoa
import RxSwift

class RegisterViewController: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var remSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameLabel.text = VCManager.shared.serverInfo().name
        serverLabel.text = .ServerURL
        
        signUpBtn.setBackgroundImage(.qmui_image(with: .systemGray), for: .disabled)
        signUpBtn.setBackgroundImage(.qmui_image(with: .systemBlue), for: .normal)
        
        let emailValid = emailTF.rx.text.orEmpty.map{ self.checkEmail(email: $0) }.share(replay: 1)
        let passValid = passTF.rx.text.orEmpty.map{ $0.count >= 6 }.share(replay: 1)
        let confirmPassValid = confirmTF.rx.text.orEmpty.map{ $0.count >= 6 }.share(replay: 1)
        
        let everythingValid = Observable.combineLatest(emailValid, passValid, confirmPassValid) { $0 && $1 && $2 }
            .share(replay: 1)
        everythingValid.bind(to: signUpBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        
        signUpBtn.rx.tap.subscribe(onNext: {
            self.view.endEditing(true)
            if self.remSwitch.isOn {
                UserDefaults.standard.set(self.emailTF.text, forKey: .user_email_key)
                UserDefaults.standard.set(self.passTF.text, forKey: .user_pass_key)
                UserDefaults.standard.synchronize()
            }
            VCManager.shared.register(email: self.emailTF.text, password: self.passTF.text) { result in
                debugPrint("推送用户ID:\(VCManager.shared.currentUser()?.user.uid ?? 0)")
                JPUSHService.setAlias("\(VCManager.shared.currentUser()?.user.uid ?? 0)", completion: { iResCode, iAlias, seq in
                    debugPrint("设置Alias code:\(iResCode)")
                }, seq: Int(Date().timeIntervalSince1970))
                
                let tabC = TabBarController()
                UIApplication.shared.keyWindow?.rootViewController = tabC
            } failure: { error in
                var errorStr = ""
                switch error {
                case 409:
                    errorStr = NSLocalizedString("name_conflict", comment: "")
                    break
                case 412:
                    errorStr = NSLocalizedString("Magic token has been expired.", comment: "")
                    break
                default:
                    errorStr = NSLocalizedString("Unknown reason", comment: "")
                    break
                }
                self.view.makeToast(errorStr)
            }
        }).disposed(by: disposeBag)
    }
    
    func checkEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func closeBtnAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        signUpBtn.isEnabled = emailTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0 && passTF.text == confirmTF.text
    }

}
