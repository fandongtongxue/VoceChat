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
import QMUIKit

class InputBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5
        clipsToBounds = true
        backgroundColor = UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return .qmui_color(withHexString: "f8f8f8")!
            }
            return .systemGroupedBackground
        })
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
        addSubview(addBtn)
        addBtn.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(self.textView.snp.left)
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
        let sendBtn = UIButton.createBtn(image: UIImage(systemName: "paperplane.fill"))
        sendBtn.backgroundColor = UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return .qmui_color(withHexString: "f8f8f8")!
            }
            return .systemGroupedBackground
        })
        return sendBtn
    }()
    
    lazy var addBtn: UIButton = {
        let addBtn = UIButton.createBtn(image: UIImage(systemName: "plus"))
        addBtn.backgroundColor = UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .light {
                return .qmui_color(withHexString: "f8f8f8")!
            }
            return .systemGroupedBackground
        })
        return addBtn
    } ()

}
