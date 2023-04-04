//
//  NotificationService.swift
//  VoceChat_PushServiceExtension
//
//  Created by 范东 on 2023/4/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UserNotifications
import SDWebImage
import Intents

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
            debugPrint("bestAttemptContent.userInfo:\(bestAttemptContent.userInfo)")
            guard let extrasInfo = bestAttemptContent.userInfo as? [String: Any] else { return }
            debugPrint("extrasInfo:\(extrasInfo)")
            guard let fromAvatar = extrasInfo["sender_avatar"] as? String, let fromUserName = extrasInfo["sender"] as? String, let fromUserId = extrasInfo["sender_uid"] as? String else { return }
            debugPrint("fromAvatar:\(fromAvatar)")
            guard let url = URL(string: fromAvatar.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? fromAvatar) else { return }
            debugPrint("url:\(url)")
            let messageId = fromUserId+"\(Date().timeIntervalSince1970)"
            SDWebImageDownloader.shared.downloadImage(with: url) { image, data, error, ret in
                var nameCom = PersonNameComponents()
                nameCom.nickname = fromUserName
                if data != nil {
                    if #available(iOSApplicationExtension 15.0, *) {
                        let avatarImage = INImage(imageData: data!)
                        let sender = INPerson(personHandle: INPersonHandle(value: nil, type: .unknown), nameComponents: nameCom, displayName: fromUserName, image: avatarImage, contactIdentifier: nil, customIdentifier: fromUserName, isMe: false, suggestionType: .none)
                        let intent = INSendMessageIntent(recipients: [sender], outgoingMessageType: .outgoingMessageText, content: bestAttemptContent.body, speakableGroupName: INSpeakableString(spokenPhrase: ""), conversationIdentifier: messageId, serviceName: nil, sender: sender, attachments: nil)
                        intent.setImage(avatarImage, forParameterNamed: \.speakableGroupName)
                        let interaction = INInteraction(intent: intent, response: nil)
                        interaction.direction = .incoming
                        interaction.donate()
                        do {
                            let nBestAttemptContent = try request.content.updating(from: intent).mutableCopy() as! UNMutableNotificationContent
                            contentHandler(nBestAttemptContent)
                        }catch{
                            contentHandler(bestAttemptContent)
                        }
                    } else {
                        // Fallback on earlier versions
                        contentHandler(bestAttemptContent)
                    }
                }else{
                    contentHandler(bestAttemptContent)
                }
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
