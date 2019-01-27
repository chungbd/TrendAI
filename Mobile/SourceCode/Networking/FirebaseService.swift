//
//  FirebaseService.swift
//  TrendAI
//
//  Created by nguyen.manh.tuanb on 14/01/2019.
//  Copyright © 2019 Benjamin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import RxSwift
import SwiftyJSON
import RxCocoa

let gCurrentUser = Variable<UserModel>(UserModel())

final class FirebaseService {
    
    static let instance: FirebaseService = {
        let instance = FirebaseService()
        instance.connectDatabase()
        return instance
    }()
    
    private var treeRef: DatabaseReference?
    private(set) var disposeBag = DisposeBag()
    
    private let twitterPath: String = "twitter"
    private let socialPath: String = "social"
    
    private func connectDatabase() {
        treeRef = Database.database().reference().child("TrendAI")
    }
    
    func saveProfileData() {
        guard let fUser = SessionManagers.shared.getCurrentUser() else { return }
        guard let treeRef = treeRef else { return }
        let userId = fUser.uid
        var userInfo: [String: Any] = [:]
        userInfo["email"] = fUser.email
        userInfo["displayName"] = fUser.displayName
        userInfo["phoneNumber"] = fUser.phoneNumber
        userInfo["avatar"] = fUser.photoURL?.absoluteString
        
        var twitterInfo: [String: Any] = [:]
        twitterInfo["screen_name"] = gCurrentUser.value.twitterInfo?.screenName
        twitterInfo["userId"] = gCurrentUser.value.twitterInfo?.userId
        twitterInfo["oAuthToken"] = gCurrentUser.value.twitterInfo?.oAuthToken
        twitterInfo["oAuthSecret"] = gCurrentUser.value.twitterInfo?.oAuthSecret
        
        userInfo[twitterPath] = twitterInfo
        treeRef.child(userId).setValue(userInfo) { (error, _) in
            print("saved data success error \(error?.localizedDescription ?? "")")
        }
    }
    
    func getProfileData(completion:@escaping (CommonDic?)->()) -> Void {
        guard let fUser = SessionManagers.shared.getCurrentUser() else { return }
        
        let userId = fUser.uid
        
        guard let treeRef = treeRef else { return }
        
        treeRef.child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? CommonDic
            completion(value)
        }) { (error) in
            print(error.localizedDescription)
            completion(nil)
        }
    }
    
    func getTwitterData(completion:@escaping (TwitterInfo?)->()) -> Void {
        getProfileData { [unowned self](data) in
            if let rData = data,
                let twTree = rData[self.twitterPath] as? CommonDic {
                let twInfor = TwitterInfo(fibTree: twTree)
                completion(twInfor)
            } else {
                completion(nil)
            }
        }
    }
    
    func saveTwitterData(_ data: [String: Any]) {
        guard let fUser = SessionManagers.shared.getCurrentUser() else { return }
        guard let treeRef = treeRef else { return }
        treeRef.child(fUser.uid)
            .child(twitterPath)
            .child(socialPath)
            .childByAutoId().setValue(data) { (error, _) in
                print("saved data success error \(error?.localizedDescription ?? "")")
        }
    }
}
