//
//  VCMessageModel.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/14.
//

public class VCMessageModel: VCBaseModel {
    public var created_at: Int = 0
    public var detail = VCMessageModelDetail()
    public var from_uid: Int = 0
    public var mid: Int = 0
    public var target = VCMessageModelTarget()
    public var online: Bool = false
    public var unread: Int = 0
}

public class VCMessageModelTarget: VCBaseModel {
    public var uid: Int = 0
    public var gid: Int = 0
}

public class VCMessageModelDetail: VCBaseModel {
    public var content = ""
    public var content_type = ""
    public var expires_in: Int = 0
    public var properties = VCMessageModelDetailProperties()
    public var type = ""
    public var detail = VCMessageModelDetailDetail()
    public var mid: Int = 0
}

public class VCMessageModelDetailDetail: VCBaseModel {
    public var action = ""
    public var type = ""
}

public class VCMessageModelDetailProperties: VCBaseModel {
    public var cid = ""
    public var content_type = ""
    public var height: Int = 0
    public var name = ""
    public var size: Int = 0
    public var width: Int = 0
}
