//
//  MessageTextCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/2.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat
import CDFInitialsAvatar
import SDWebImage

class MessageTextCell: MessageBubbleCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        bubbleView.addSubview(contentLabel)
    }
    
    public override var model : VCMessageModel!{
        set{
            _model = newValue
            super.model = newValue
            //设置数据
            contentLabel.text = model.detail.content
            if newValue.from_uid == VCManager.shared.currentUser()?.user.uid {
                contentLabel.snp.makeConstraints { make in
                    make.right.equalToSuperview().offset(-10)
                    make.bottom.equalToSuperview().offset(-11)
                    make.top.equalToSuperview().offset(15)
                    make.left.equalToSuperview().offset(10)
                }
            }else {
                contentLabel.snp.makeConstraints { make in
                    make.left.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(15)
                    make.bottom.equalToSuperview().offset(-11)
                    make.right.equalToSuperview().offset(-11)
                }
            }
        }
        get{
            return _model
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var contentLabel: UILabel = {
        let contentLabel = UILabel(frame: .zero)
        contentLabel.textColor = UIColor(dynamicProvider: { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return .white
            }
            return .darkText
        })
        contentLabel.font = .systemFont(ofSize: 15)
        contentLabel.numberOfLines = 0
        return contentLabel
    }()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
