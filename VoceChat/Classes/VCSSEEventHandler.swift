//
//  VCSSSEventHandler.swift
//  VoceChat
//
//  Created by 范东 on 2022/12/30.
//

import LDSwiftEventSource

struct VCSSEEventHandler: EventHandler {
    func onOpened() {
        debugPrint("SSE Connected")
    }
    
    func onClosed() {
        debugPrint("SSE Disconnected")
    }
    
    func onMessage(eventType: String, messageEvent: MessageEvent) {
        debugPrint("eventType:\(eventType) messageEvent:\(messageEvent.data) lastEventId:\(messageEvent.lastEventId)")
        let model = VCSSEEventModel.deserialize(from: messageEvent.data) ?? VCSSEEventModel()
//        debugPrint("事件类型:" + model.type)
        switch model.type {
        case .heartbeat:
            debugPrint("心跳")
            break
        case .users_state:
            UserDefaults.standard.setValue(model.toJSONString(), forKey: .users_state)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .user_state, object: model)
            break
        case .user_state_changed:
            
            break
        case .chat:
            NotificationCenter.default.post(name: .chat, object: messageEvent.data)
            break
        default:
            break
            //do nothing
        }
    }
    
    func onComment(comment: String) {
//        debugPrint("onComment:\(comment)")
    }
    
    func onError(error: Error) {
        debugPrint("onError:\(error.localizedDescription)")
    }
}
