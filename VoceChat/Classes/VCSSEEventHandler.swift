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
        switch model.type {
        case .heartbeat:
            debugPrint("心跳")
            break
        case .users_state:
            UserDefaults.standard.setValue(model.toJSONString(), forKey: .users_state)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .user_state, object: model)
            break
        case .users_state_changed:
            NotificationCenter.default.post(name: .users_state_changed, object: model)
            break
        case .chat:
            NotificationCenter.default.post(name: .chat, object: messageEvent.data)
            break
        case .ready:
            NotificationCenter.default.post(name: .ready, object: nil)
            break
        case .kick:
            NotificationCenter.default.post(name: .kick, object: nil)
            break
        case .joined_group:
            NotificationCenter.default.post(name: .joined_group, object: model)
            break
        case .related_groups:
            NotificationCenter.default.post(name: .related_groups, object: model)
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
