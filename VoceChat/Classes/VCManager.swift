//
//  VoceChatManager.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import HandyJSON
import IKEventSource

public class VCManager: NSObject {
    
    public static let shared = VCManager()
    
    private var eventSource: EventSource?
    
    /// 服务器URL
    /// - Parameter serverUrl: 服务器URL
    public func register(serverUrl: String) {
        guard serverUrl.count > 0 else {
            UIApplication.shared.keyWindow?.makeToast("VoceChat服务器URL为空")
            return
        }
        //存储服务器URL
        UserDefaults.standard.set(serverUrl, forKey: .serverURLKey)
        UserDefaults.standard.synchronize()
        //获取系统组织信息
        VCNetwork.get(url: .system_organization) { result in
            let info = VCOrganizationModel.deserialize(from: result as? NSDictionary) ?? VCOrganizationModel()
            UserDefaults.standard.set(info.name, forKey: .nameKey)
            UserDefaults.standard.set(info.description, forKey: .descKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            debugPrint(error)
        }
    }
    
    
    /// 获取当前服务器信息
    /// - Returns: 服务器信息
    public func serverInfo() -> VCOrganizationModel{
        let name = UserDefaults.standard.string(forKey: .nameKey)
        let desc = UserDefaults.standard.string(forKey: .descKey)
        let serverURL = UserDefaults.standard.string(forKey: .serverURLKey)
        let info = VCOrganizationModel()
        info.name = name ?? ""
        info.description = desc ?? ""
        info.serverURL = serverURL ?? ""
        return info
    }
    
    
    /// 获取登录配置
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getLoginConfig(success: @escaping ((VCLoginConfigModel)->()), failure: @escaping ((String)->())) {
        VCNetwork.get(url: .admin_login_config) { result in
            let resultDict = result as? NSDictionary
            let model = VCLoginConfigModel.deserialize(from: resultDict) ?? VCLoginConfigModel()
            success(model)
        } failure: { error in
            failure(error)
        }
    }
    
    
    /// 登陆
    /// - Parameters:
    ///   - email: email
    ///   - password: 密码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func login(email: String?, password: String?, success: @escaping ((VCLoginModel)->()), failure: @escaping ((String)->())) {
        let credential = ["email":email,"password":password,"type":"password"]
        let device = UIDevice.current.model
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            success(model)
            self.sse(token: model.token)
            debugPrint("登陆成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
            debugPrint("登陆失败:"+error)
        }
    }
    
    public func register(email: String?, password: String?, success: @escaping ((VCLoginModel)->()), failure: @escaping ((String)->())) {
        let device = UIDevice.current.model
        let language = Locale.preferredLanguages.first
        VCNetwork.post(url: .user_register, param: ["email":email, "password":password, "device": device, "language": language]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            success(model)
            self.sse(token: model.token)
            debugPrint("注册成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
            debugPrint("注册失败:"+error)
        }

    }
    
    public func sse(token: String?) {
        //SSE
        eventSource = EventSource(url: URL(string: VCManager.shared.serverInfo().serverURL)!, headers: ["X-API-Key":VCManager.shared.currentUser()?.token ?? ""])
        eventSource?.onOpen {
            debugPrint("SSE Connected")
        }
        eventSource?.onComplete({ statusCode, reconnect, error in
            debugPrint("SSE Disconnected")
            let retryTime = self.eventSource?.retryTime ?? 3000
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(retryTime), execute: DispatchWorkItem(block: {
                self.eventSource?.connect()
            }))
        })
        eventSource?.onMessage({ id, event, data in
            debugPrint("收到消息:id:\(id) event:\(event) data:\(data)")
        })
        eventSource?.addEventListener("users_state", handler: { id, event, data in
            debugPrint("收到users_state事件:id:\(id) event:\(event) data:\(data)")
        })
    }
    
    
    /// 是否登录
    /// - Returns: 结果
    public func isLogin() -> Bool {
        let dict = UserDefaults.standard.object(forKey: .userKey) as? NSDictionary
        let model = VCLoginModel.deserialize(from: dict)
        return model?.user.uid ?? 0 > 0
    }
    
    
    /// 当前用户
    /// - Returns: 用户信息
    public func currentUser() -> VCLoginModel? {
        let dict = UserDefaults.standard.object(forKey: .userKey) as? NSDictionary
        let model = VCLoginModel.deserialize(from: dict)
        return model?.user.uid == 0 ? nil : model
    }
    
    
    /// 退出登陆
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func logout(success: @escaping (()->()), failure: @escaping ((String)->())) {
        VCNetwork.post(url: .token_logout) { result in
            debugPrint("退出登陆成功")
            success()
            UserDefaults.standard.set([:], forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
            debugPrint("退出登陆失败:"+error)
        }
    }
    
    
    /// 获取用户列表
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getUsers(success: @escaping (([VCUserModel])->()), failure: @escaping ((String)->())) {
        VCNetwork.get(url: .user) { result in
            let resultArray = result as? [NSDictionary]
            var tempArray = [VCUserModel]()
            for item in resultArray ?? [] {
                tempArray.append(VCUserModel.deserialize(from: item) ?? VCUserModel())
            }
            success(tempArray)
            debugPrint("获取用户列表成功")
        } failure: { error in
            failure(error)
            debugPrint("获取用户列表失败:"+error)
        }
    }
    
    
    /// 获取历史消息
    /// - Parameters:
    ///   - uid: 用户ID
    ///   - before: 之前的记录before
    ///   - limit: 限制数量
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getHistoryMessage(uid: String, before: Int = 0, limit: Int = 300, success: @escaping (([VCMessageModel])->()), failure: @escaping ((String)->())) {
        VCNetwork.get(url: .user+"/"+uid+"/history") { result in
            let resultArray = result as? [NSDictionary]
            var tempArray = [VCMessageModel]()
            for item in resultArray ?? [] {
                tempArray.append(VCMessageModel.deserialize(from: item) ?? VCMessageModel())
            }
            success(tempArray)
            debugPrint("获取历史消息成功")
        } failure: { error in
            failure(error)
            debugPrint("获取历史消息失败:"+error)
        }
    }
    
    
    public func sendMessage(uid: String, success: @escaping (()->()), failure: @escaping ((String)->())) {
        VCNetwork.post(url: .user+"/"+uid+"/send") { result in
            debugPrint("发送消息成功")
        } failure: { error in
            failure(error)
            debugPrint("发送消息失败:"+error)
        }
    }
    
    
    /// 注册推送Token
    /// - Parameters:
    ///   - device_token: DeviceToken
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func setDeviceToken(device_token: Data, success: @escaping (()->()), failure: @escaping ((String)->())) {
        let device_token_str = device_token.map { value in
            String(format: "%02.2hhx", [value])
        }.joined()
        debugPrint("当前DeviceToken:"+device_token_str)
        VCNetwork.put(url: .token_device_token, param: ["device_token":device_token_str]) { result in
            success()
            debugPrint("注册FCM成功")
        } failure: { error in
            debugPrint("注册FCM失败:"+error)
            failure(error)
        }

    }
}
