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
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append(param?[key] as? String ?? "")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            AF.request(newUrl, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["X-API-Key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).responseJSON { responseJSON in
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
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append(param?[key] as? String ?? "")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            AF.request(newUrl, method: method, parameters: newParam,  encoding: JSONEncoding.default, headers: ["X-API-Key":VCManager.shared.currentUser()?.token ?? "", "Referer":serverURL+"/"]).response { response in
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
    
    public class func httpBody(url: String, method: HTTPMethod = .get, param: Parameters? = nil, body: String?, success: @escaping ((Any)->()), failure: @escaping ((String)->())){
        if NetworkReachabilityManager()?.isReachable ?? false {
            cookieLoad()
            let serverURL = UserDefaults.standard.string(forKey: .serverURLKey) ?? ""
            var newUrl = serverURL + url
            var newParam: Parameters? = nil
            if method == .get {
                if VCManager.shared.currentUser()?.token.count ?? 0 > 0 {
                    newUrl.append("?api-key=")
                    newUrl.append(VCManager.shared.currentUser()?.token ?? "")
                }
                param?.keys.forEach({ key in
                    newUrl.append("&")
                    newUrl.append(key)
                    newUrl.append("=")
                    newUrl.append(param?[key] as? String ?? "")
                })
            }else{
                newParam = param
                newParam?["api-key"] = VCManager.shared.currentUser()?.token
            }
            do {
                var request = try URLRequest(url: newUrl, method: method)
                request.setValue(VCManager.shared.currentUser()?.token, forHTTPHeaderField: "X-API-Key")
                request.setValue(serverURL+"/", forHTTPHeaderField: "Referer")
                
                request.httpBody = body?.data(using: .utf8)
                AF.request(request).response { response in
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
            } catch {
                failure(error.localizedDescription)
                UIApplication.shared.keyWindow?.makeToast(error.localizedDescription)
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
