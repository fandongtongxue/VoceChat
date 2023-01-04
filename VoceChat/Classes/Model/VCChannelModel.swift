//
//  VCChannelModel.swift
//  VoceChat
//
//  Created by 范东 on 2023/1/4.
//

import Foundation

public class VCChannelModel: VCBaseModel {
    public var avatar_updated_at: Int = 0
    public var description = ""
    public var gid: Int = 0
    public var is_public: Bool = false
    public var members = [String]()
    public var name = ""
    public var owner: Int = 0
    public var pinned_messages = [VCChannelModelPinned_messages]()
}

public class VCChannelModelPinned_messages: VCBaseModel {
    public var content = ""
    public var content_type = ""
    public var created_at: Int = 0
    public var created_by: Int = 0
    public var mid: Int = 0
    public var properties = VCChannelModelPinned_messagesProperties()
}

public class VCChannelModelPinned_messagesProperties: VCBaseModel {
    public var additionalProp1 = ""
    public var additionalProp2 = ""
    public var additionalProp3 = ""
}
