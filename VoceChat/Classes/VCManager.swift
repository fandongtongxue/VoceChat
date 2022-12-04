//
//  VoceChatManager.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import Alamofire

public class VCManager: NSObject {
    
    
    /// 服务器URL
    /// - Parameter serverUrl: 服务器URL
    public class func register(serverUrl: String) {
        UserDefaults.standard.set(serverUrl, forKey: .serverURLKey)
        UserDefaults.standard.synchronize()
        VCNetwork.get(url: .license, param: nil)
    }
    
    public class func login(email: String, password: String) {
        let credential = ["email":email,"password":password,"type":"password"]
        let device = UIDevice.current.model
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device])
    }
}
