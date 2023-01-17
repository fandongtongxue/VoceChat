//
//  MessageBubbleCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/17.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class MessageBubbleCell: MessageListCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        containerView.addSubview(bubbleView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var model : VCMessageModel!{
        set{
            _model = newValue
            super.model = newValue
            //设置数据
            if newValue.from_uid == VCManager.shared.currentUser()?.user.uid {
                bubbleView.image = UIImage(named: "SenderTextNodeBkg")?.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 10, bottom: 11, right: 10), resizingMode: .stretch)
                bubbleView.snp.makeConstraints { make in
                    make.right.top.bottom.equalToSuperview()
                    make.left.greaterThanOrEqualToSuperview()
                }
            }else {
                bubbleView.image = UIImage(named: "ReceiverTextNodeBkg")?.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 11, bottom: 11, right: 11), resizingMode: .stretch)
                bubbleView.snp.makeConstraints { make in
                    make.left.top.bottom.equalToSuperview()
                    make.right.lessThanOrEqualToSuperview()
                }
            }
        }
        get{
            return _model
        }
    }
    
    lazy var bubbleView: UIImageView = {
        let bubbleView = UIImageView(frame: .zero)
        bubbleView.isUserInteractionEnabled = true
        return bubbleView
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
