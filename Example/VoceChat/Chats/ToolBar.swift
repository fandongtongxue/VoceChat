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

class ToolBar: UIToolbar {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let deleteItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAction))
        let forwardItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(forwardAction))
        setItems([deleteItem, forwardItem], animated: true)
    }
    
    @objc func deleteAction() {
        
    }
    
    @objc func forwardAction() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
