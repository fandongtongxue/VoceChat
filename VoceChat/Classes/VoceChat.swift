//
//  VoceChat.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation

extension String {
    //存储相关
    static let serverURLKey = "serverURLKey"
    
    //API
    static let api = "/api"
    static let license = api+"/license"
    static let license_check = api+"/license/check"
    
    static let token_login = api+"/token/login"
}
