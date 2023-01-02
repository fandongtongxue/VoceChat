//
//  InputBar.swift
//  VoceChat_Example
//
//  Created by 范东 on 2022/12/27.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class InputBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGroupedBackground
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(44)
            make.right.equalToSuperview().offset(-44)
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
        }
        addSubview(sendBtn)
        sendBtn.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.left.equalTo(self.textView.snp.right)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textView: UITextView = {
        let textView = UITextView(frame: .zero)
        textView.font = .systemFont(ofSize: 16)
        return textView
    }()
    
    lazy var sendBtn: UIButton = {
        let sendBtn = UIButton.createBtn(title: NSLocalizedString("Send", comment: ""), titleColor: .systemBlue, font: .systemFont(ofSize: 16))
        sendBtn.backgroundColor = .systemGroupedBackground
        return sendBtn
    }()

}
