//
//  FDDefine.swift
//  FDUIKit
//
//  Created by fandongtongxue on 2020/2/23.
//

import Foundation
import UIKit

extension CGFloat {
    static let screenW = UIScreen.main.bounds.size.width
    static let screenH = UIScreen.main.bounds.size.height
    static let navigationBarHeight = CGFloat(44)
    static let statusBarHeight = CGFloat(UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.size.height ?? 0)
    static let largeNavigationTitleHeight = CGFloat(96)
    static let topHeight = (statusBarHeight + navigationBarHeight)
    static let tabBarHeight = CGFloat(49 + (statusBarHeight > 20 ? 34 : 0))
    static let safeAreaBottomHeight = CGFloat(statusBarHeight > 20 ? 34 : 0)
    static let screenScale = UIScreen.main.scale
}
