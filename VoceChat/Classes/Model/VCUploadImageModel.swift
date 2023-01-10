//
//  VCUploadImageModel.swift
//  VoceChat
//
//  Created by 范东 on 2023/1/6.
//

import UIKit

public class VCUploadImageModel: VCBaseModel {
    public var hash = ""
    public var image_properties = VCUploadImageModelImage_properties()
    public var path = ""
    public var size: Int = 0
}

public class VCUploadImageModelImage_properties: VCBaseModel {
    public var height: Int = 0
    public var width: Int = 0
}

