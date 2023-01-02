//
//  ChatViewController.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/26.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import RxCocoa
import RxSwift

class ChatViewController: BaseViewController {
    
    var messageVC: MessageViewController!
    var model = VCUserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let user = VCManager.shared.getUserFromTable(uid: model.uid)
        navigationItem.title = user.name
        
        messageVC = MessageViewController()
        messageVC.model = model
        view.addSubview(messageVC.view)
        messageVC.view.frame = CGRect(x: 0, y: 0, width: .screenW, height: .screenH - .tabBarHeight)
        addChildViewController(messageVC)
        
        view.addSubview(inputBar)
        
        NotificationCenter.default.rx.notification(.UIKeyboardWillShow)
            .subscribe { noti in
                let userInfo = noti.element?.userInfo
                let keyboardFrame = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
                let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                let keyboardH = keyboardFrame.height
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.inputBar.frame.origin.y = .screenH - keyboardH - self.inputBar.bounds.height
                }
            }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(.UIKeyboardWillHide)
            .subscribe { noti in
                let userInfo = noti.element?.userInfo
                let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                UIView.animate(withDuration: TimeInterval(duration)) {
                    self.inputBar.frame.origin.y = .screenH - self.inputBar.bounds.height - .safeAreaBottomHeight
                }
            }
            .disposed(by: disposeBag)
        
        inputBar.textView.rx.text.orEmpty.asObservable()
            .subscribe(onNext: { text in
                let size = self.inputBar.textView.contentSize
                let currentBarHeight = self.inputBar.bounds.height
                var futureBarHeight = max(size.height + 10, .tabBarHeight - .safeAreaBottomHeight)
                if futureBarHeight >= 100 {
                    futureBarHeight = min(futureBarHeight, 100)
                }
                let compareHeight = currentBarHeight > futureBarHeight ? currentBarHeight - futureBarHeight : futureBarHeight - currentBarHeight
                self.inputBar.frame = CGRect(x: 0, y: self.inputBar.frame.minY - compareHeight, width: self.inputBar.bounds.width, height: futureBarHeight)
            })
            .disposed(by: disposeBag)
        
        inputBar.sendBtn.rx.tap.subscribe(onNext: {
            debugPrint("点击了发送消息")
        })
        .disposed(by: disposeBag)
    }
    
    
    lazy var inputBar: InputBar = {
        let inputBar = InputBar(frame: CGRect(x: 0, y: .screenH - .tabBarHeight, width: .screenW, height: .tabBarHeight - .safeAreaBottomHeight))
        return inputBar
    }()
    
}
