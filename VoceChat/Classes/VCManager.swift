//
//  VoceChatManager.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import HandyJSON
import LDSwiftEventSource
import SQLite

public class VCManager: NSObject {
    
    public static let shared = VCManager()
    
    private var eventSource: EventSource?
    
    //用户表
    private var users: Table!
    private var messages: Table!
    private var db: Connection!
    
    //更新Token
    private var timer: Timer?
    
    // MARK: - 注册VoceChat服务
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
        
        //创建用户表
        createDb()
        getUsers { users in
            //do nothing
        } failure: { error in
            //do nothing
        }
        
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
    
    // MARK: - 服务器信息
    /// 获取当前服务器信息
    /// - Returns: 服务器信息
    public func serverInfo() -> VCOrganizationModel{
        let name = UserDefaults.standard.string(forKey: .nameKey)
        let desc = UserDefaults.standard.string(forKey: .descKey)
        let info = VCOrganizationModel()
        info.name = name ?? ""
        info.description = desc ?? ""
        return info
    }
    
    public func updateServerInfo(name: String?, desc: String?, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.postRaw(url: .admin_system_organization, param: ["name": name, "description": desc]) { result in
            success()
            UserDefaults.standard.set(name, forKey: .nameKey)
            UserDefaults.standard.set(desc, forKey: .descKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
        }
    }
    
    public func updateServerAvatar(image: UIImage, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.uploadAvatar(url: .admin_system_organization_logo, image: image) { result in
            success()
        } failure: { error in
            failure(error)
        }
        
    }
    
    // MARK: - 验证Email是否合法
    /// 验证Email是否合法
    /// - Parameters:
    ///   - email: Email
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func checkEmail(email: String?, success: @escaping ((Bool)->()), failure: @escaping ((Int)->())) {
        VCNetwork.getRaw(url: .user_check_email, param: ["email":email]) { result in
            success(result as? Bool ?? false)
        } failure: { error in
            failure(error)
        }
    }
    
    // MARK: - 登录注册相关
    /// 获取登录配置
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getLoginConfig(success: @escaping ((VCLoginConfigModel)->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .admin_login_config) { result in
            let resultDict = result as? NSDictionary
            let model = VCLoginConfigModel.deserialize(from: resultDict) ?? VCLoginConfigModel()
            success(model)
        } failure: { error in
            failure(error)
        }
    }
    
    
    /// Guest登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func loginGuest(success: @escaping ((VCLoginModel)->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .login_guest) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            success(model)
            debugPrint("登陆成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
            self.sse(token: model.token)
        } failure: { error in
            failure(error)
            debugPrint("登陆失败:\(error)")
        }
        
    }
    
    
    /// 登陆
    /// - Parameters:
    ///   - email: email
    ///   - password: 密码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func login(email: String?, password: String?, success: @escaping ((VCLoginModel)->()), failure: @escaping ((Int)->())) {
        let credential = ["email":email,"password":password,"type":"password"]
        //存储自动登录参数
        UserDefaults.standard.set(email, forKey: .emailKey)
        UserDefaults.standard.set(password, forKey: .passwordKey)
        UserDefaults.standard.synchronize()
        
        let device = UIDevice.current.model
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device, "device_token":"test"]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            debugPrint("登陆成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
            self.sse(token: model.token)
            success(model)
        } failure: { error in
            failure(error)
            debugPrint("登陆失败:\(error)")
        }
    }
    
    
    /// 自动登录
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func autoLogin(success: @escaping ((VCLoginModel)->()), failure: @escaping ((Int)->())) {
        let device = UIDevice.current.model
        let email = UserDefaults.standard.string(forKey: .emailKey)
        let password = UserDefaults.standard.string(forKey: .passwordKey)
        let credential = ["email":email,"password":password,"type":"password"]
        VCNetwork.post(url: .token_login, param: ["credential":credential, "device": device, "device_token":"test"]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            debugPrint("自动登陆成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
            self.sse(token: model.token)
            success(model)
        } failure: { error in
            failure(error)
            debugPrint("自动登陆失败:\(error)")
        }
    }
    
    
    /// 注册
    /// - Parameters:
    ///   - email: 邮箱
    ///   - password: 密码
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func register(email: String?, password: String?, success: @escaping ((VCLoginModel)->()), failure: @escaping ((Int)->())) {
        //存储自动登录参数
        UserDefaults.standard.set(email, forKey: .emailKey)
        UserDefaults.standard.set(password, forKey: .passwordKey)
        UserDefaults.standard.synchronize()
        
        let device = UIDevice.current.model
        let language = Locale.preferredLanguages.first
        VCNetwork.post(url: .user_register, param: ["email":email, "password":password, "device": device, "language": language]) { result in
            let model = VCLoginModel.deserialize(from: result as? NSDictionary) ?? VCLoginModel()
            debugPrint("注册成功")
            UserDefaults.standard.set(model.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
            self.sse(token: model.token)
            success(model)
        } failure: { error in
            failure(error)
            debugPrint("注册失败:\(error)")
        }
    }
    
    /// 是否登录
    /// - Returns: 结果
    public func isLogin() -> Bool {
        let dict = UserDefaults.standard.object(forKey: .userKey) as? NSDictionary
        let model = VCLoginModel.deserialize(from: dict)
        return model?.user.uid ?? 0 > 0
    }
    
    /// 退出登陆
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func logout(success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.getRaw(url: .token_logout) { result in
            debugPrint("退出登陆成功")
            success()
            self.eventSource?.stop()
            self.timer?.invalidate()
            self.timer = nil
            UserDefaults.standard.set([:], forKey: .userKey)
            UserDefaults.standard.synchronize()
            self.clearLocalData()
        } failure: { error in
            failure(error)
            debugPrint("退出登陆失败:\(error)")
        }
    }
    
    
    /// SEE监听
    /// - Parameter token: token
    private func sse(token: String?) {
        let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
        let mid = VCManager.shared.getLastMsg().mid
        let urlStr = serverURL + .user_events + "?api-key=" + (token ?? "")+"&after_mid=\(mid)"
        var config = EventSource.Config(handler: VCSSEEventHandler(), url: URL(string: urlStr)!)
        config.headers = ["x-api-key":token ?? ""]
        eventSource = EventSource(config: config)
        eventSource?.start()
        
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(VCManager.shared.currentUser()?.expired_in ?? 0), target: self, selector: #selector(renewToken), userInfo: nil, repeats: true)
    }
    
    @objc private func renewToken() {
        VCNetwork.post(url: .token_renew, param: ["token": VCManager.shared.currentUser()?.token, "refresh_token": VCManager.shared.currentUser()?.refresh_token]) { result in
            let model = VCLoginModel.deserialize(from: result as? [String: Any]) ?? VCLoginModel()
            let user = VCManager.shared.currentUser()
            user?.token = model.token
            user?.refresh_token = model.refresh_token
            UserDefaults.standard.set(user?.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            debugPrint("刷新Token失败")
        }
        
    }
    
    // MARK: - 数据库
    private func createDb() {
        do {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let path = paths.first ?? ""
            db = try Connection(path+"/db.sqlite3")
            
            createUserTable()
            createMessageTable()
        } catch {
            debugPrint("创建数据库失败:"+error.localizedDescription)
        }
    }
    // MARK: - 用户表
    private func createUserTable() {
        users = Table("users")
        let id = Expression<Int>("id")
        let name = Expression<String>("name")
        let avatar_updated_at = Expression<Int>("avatar_updated_at")
        
        do {
            try db.run(users.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(avatar_updated_at)
            })
        } catch {
            debugPrint("创建用户表失败:"+error.localizedDescription)
        }
    }
    
    private func insertUser(user: VCUserModel) {
        let id = Expression<Int>("id")
        let name = Expression<String>("name")
        let avatar_updated_at = Expression<Int>("avatar_updated_at")
        let insert = users.insert(name <- user.name, id <- user.uid, avatar_updated_at <- user.avatar_updated_at)
        do {
            _ = try db.run(insert)
        } catch {
            debugPrint("插入用户表失败:"+error.localizedDescription)
            updateUser(user: user)
        }
    }
    
    private func updateUser(user: VCUserModel) {
        let id = Expression<Int>("id")
        let name = Expression<String>("name")
        let avatar_updated_at = Expression<Int>("avatar_updated_at")
        let row = users.filter(id == user.uid)
        let update = row.update(name <- name.replace("\(row[name])", with: user.name), avatar_updated_at <- user.avatar_updated_at)
        do {
            _ = try db.run(update)
        } catch {
            debugPrint("更新用户表失败:"+error.localizedDescription)
        }
    }
    
    private func deleteUsers() {
        do {
            try db.run(users.delete())
        }catch{
            debugPrint("删除用户表失败:"+error.localizedDescription)
        }
        
    }
    
    public func getUserFromTable(uid: Int) -> VCUserModel {
        let id = Expression<Int>("id")
        let name = Expression<String>("name")
        let avatar_updated_at = Expression<Int>("avatar_updated_at")
        do {
            let users = try db.prepare(users.filter(id == uid))
            for user in users {
                let model = VCUserModel()
                model.uid = user[id]
                model.name = user[name]
                model.avatar_updated_at = user[avatar_updated_at]
                return model
            }
        } catch {
            debugPrint("从用户表查询用户失败:"+error.localizedDescription)
        }
        return VCUserModel()
    }
    
    // MARK: - 消息表
    private func createMessageTable() {
        messages = Table("messages")
        
        let id = Expression<Int>("id")
        let from_uid = Expression<Int>("from_uid")
        let mid = Expression<Int>("mid")
        let content = Expression<String>("content")
        let content_type = Expression<String>("content_type")
        let type = Expression<String>("type")
        let detail_content_type = Expression<String>("detail_content_type")
        let uid = Expression<Int>("uid")
        let created_at = Expression<Int>("created_at")
        let gid = Expression<Int>("gid")
        do {
            try db.run(messages.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(from_uid)
                t.column(mid)
                t.column(content)
                t.column(content_type)
                t.column(type)
                t.column(detail_content_type)
                t.column(uid)
                t.column(created_at)
                t.column(gid)
            })
        } catch {
            debugPrint("创建消息表失败:"+error.localizedDescription)
        }
    }
    
    public func insertMessage(message: VCMessageModel) {
        let id = Expression<Int>("id")
        let from_uid = Expression<Int>("from_uid")
        let mid = Expression<Int>("mid")
        let content = Expression<String>("content")
        let type = Expression<String>("type")
        let content_type = Expression<String>("content_type")
        let detail_content_type = Expression<String>("detail_content_type")
        let uid = Expression<Int>("uid")
        let created_at = Expression<Int>("created_at")
        let gid = Expression<Int>("gid")
        let insert = messages.insert(id <- message.mid, from_uid <- message.from_uid, mid <- message.mid, content <- message.detail.content, content_type <- message.detail.content_type, uid <- message.target.uid, created_at <- message.created_at, detail_content_type <- message.detail.properties.content_type, type <- message.detail.detail.type, gid <- message.target.gid)
        do {
            _ = try db.run(insert)
        } catch {
            debugPrint("插入消息表失败:"+error.localizedDescription)
        }
    }
    
    private func deleteMessages() {
        do {
            try db.run(messages.delete())
        }catch{
            debugPrint("删除消息表失败:"+error.localizedDescription)
        }
    }
    
    public func deleteMessage(message: VCMessageModel) {
        let from_uid = Expression<Int>("from_uid")
        let uid = Expression<Int>("uid")
        let gid = Expression<Int>("gid")
        
        let row = messages.filter(from_uid == message.from_uid && uid == message.target.uid && gid == message.target.gid)
        do {
            try db.run(row.delete())
        }catch {
            debugPrint("删除消息失败:"+error.localizedDescription)
        }
    }
    
    public func getLastMsg(touid: Int = 0, togid: Int = 0) -> VCMessageModel {
        do {
            
            let from_uid = Expression<Int>("from_uid")
            let mid = Expression<Int>("mid")
            let content = Expression<String>("content")
            let content_type = Expression<String>("content_type")
            let detail_content_type = Expression<String>("detail_content_type")
            let type = Expression<String>("type")
            let uid = Expression<Int>("uid")
            let created_at = Expression<Int>("created_at")
            let gid = Expression<Int>("gid")
            
            let is_from = touid == from_uid && VCManager.shared.currentUser()?.user.uid ?? 0 == uid
            let is_to = from_uid == VCManager.shared.currentUser()?.user.uid ?? 0 && touid == uid
            let is_gid = gid == togid
            var all = Array(try db.prepare(messages))
            if touid != 0 {
                all = Array(try db.prepare(messages.filter(is_from || is_to)))
            }
            if togid != 0 {
                all = Array(try db.prepare(messages.filter(is_gid)))
            }
            
            let message = all.last
            let model = VCMessageModel()
            
            model.from_uid = try message?.get(from_uid) ?? 0
            model.mid = try message?.get(mid) ?? 0
            model.created_at = try message?.get(created_at) ?? 0
            
            let detail = VCMessageModelDetail()
            detail.content = try message?.get(content) ?? ""
            detail.content_type = try message?.get(content_type) ?? ""
            detail.type = try message?.get(type) ?? ""
            
            let properties = VCMessageModelDetailProperties()
            properties.content_type = try message?.get(detail_content_type) ?? ""
            
            detail.properties = properties
            
            let target = VCMessageModelTarget()
            target.uid = try message?.get(uid) ?? 0
            target.gid = try message?.get(gid) ?? 0
            
            model.detail = detail
            model.target = target
            
            return model
            
        } catch {
            debugPrint("获取最后一条消息失败:"+error.localizedDescription)
        }
        return VCMessageModel()
    }
    
    public func getAllMsg() -> [VCMessageModel] {
        do {
            
            let from_uid = Expression<Int>("from_uid")
            let mid = Expression<Int>("mid")
            let content = Expression<String>("content")
            let content_type = Expression<String>("content_type")
            let detail_content_type = Expression<String>("detail_content_type")
            let uid = Expression<Int>("uid")
            let created_at = Expression<Int>("created_at")
            let gid = Expression<Int>("gid")
            
            let all = Array(try db.prepare(messages))
            var tempArray = [VCMessageModel]()
            for message in all {
                let model = VCMessageModel()
                
                model.from_uid = try message.get(from_uid)
                model.mid = try message.get(mid)
                model.created_at = try message.get(created_at)
                
                let detail = VCMessageModelDetail()
                detail.content = try message.get(content)
                detail.content_type = try message.get(content_type)
                
                let properties = VCMessageModelDetailProperties()
                properties.content_type = try message.get(detail_content_type)
                
                detail.properties = properties
                
                let target = VCMessageModelTarget()
                target.uid = try message.get(uid)
                target.gid = try message.get(gid)
                
                model.detail = detail
                model.target = target
                
                tempArray.append(model)
            }
            
            
            return tempArray
            
        } catch {
            debugPrint("获取最后一条消息失败:"+error.localizedDescription)
        }
        return [VCMessageModel]()
    }
    
    // MARK: - 用户操作
    /// 当前用户
    /// - Returns: 用户信息
    public func currentUser() -> VCLoginModel? {
        let dict = UserDefaults.standard.object(forKey: .userKey) as? NSDictionary
        let model = VCLoginModel.deserialize(from: dict)
        return model?.user.uid == 0 ? nil : model
    }
    
    public func deleteUser(success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.delete(url: .user_delete) { result in
            success()
            self.clearLocalData()
        } failure: { error in
            failure(error)
        }
    }
    
    public func clearLocalData() {
//        UserDefaults.standard.set("", forKey: .nameKey)
//        UserDefaults.standard.set("", forKey: .descKey)
//        UserDefaults.standard.set("", forKey: .serverURLKey)
        UserDefaults.standard.set([:], forKey: .userKey)
        UserDefaults.standard.set("", forKey: .emailKey)
        UserDefaults.standard.set("", forKey: .passwordKey)
        UserDefaults.standard.set(Data(), forKey: .cookieKey)
//        self.deleteUsers()
        self.deleteMessages()
    }
    
    public func updateUserName(name: String, success: @escaping ((VCUserModel)->()), failure: @escaping ((Int)->())) {
        VCNetwork.put(url: .user, param: ["name": name]) { result in
            guard let resultDict = result as? NSDictionary else { return }
            let model = VCUserModel.deserialize(from: resultDict) ?? VCUserModel()
            success(model)
            //更新本地存储
            let loginModel = VCManager.shared.currentUser()
            loginModel?.user.name = name
            UserDefaults.standard.set(loginModel?.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
        }
    }
    
    public func updateUserAvatar(image: UIImage, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.uploadAvatar(url: .user_avatar, image: image) { result in
            success()
            let loginModel = VCManager.shared.currentUser()
            loginModel?.user.avatar_updated_at = Int(Date().timeIntervalSince1970)
            UserDefaults.standard.set(loginModel?.toJSON(), forKey: .userKey)
            UserDefaults.standard.synchronize()
        } failure: { error in
            failure(error)
        }

    }
    
    
    /// 获取用户列表
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getUsers(success: @escaping (([VCUserModel])->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .user) { result in
            let resultArray = result as? [NSDictionary]
            var tempArray = [VCUserModel]()
            for item in resultArray ?? [] {
                let user = VCUserModel.deserialize(from: item) ?? VCUserModel()
                self.insertUser(user: user)
                tempArray.append(user)
            }
            success(tempArray)
            debugPrint("获取用户列表成功")
        } failure: { error in
            failure(error)
            debugPrint("获取用户列表失败:\(error)")
        }
        
    }
    
    public func getUserFromServer(uid: Int, success: @escaping ((VCUserModel)->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .user+"/\(uid)") { result in
            let resultDict = result as? NSDictionary
            let model = VCUserModel.deserialize(from: resultDict) ?? VCUserModel()
            success(model)
            debugPrint("获取用户成功")
        } failure: { error in
            failure(error)
            debugPrint("获取用户失败:\(error)")
        }

    }
    
    public func generateInviteLink(success: @escaping ((String)->()), failure: @escaping ((Int)->())) {
        VCNetwork.getRaw(url: .group_create_reg_magic_link, param: ["expired_in": 48 * 3600]) { result in
            let url = String(data: result as? Data ?? Data(), encoding: .utf8)
            success(url ?? "")
        } failure: { error in
            failure(error)
        }
    }
    
    // MARK: - 群组相关
    public func createChannel(name:String? = "", description: String? = "", is_public: Bool = false, members: [Int?] = [], success: @escaping ((Int)->()), failure: @escaping ((Int)->())) {
        VCNetwork.postRaw(url: .group, param: ["name": name, "description": description, "is_public": is_public, "members": members]) { result in
            success(result as? Int ?? 0)
        } failure: { error in
            failure(error)
        }

    }
    
    public func getChannels(success: @escaping (([VCChannelModel])->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .group) { result in
            let resultArray = result as? [NSDictionary]
            var tempArray = [VCChannelModel]()
            for item in resultArray ?? [] {
                let channel = VCChannelModel.deserialize(from: item) ?? VCChannelModel()
                tempArray.append(channel)
            }
            success(tempArray)
        } failure: { error in
            failure(error)
        }
    }
    
    public func getChannel(gid: Int, success: @escaping ((VCChannelModel)->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .group+"/\(gid)") { result in
            let resultDict = result as? NSDictionary
            let model = VCChannelModel.deserialize(from: resultDict) ?? VCChannelModel()
            success(model)
            debugPrint("获取群组成功")
        } failure: { error in
            failure(error)
            debugPrint("获取群组失败:\(error)")
        }

    }
    
    
    // MARK: - 消息相关
    
    /// 获取历史消息
    /// - Parameters:
    ///   - uid: 用户ID
    ///   - before: 之前的记录before
    ///   - limit: 限制数量
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func getHistoryMessage(uid: Int = 0, gid: Int = 0, before: Int = 0, limit: Int = 300, success: @escaping (([VCMessageModel])->()), failure: @escaping ((Int)->())) {
        var url = ""
        if uid > 0 {
            url = .user+"/\(uid)/history"
        }else if gid > 0 {
            url = .group+"/\(gid)/history"
        }
        VCNetwork.get(url: url) { result in
            let resultArray = result as? [NSDictionary]
            var tempArray = [VCMessageModel]()
            for item in resultArray ?? [] {
                tempArray.append(VCMessageModel.deserialize(from: item) ?? VCMessageModel())
            }
            success(tempArray)
            debugPrint("获取历史消息成功")
        } failure: { error in
            failure(error)
            debugPrint("获取历史消息失败:\(error)")
        }
    }
    
    
    /// 发送消息
    /// - Parameters:
    ///   - uid: 用户ID
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func sendMessage(uid: Int = 0, gid: Int = 0, msg: String? = nil, imageURL: URL? = nil, Content_Type:String, mid: Int, success: @escaping ((Int, VCUploadImageModel?)->()), failure: @escaping ((Int)->())) {
        var url = ""
        if uid > 0 {
            url = .user+"/\(uid)/send"
        }else if gid > 0 {
            url = .group+"/\(gid)/send"
        }
        if Content_Type == "text/plain" {
            VCNetwork.httpBody(url: url, method: .post, body: msg, Content_Type: Content_Type, mid: mid) { result in
                success(result as? Int ?? 0, nil)
            } failure: { error in
                failure(error)
            }
        }else if Content_Type == "image/jpeg" {
            VCNetwork.postRaw(url: .resource_file_prepare, param: ["content_type": "image/jpeg", "filename": "\(VCManager.shared.currentUser()?.user.uid)_\(Date().timeIntervalSince1970).jpg"]) { result in
                guard let resultData = result as? Data else { return }
                let file_id = String(data: resultData, encoding: .utf8)
                VCNetwork.uploadImage(url: .resource_file_upload, file_id: file_id!, imageURL: imageURL!) { result2 in
                    VCNetwork.httpBody(url: url,method: .post, body: result2.path, Content_Type: "vocechat/file", mid: mid) { result3 in
                        success(result as? Int ?? 0, result2)
                    } failure: { error in
                        failure(error)
                    }
                } failure: { error in
                    failure(error)
                }
            } failure: { error in
                failure(error)
            }

        }
    }
    
    public func deleteMessage(mid: Int, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.deleteRaw(url: .message+"/\(mid)") { result in
            success()
        } failure: { error in
            failure(error)
        }
    }
    
    // MARK: - APNS
    /// 注册推送Token
    /// - Parameters:
    ///   - device_token: DeviceToken
    ///   - success: 成功回调
    ///   - failure: 失败回调
    public func setDeviceToken(device_token: Data, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        let device_token_str = device_token.map { value in
            String(format: "%02.2hhx", [value])
        }.joined()
        debugPrint("当前DeviceToken:"+device_token_str)
        VCNetwork.put(url: .token_device_token, param: ["device_token":device_token_str]) { result in
            success()
            debugPrint("注册FCM成功")
        } failure: { error in
            debugPrint("注册FCM失败:\(error)")
            failure(error)
        }

    }
    
    // MARK: - 收藏相关
    public func getFavorites(success: @escaping (([VCFavoriteModel])->()), failure: @escaping ((Int)->())) {
        VCNetwork.get(url: .favorite) { result in
            let resultArray = result as? [[String: Any]]
            var tempArray = [VCFavoriteModel]()
            for dict in resultArray ?? [] {
                let model = VCFavoriteModel.deserialize(from: dict) ?? VCFavoriteModel()
                tempArray.append(model)
            }
            success(tempArray)
        } failure: { error in
            failure(error)
        }
    }
    
    public func createFavorite(mid: String, success: @escaping (()->()), failure: @escaping ((Int)->())) {
        VCNetwork.post(url: .favorite, param: ["mid_list": [mid]]) { result in
            success()
        } failure: { error in
            failure(error)
        }

    }
}
