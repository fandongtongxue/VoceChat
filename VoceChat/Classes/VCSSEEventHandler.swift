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
        
    }
    
    func onComment(comment: String) {
        debugPrint("onComment:\(comment)")
    }
    
    func onError(error: Error) {
        debugPrint("onError:\(error.localizedDescription)")
    }
}
