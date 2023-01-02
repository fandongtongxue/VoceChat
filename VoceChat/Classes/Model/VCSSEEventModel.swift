//
//  VCSSEEventModel.swift
//
//
//  Created by JSONConverter on 2022/12/30.
//  Copyright © 2022年 JSONConverter. All rights reserved.
//

import Foundation

public extension String {
    static let ready = "ready"
    static let users_log = "users_log"
    static let users_state = "users_state"
    static let users_state_changed = "users_state_changed"
    static let user_settings = "user_settings"
    static let user_settings_changed = "user_settings_changed"
    static let related_groups = "related_groups"
    static let chat = "chat"
    static let kick = "kick"
    static let user_joined_group = "user_joined_group"
    static let user_leaved_group = "user_leaved_group"
    static let joined_group = "joined_group"
    static let kick_from_group = "kick_from_group"
    static let group_changed = "group_changed"
    static let pinned_message_updated = "pinned_message_updated"
    static let heartbeat = "heartbeat"
}

public class VCSSEEventModel: VCBaseModel {
	public var add_mute_groups = [VCSSEEventModelAdd_mute_groups]()
	public var add_mute_users = [VCSSEEventModelAdd_mute_users]()
	public var avatar_updated_at: Int = 0
	public var burn_after_reading_groups = [VCSSEEventModelBurn_after_reading_groups]()
	public var burn_after_reading_users = [VCSSEEventModelBurn_after_reading_users]()
	public var created_at: Int = 0
	public var description = ""
	public var detail = VCSSEEventModelDetail()
	public var from_device = ""
	public var from_uid: Int = 0
	public var gid: Int = 0
	public var group = VCSSEEventModelGroup()
	public var groups = [VCSSEEventModelGroups]()
	public var is_public: Bool = false
	public var logs = [VCSSEEventModelLogs]()
	public var mid: Int = 0
	public var msg = VCSSEEventModelMsg()
	public var mute_groups = [VCSSEEventModelMute_groups]()
	public var mute_users = [VCSSEEventModelMute_users]()
	public var name = ""
	public var online: Bool = false
	public var owner: Int = 0
	public var read_index_groups = [VCSSEEventModelRead_index_groups]()
	public var read_index_users = [VCSSEEventModelRead_index_users]()
	public var reason = ""
	public var remove_mute_groups = [Int]()
	public var remove_mute_users = [Int]()
	public var target = VCSSEEventModelTarget()
	public var time: Int = 0
    public var type = ""
    public var uid: Int = 0
	public var users = [VCSSEEventModelUsers]()
	public var version: Int = 0
}

public class VCSSEEventModelMute_groups: VCBaseModel {
	public var expired_at: Int = 0
	public var gid: Int = 0
}

public class VCSSEEventModelBurn_after_reading_users: VCBaseModel {
	public var expires_in: Int = 0
	public var uid: Int = 0
}

public class VCSSEEventModelMute_users: VCBaseModel {
	public var expired_at: Int = 0
	public var uid: Int = 0
}

public class VCSSEEventModelGroups: VCBaseModel {
	public var avatar_updated_at: Int = 0
	public var description = ""
	public var gid: Int = 0
	public var is_public: Bool = false
	public var members = [String]()
	public var name = ""
	public var owner: Int = 0
	public var pinned_messages = [VCSSEEventModelGroupsPinned_messages]()
}

public class VCSSEEventModelGroupsPinned_messages: VCBaseModel {
	public var content = ""
	public var content_type = ""
	public var created_at: Int = 0
	public var created_by: Int = 0
	public var mid: Int = 0
	public var properties = VCSSEEventModelGroupsPinned_messagesProperties()
}

public class VCSSEEventModelGroupsPinned_messagesProperties: VCBaseModel {
	public var additionalProp1 = ""
	public var additionalProp2 = ""
	public var additionalProp3 = ""
}

public class VCSSEEventModelBurn_after_reading_groups: VCBaseModel {
	public var expires_in: Int = 0
	public var gid: Int = 0
}

public class VCSSEEventModelMsg: VCBaseModel {
	public var content = ""
	public var content_type = ""
	public var created_at: Int = 0
	public var created_by: Int = 0
	public var mid: Int = 0
	public var properties = VCSSEEventModelMsgProperties()
}

public class VCSSEEventModelMsgProperties: VCBaseModel {
	public var additionalProp1 = ""
	public var additionalProp2 = ""
	public var additionalProp3 = ""
}

public class VCSSEEventModelRead_index_users: VCBaseModel {
	public var mid: Int = 0
	public var uid: Int = 0
}

public class VCSSEEventModelAdd_mute_users: VCBaseModel {
	public var expired_at: Int = 0
	public var uid: Int = 0
}

public class VCSSEEventModelGroup: VCBaseModel {
	public var avatar_updated_at: Int = 0
	public var description = ""
	public var gid: Int = 0
	public var is_public: Bool = false
	public var members = [String]()
	public var name = ""
	public var owner: Int = 0
	public var pinned_messages = [VCSSEEventModelGroupPinned_messages]()
}

public class VCSSEEventModelGroupPinned_messages: VCBaseModel {
	public var content = ""
	public var content_type = ""
	public var created_at: Int = 0
	public var created_by: Int = 0
	public var mid: Int = 0
	public var properties = VCSSEEventModelGroupPinned_messagesProperties()
}

public class VCSSEEventModelGroupPinned_messagesProperties: VCBaseModel {
	public var additionalProp1 = ""
	public var additionalProp2 = ""
	public var additionalProp3 = ""
}

public class VCSSEEventModelTarget: VCBaseModel {
	public var uid: Int = 0
}

public class VCSSEEventModelDetail: VCBaseModel {
	public var content = ""
	public var content_type = ""
	public var expires_in: Int = 0
	public var properties = VCSSEEventModelDetailProperties()
	public var type = ""
}

public class VCSSEEventModelDetailProperties: VCBaseModel {
	public var additionalProp1 = ""
	public var additionalProp2 = ""
	public var additionalProp3 = ""
}

public class VCSSEEventModelRead_index_groups: VCBaseModel {
	public var gid: Int = 0
	public var mid: Int = 0
}

public class VCSSEEventModelAdd_mute_groups: VCBaseModel {
	public var expired_at: Int = 0
	public var gid: Int = 0
}

public class VCSSEEventModelLogs: VCBaseModel {
	public var action = ""
	public var avatar_updated_at: Int = 0
	public var email = ""
	public var gender: Int = 0
	public var is_admin: Bool = false
	public var language = ""
	public var log_id: Int = 0
	public var name = ""
	public var uid: Int = 0
}

public class VCSSEEventModelUsers: VCBaseModel {
	public var avatar_updated_at: Int = 0
	public var create_by = ""
	public var email = ""
	public var gender: Int = 0
	public var is_admin: Bool = false
	public var language = ""
	public var name = ""
	public var uid: Int = 0
    public var online: Bool = false
}
