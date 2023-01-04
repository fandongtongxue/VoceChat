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
    var chat = VCMessageModel()
    var channel = VCChannelModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        navigationItem.title = user.name
        let titleView = TitleView(frame: CGRect(x: 0, y: 0, width: .screenW - 88, height: .navigationBarHeight))
        if chat.from_uid > 0 {
            titleView.chat = chat
        }else if channel.gid > 0 {
            titleView.channel = channel
        }
        navigationItem.titleView = titleView
        
        messageVC = MessageViewController()
        messageVC.model = chat
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
                    self.messageVC.view.frame.origin.y = -keyboardH + .safeAreaBottomHeight
                }
            }
            .disposed(by: disposeBag)
        NotificationCenter.default.rx.notification(.UIKeyboardWillHide)
            .subscribe { noti in
                let userInfo = noti.element?.userInfo
                let duration = (userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).floatValue
                UIView.animate(withDuration: TimeInterval(duration)) {
                    if self.inputBar.textView.text.count == 0 {
                        self.inputBar.bounds.size.height = .tabBarHeight - .safeAreaBottomHeight
                    }
                    self.inputBar.frame.origin.y = .screenH - self.inputBar.bounds.height - .safeAreaBottomHeight
                    self.messageVC.view.frame.origin.y = 0
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
                self.inputBar.frame = CGRect(x: 10, y: self.inputBar.frame.minY - compareHeight, width: self.inputBar.bounds.width, height: futureBarHeight)
            })
            .disposed(by: disposeBag)
        
        let sendAble = inputBar.textView.rx.text.orEmpty.map{ $0.count > 0 }.share(replay: 1)
        sendAble.bind(to: inputBar.sendBtn.rx.isEnabled)
            .disposed(by: disposeBag)
        
        inputBar.sendBtn.rx.tap.subscribe(onNext: {
            self.messageVC.sendMsg(text: self.inputBar.textView.text)
            self.inputBar.textView.text = ""
            self.inputBar.textView.resignFirstResponder()
        })
        .disposed(by: disposeBag)
    }
    
    
    lazy var inputBar: InputBar = {
        let inputBar = InputBar(frame: CGRect(x:10, y: .screenH - .tabBarHeight, width: .screenW - 20, height: .tabBarHeight - .safeAreaBottomHeight))
        return inputBar
    }()
    
}
