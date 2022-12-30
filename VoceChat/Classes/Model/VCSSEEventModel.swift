//
//  VCSSEEventModel.swift
//
//
//  Created by JSONConverter on 2022/12/30.
//  Copyright © 2022年 JSONConverter. All rights reserved.
//

import Foundation

class VCSSEEventModel: VCBaseModel {
	var add_mute_groups = [VCSSEEventModelAdd_mute_groups]()
	var add_mute_users = [VCSSEEventModelAdd_mute_users]()
	var avatar_updated_at: Int = 0
	var burn_after_reading_groups = [VCSSEEventModelBurn_after_reading_groups]()
	var burn_after_reading_users = [VCSSEEventModelBurn_after_reading_users]()
	var created_at: Int = 0
	var description = ""
	var detail = VCSSEEventModelDetail()
	var from_device = ""
	var from_uid: Int = 0
	var gid: Int = 0
	var group = VCSSEEventModelGroup()
	var groups = [VCSSEEventModelGroups]()
	var is_public: Bool = false
	var logs = [VCSSEEventModelLogs]()
	var mid: Int = 0
	var msg = VCSSEEventModelMsg()
	var mute_groups = [VCSSEEventModelMute_groups]()
	var mute_users = [VCSSEEventModelMute_users]()
	var name = ""
	var online: Bool = false
	var owner: Int = 0
	var read_index_groups = [VCSSEEventModelRead_index_groups]()
	var read_index_users = [VCSSEEventModelRead_index_users]()
	var reason = ""
	var remove_mute_groups = [Int]()
	var remove_mute_users = [Int]()
	var target = VCSSEEventModelTarget()
	var time: Int = 0
	var type = ""
	var uid = [Int]()
	var users = [VCSSEEventModelUsers]()
	var version: Int = 0
}

class VCSSEEventModelMute_groups: VCBaseModel {
	var expired_at: Int = 0
	var gid: Int = 0
}

class VCSSEEventModelBurn_after_reading_users: VCBaseModel {
	var expires_in: Int = 0
	var uid: Int = 0
}

class VCSSEEventModelMute_users: VCBaseModel {
	var expired_at: Int = 0
	var uid: Int = 0
}

class VCSSEEventModelGroups: VCBaseModel {
	var avatar_updated_at: Int = 0
	var description = ""
	var gid: Int = 0
	var is_public: Bool = false
	var members = [String]()
	var name = ""
	var owner: Int = 0
	var pinned_messages = [VCSSEEventModelGroupsPinned_messages]()
}

class VCSSEEventModelGroupsPinned_messages: VCBaseModel {
	var content = ""
	var content_type = ""
	var created_at: Int = 0
	var created_by: Int = 0
	var mid: Int = 0
	var properties = VCSSEEventModelGroupsPinned_messagesProperties()
}

class VCSSEEventModelGroupsPinned_messagesProperties: VCBaseModel {
	var additionalProp1 = ""
	var additionalProp2 = ""
	var additionalProp3 = ""
}

class VCSSEEventModelBurn_after_reading_groups: VCBaseModel {
	var expires_in: Int = 0
	var gid: Int = 0
}

class VCSSEEventModelMsg: VCBaseModel {
	var content = ""
	var content_type = ""
	var created_at: Int = 0
	var created_by: Int = 0
	var mid: Int = 0
	var properties = VCSSEEventModelMsgProperties()
}

class VCSSEEventModelMsgProperties: VCBaseModel {
	var additionalProp1 = ""
	var additionalProp2 = ""
	var additionalProp3 = ""
}

class VCSSEEventModelRead_index_users: VCBaseModel {
	var mid: Int = 0
	var uid: Int = 0
}

class VCSSEEventModelAdd_mute_users: VCBaseModel {
	var expired_at: Int = 0
	var uid: Int = 0
}

class VCSSEEventModelGroup: VCBaseModel {
	var avatar_updated_at: Int = 0
	var description = ""
	var gid: Int = 0
	var is_public: Bool = false
	var members = [String]()
	var name = ""
	var owner: Int = 0
	var pinned_messages = [VCSSEEventModelGroupPinned_messages]()
}

class VCSSEEventModelGroupPinned_messages: VCBaseModel {
	var content = ""
	var content_type = ""
	var created_at: Int = 0
	var created_by: Int = 0
	var mid: Int = 0
	var properties = VCSSEEventModelGroupPinned_messagesProperties()
}

class VCSSEEventModelGroupPinned_messagesProperties: VCBaseModel {
	var additionalProp1 = ""
	var additionalProp2 = ""
	var additionalProp3 = ""
}

class VCSSEEventModelTarget: VCBaseModel {
	var uid: Int = 0
}

class VCSSEEventModelDetail: VCBaseModel {
	var content = ""
	var content_type = ""
	var expires_in: Int = 0
	var properties = VCSSEEventModelDetailProperties()
	var type = ""
}

class VCSSEEventModelDetailProperties: VCBaseModel {
	var additionalProp1 = ""
	var additionalProp2 = ""
	var additionalProp3 = ""
}

class VCSSEEventModelRead_index_groups: VCBaseModel {
	var gid: Int = 0
	var mid: Int = 0
}

class VCSSEEventModelAdd_mute_groups: VCBaseModel {
	var expired_at: Int = 0
	var gid: Int = 0
}

class VCSSEEventModelLogs: VCBaseModel {
	var action = ""
	var avatar_updated_at: Int = 0
	var email = ""
	var gender: Int = 0
	var is_admin: Bool = false
	var language = ""
	var log_id: Int = 0
	var name = ""
	var uid: Int = 0
}

class VCSSEEventModelUsers: VCBaseModel {
	var avatar_updated_at: Int = 0
	var create_by = ""
	var email = ""
	var gender: Int = 0
	var is_admin: Bool = false
	var language = ""
	var name = ""
	var uid: Int = 0
}
