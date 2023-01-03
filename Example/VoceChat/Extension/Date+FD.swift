//
//  Date+FD.swift
//  VoceChat_Example
//
//  Created by 范东 on 2023/1/3.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import SwiftDate

extension Int {
    func translateTimestamp() -> String {
        let currentTime = Date().timeIntervalSince1970
        let time:TimeInterval = TimeInterval(self/1000)
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat="MM月dd日 HH:mm"
        return dateFormatter.string(from: date)
    }
}
