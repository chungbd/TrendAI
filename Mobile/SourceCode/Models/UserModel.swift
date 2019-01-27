//
//  UserModel.swift
//  TrendAI
//
//  Created by nguyen.manh.tuanb on 14/01/2019.
//  Copyright © 2019 Benjamin. All rights reserved.
//

import Foundation

final class UserModel: Codable {
    var twitterInfo: TwitterInfo?
}

final class TwitterInfo: Codable {
    var userId: String?
    var oAuthToken: String?
    var oAuthSecret: String?
    var screenName: String?
    
    convenience init(parameters:[String:Any], token:String?, secret:String?) {
        self.init()
     
        screenName = parameters["screen_name"] as? String
        userId = parameters["user_id"] as? String
        oAuthToken = token
        oAuthSecret = secret
    }
    
    convenience init(fibTree:CommonDic) {
        self.init()
        
        screenName = fibTree["screen_name"] as? String
        userId = fibTree["userId"] as? String
        oAuthToken = fibTree["oAuthToken"] as? String
        oAuthSecret = fibTree["oAuthSecret"] as? String
    }
}

