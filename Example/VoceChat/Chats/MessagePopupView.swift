//
//  MessagePopupView.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/12.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import QMUIKit

class MessagePopupView: QMUIPopupContainerView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBlue
        layer.cornerRadius = 5
        clipsToBounds = true
        
        contentEdgeInsets = .zero
        arrowImage = UIImage(named: "popover_container_arrow")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(inContentView size: CGSize) -> CGSize {
        CGSize(width: 300, height: 232)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
