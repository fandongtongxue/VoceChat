//
//  Date+FD.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

extension Int {
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
      func updateTimeToCurrennTime() -> String {
            //获取当前的时间戳
            let currentTime = Date().timeIntervalSince1970
            //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
            let timeSta:TimeInterval = TimeInterval(self/1000)
            //时间差
            let reduceTime : TimeInterval = currentTime - timeSta
            //时间差小于60秒
            if reduceTime < 60 {
                return "刚刚"
            }
            //时间差大于一分钟小于60分钟内
            let mins = Int(reduceTime / 60)
            if mins < 60 {
                return "\(mins)分钟前"
            }
            let hours = Int(reduceTime / 3600)
            if hours < 24 {
                return "\(hours)小时前"
            }
            let days = Int(reduceTime / 3600 / 24)
            if days < 30 {
                if days < 2 {
                    let date = NSDate(timeIntervalSince1970: timeSta)
                    let dfmatter = DateFormatter()
                    //yyyy-MM-dd HH:mm:ss
                    dfmatter.dateFormat="HH:mm"
                    return "昨天 "+dfmatter.string(from: date as Date)
                }else {
                    let date = NSDate(timeIntervalSince1970: timeSta)
                    let dfmatter = DateFormatter()
                    //yyyy-MM-dd HH:mm:ss
                    dfmatter.dateFormat="MM月dd日 HH:mm"
                    return dfmatter.string(from: date as Date)
                }
            }
            //不满足上述条件---或者是未来日期-----直接返回日期
            let date = NSDate(timeIntervalSince1970: timeSta)
            let dfmatter = DateFormatter()
            //yyyy-MM-dd HH:mm:ss
            dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
            return dfmatter.string(from: date as Date)
        }
}
