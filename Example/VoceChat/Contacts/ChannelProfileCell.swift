//
//  ChannelProfileCell.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/16.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import VoceChat

class ChannelProfileCell: UITableViewCell {

    @IBOutlet weak var lockImgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var editBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    var _model : VCChannelModel!
    public var model : VCChannelModel!{
        set{
            _model = newValue
            //设置数据
            nameLabel.text = newValue.name
            lockImgView.isHidden = newValue.is_public
            editBtn.isHidden = newValue.owner != VCManager.shared.currentUser()?.user.uid
        }
        get{
            return _model
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
