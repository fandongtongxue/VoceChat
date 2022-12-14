//
//  VCMessageModel.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/14.
//

public class VCMessageModel: VCBaseModel {
    public var created_at: Int = 0
    public var detail: VCMessageModelDetail?
    public var from_uid: Int = 0
    public var mid: Int = 0
    public var target: VCMessageModelTarget?
}

public class VCMessageModelTarget: VCBaseModel {
    public var uid: Int = 0
}

public class VCMessageModelDetail: VCBaseModel {
    public var content: String?
    public var content_type: String?
    public var expires_in: Int = 0
    public var properties: VCMessageModelDetailProperties?
    public var type: String?
}

public class VCMessageModelDetailProperties: VCBaseModel {
    public var additionalProp1: String?
    public var additionalProp2: String?
    public var additionalProp3: String?
}
