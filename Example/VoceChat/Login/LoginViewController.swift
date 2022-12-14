//
//  ViewController.swift
//  VoceChat
//
//  Created by 范东同学 on 12/04/2022.
//  Copyright (c) 2022 范东同学. All rights reserved.
//

import UIKit
import VoceChat
import RxSwift
import RxCocoa
import QMUIKit

class LoginViewController: BaseViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serverLabel: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpView: UIView!
    @IBOutlet weak var inviteLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        serverLabel.text = .ServerURL
        VCManager.shared.getLoginConfig { config in
            self.nameLabel.text = VCManager.shared.serverInfo().name
            let ret = config.who_can_sign_up == "EveryOne"
            self.signUpView.isHidden = !ret
            self.inviteLabel.isHidden = ret
        } failure: { error in
            //do nothing
        }
        
        loginBtn.setBackgroundImage(.qmui_image(with: .systemGray), for: .disabled)
        loginBtn.setBackgroundImage(.qmui_image(with: .systemBlue), for: .normal)
        
        let emailValid = emailTF.rx.text.orEmpty.map{ self.checkEmail(email: $0) }.share(replay: 1)
        let passValid = passTF.rx.text.orEmpty.map{ $0.count >= 6 }.share(replay: 1)
        
        let everythingValid = Observable.combineLatest(emailValid, passValid) { $0 && $1 }
            .share(replay: 1)
        everythingValid.bind(to: loginBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginBtn.rx.tap.subscribe(onNext: {
            self.view.endEditing(true)
            VCManager.shared.login(email: self.emailTF.text, password: self.passTF.text) { result in
                //do nothing
                let tabC = TabBarController()
                UIApplication.shared.keyWindow?.rootViewController = tabC
            } failure: { error in
                var errorStr = ""
                switch error {
                case 401:
                    errorStr = NSLocalizedString("Invalid account or password", comment: "")
                    break
                case 403:
                    errorStr = NSLocalizedString("Login method does not supported", comment: "")
                    break
                case 404:
                    errorStr = NSLocalizedString("User does not exists", comment: "")
                    break
                case 409:
                    errorStr = NSLocalizedString("Email collision", comment: "")
                    break
                case 410:
                    errorStr = NSLocalizedString("Account not associated", comment: "")
                    break
                case 423:
                    errorStr = NSLocalizedString("User has been frozen", comment: "")
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
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        loginBtn.isEnabled = emailTF.text?.count ?? 0 > 0 && passTF.text?.count ?? 0 > 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

