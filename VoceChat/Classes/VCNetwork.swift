//
//  VCNetwork.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/4.
//

import Foundation
import Alamofire
import Toast_Swift

class VCNetwork: NSObject {
    class func get(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .get, param: param, success: success, failure: failure)
    }
    
    class func post(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .post, param: param, success: success, failure: failure)
    }
    
    class func put(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .put, param: param, success: success, failure: failure)
    }
    
    class func delete(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        http(url: url, method: .delete, param: param, success: success, failure: failure)
    }
    
    class func getRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        httpRaw(url: url, method: .get, param: param, success: success, failure: failure)
    }
    
    class func postRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        httpRaw(url: url, method: .post, param: param, success: success, failure: failure)
    }
    
    class func putRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        httpRaw(url: url, method: .put, param: param, success: success, failure: failure)
    }
    
    class func deleteRaw(url: String , param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        httpRaw(url: url, method: .delete, param: param, success: success, failure: failure)
    }
    
    private class func http(url: String, method: HTTPMethod = .get, param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newParam: Parameters? = param
            newParam?["api-key"] = VCManager.shared.currentUser()?.token
            AF.request(serverURL + url, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["X-API-Key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let result):
                    success(result)
                    break
                case .failure(let error):
                    failure(error.errorDescription ?? "")
                    UIApplication.shared.keyWindow?.makeToast(error.errorDescription)
                    break
                }
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
        
    }
    
    private class func httpRaw(url: String, method: HTTPMethod = .get, param: Parameters? = nil, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newParam: Parameters? = param
            newParam?["api-key"] = VCManager.shared.currentUser()?.token
            AF.request(serverURL + url, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["X-API-Key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).responseData { response in
                switch response.result {
                case .success(let result):
                    success(result)
                    break
                case .failure(let error):
                    failure(error.errorDescription ?? "")
                    UIApplication.shared.keyWindow?.makeToast(error.errorDescription)
                    break
                }
            }
        }else {
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("No network", comment: ""))
        }
        
    }
    
    class func cookieLoad() {
        let data = UserDefaults.standard.object(forKey: .cookieKey)
        if data != nil {
            let cookieData = NSKeyedUnarchiver.unarchiveObject(with: data as! Data)
            guard let cookies = cookieData as? [HTTPCookie] else{
                return
            }
            let cookieStorage = HTTPCookieStorage.shared
            for cookie in cookies {
                cookieStorage.setCookie(cookie)
            }
        }
    }
}
