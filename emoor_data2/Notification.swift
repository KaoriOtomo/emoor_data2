//
//  Notification.swift
//  emoor_data2
//
//  Created by 大友香穂里 on 2019/03/07.
//  Copyright © 2019年 大友香穂里. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

//ユーザー通知用のクラスを単独で設計
final class UserNotifications{
    init(){
    }
    
    //アイコン画面に表示する、バッジの数字をstaticで管理。
    static var number = 0
    
    //ユーザーに対して通知の許可を求める。
    class func pleaseAgree(){
        //通知許可を求める前のネゴ
        
        //ここからが実際の通知許可依頼
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
                if error != nil {
                    // エラー
                    return
                }
                
                if granted {
                    // 通知許可された
                } else {
                    // 通知拒否
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
        }
    }
}
