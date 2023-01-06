//
//  VCUploadImageModel.swift
//  VoceChat
//
//  Created by 范东 on 2023/1/6.
//

import UIKit

class VCUploadImageModel: VCBaseModel {
    var hash = ""
    var image_properties = VCUploadImageModelImage_properties()
    var path = ""
    var size: Int = 0
}

class VCUploadImageModelImage_properties: VCBaseModel {
    var height: Int = 0
    var width: Int = 0
}

