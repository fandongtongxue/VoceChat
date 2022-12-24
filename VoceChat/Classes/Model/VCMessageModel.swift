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
}

public class VCMessageModelTarget: VCBaseModel {
    public var uid: Int = 0
}

public class VCMessageModelDetail: VCBaseModel {
    public var content = ""
    public var content_type = ""
    public var expires_in: Int = 0
    public var properties = VCMessageModelDetailProperties()
    public var type = ""
}

public class VCMessageModelDetailProperties: VCBaseModel {
    public var additionalProp1 = ""
    public var additionalProp2 = ""
    public var additionalProp3 = ""
}
