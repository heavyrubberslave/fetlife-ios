//
//  FetAPI.swift
//  FetLife
//
//  Created by Jose Cortinas on 2/3/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Freddy
import p2_OAuth2
import JWTDecode
import RealmSwift

// MARK: - API Singleton

final class API {
    
    // Make this is a singleton, accessed through sharedInstance
    static let sharedInstance = API()
    
    let baseURL: String
    let oauthSession: OAuth2CodeGrant
    
    var memberId: String?
    var memberNickname: String?
    
    class func isAuthorized() -> Bool {
        return sharedInstance.isAuthorized()
    }
    
    class func currentMemberId() -> String? {
        return sharedInstance.memberId
    }
    
    class func currentMemberNickname() -> String? {
        return sharedInstance.memberNickname
    }
    
    class func authorizeInContext(context: AnyObject, onAuthorize: ((parameters: OAuth2JSON) -> Void)?, onFailure: ((error: ErrorType?) -> Void)?) {
        guard isAuthorized() else {
            sharedInstance.oauthSession.onAuthorize = onAuthorize
            sharedInstance.oauthSession.onFailure = onFailure
            sharedInstance.oauthSession.authorizeEmbeddedFrom(context)
            return
        }
    }
    
    private init() {
        let info = NSBundle.mainBundle().infoDictionary!
        
        self.baseURL = info["FETAPI_BASE_URL"] as! String
        
        let clientID = info["FETAPI_OAUTH_CLIENT_ID"] as! String
        let clientSecret = info["FETAPI_OAUTH_CLIENT_SECRET"] as! String
        
        oauthSession = OAuth2CodeGrant(settings: [
            "client_id": clientID,
            "client_secret": clientSecret,
            "authorize_uri": "\(baseURL)/oauth/authorize",
            "token_uri": "\(baseURL)/oauth/token",
            "scope": "",
            "redirect_uris": ["fetlifeapp://oauth/callback"],
            "verbose": true
        ] as OAuth2JSON)
        
        oauthSession.authConfig.ui.useSafariView = false
        
        if let accessToken = oauthSession.accessToken {
            do {
                let jwt = try decode(accessToken)
                
                if let userDictionary = jwt.body["user"] as? Dictionary<String, AnyObject> {
                    self.memberId = userDictionary["id"] as? String
                    self.memberNickname = userDictionary["nick"] as? String
                }
            } catch(let error) {
                print(error)
            }
        }
    }
    
    func isAuthorized() -> Bool {
        return oauthSession.hasUnexpiredAccessToken()
    }
    
    func loadConversations(completion: ((error: ErrorType?) -> Void)?) {
        let parameters = ["limit": 100, "order": "-updated_at", "with_archived": true]
        let url = "\(baseURL)/v2/me/conversations"
        
        oauthSession.request(.GET, url, parameters: parameters).responseData { response -> Void in
            switch response.result {
            case .Success(let value):
                do {
                    let json = try JSON(data: value).array()
                    
                    if json.isEmpty {
                        completion?(error: nil)
                        return
                    }
                    
                    let realm = try! Realm()
                    
                    realm.beginWrite()
                    
                    for c in json {
                        let conversation = try! Conversation.init(json: c)
                        realm.add(conversation, update: true)
                    }
                    
                    try! realm.commitWrite()
                    
                    completion?(error: nil)
                } catch(let error) {
                    completion?(error: error)
                }
            case .Failure(let error):
                completion?(error: error)
            }
        }
    }
    
    func archiveConversation(conversationId: String, completion: ((error: ErrorType?) -> Void)?) {
        let parameters = ["is_archived": true]
        let url = "\(baseURL)/v2/me/conversations/\(conversationId)"
        
        oauthSession.request(.PUT, url, parameters: parameters).responseData { response -> Void in
            switch response.result {
            case .Success(let value):
                do {
                    let json = try JSON(data: value)
                    
                    let conversation = try Conversation.init(json: json)
                    
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.add(conversation, update: true)
                    }
                    
                    completion?(error: nil)
                } catch(let error) {
                    completion?(error: error)
                }
            case .Failure(let error):
                completion?(error: error)
            }
        }
    }

    
    func loadMessages(conversationId: String, parameters extraParameters: Dictionary<String, AnyObject> = [:], completion: ((error: ErrorType?) -> Void)?) {
        let url = "\(baseURL)/v2/me/conversations/\(conversationId)/messages"
        var parameters: Dictionary<String, AnyObject> = ["limit": 50]

        for (k, v) in extraParameters {
            parameters.updateValue(v, forKey: k)
        }
        
        oauthSession.request(.GET, url, parameters: parameters).responseData { response in
            switch response.result {
            case .Success(let value):
                do {
                    let json = try JSON(data: value).array()
                    
                    if json.isEmpty {
                        completion?(error: nil)
                        return
                    }
                    
                    let realm = try! Realm()
                    
                    realm.beginWrite()
                    
                    for m in json {
                        let message = try! Message.init(json: m)
                        message.conversationId = conversationId
                        realm.add(message, update: true)
                    }
                    
                    try! realm.commitWrite()
                    
                    completion?(error: nil)
                } catch(let error) {
                    completion?(error: error)
                }
            case .Failure(let error):
                completion?(error: error)
            }
        }
    }
    
    func createAndSendMessage(conversationId: String, messageBody: String) {
        let parameters = ["body": messageBody]
        let url = "\(baseURL)/v2/me/conversations/\(conversationId)/messages"
        
        oauthSession.request(.POST, url, parameters: parameters).responseData { response in
            switch response.result {
            case .Success(let value):
                do {
                    let json = try JSON(data: value)
                    
                    let realm = try! Realm()
                    
                    let conversation = realm.objectForPrimaryKey(Conversation.self, key: conversationId)
                    let message = try Message(json: json)
                    
                    message.conversationId = conversationId
                    
                    try! realm.write {
                        conversation?.lastMessageBody = message.body
                        conversation?.lastMessageCreated = message.createdAt
                        realm.add(message)
                    }
                    
                } catch(let error) {
                    print(error)
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func markMessagesAsRead(conversationId: String, messageIds: [String]) {
        let parameters = ["ids": messageIds]
        let url = "\(baseURL)/v2/me/conversations/\(conversationId)/messages/read"
        
        oauthSession.request(.PUT, url, parameters: parameters).responseData { response in
            switch response.result {
            case .Success:
                let realm = try! Realm()
                
                let conversation = realm.objectForPrimaryKey(Conversation.self, key: conversationId)
                
                try! realm.write {
                    conversation?.hasNewMessages = false
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    // Extremely useful for making app store screenshots, keeping this around for now.
    func fakeConversations() -> JSON {
        return JSON.Array([
            
            .Dictionary([ // 1
                "id": .String("fake-convo-1"),
                "updated_at": .String("2016-03-11T02:29:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-1"),
                    "nickname": .String("JohnBaku"),
                    "meta_line": .String("38M Dom"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics0.a.ssl.fastly.net/0/1/0005031f-846f-5022-a440-3bf29e0a649e_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(true),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-11T02:29:27.000Z"),
                    "body": .String("Welcome?! Welcome!"),
                    "member": .Dictionary([
                        "id": .String("fake-member-1"),
                        "nickname": .String("JohnBaku"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 2
                "id": .String("fake-convo-2"),
                "updated_at": .String("2016-03-11T02:22:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-2"),
                    "nickname": .String("phoenix_flame"),
                    "meta_line": .String("24F Undecided"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics2.a.ssl.fastly.net/729/729713/00051c06-0754-8b77-802c-c87e9632d126_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-11T02:22:27.000Z"),
                    "body": .String("Miss you!"),
                    "member": .Dictionary([
                        "id": .String("fake-member-2"),
                        "nickname": .String("phoenix_flame"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 3
                "id": .String("fake-convo-3"),
                "updated_at": .String("2016-03-11T00:59:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-3"),
                    "nickname": .String("_jose_"),
                    "meta_line": .String("28M Evolving"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics0.a.ssl.fastly.net/1568/1568309/0004c1d4-637c-8930-0e97-acf588a65176_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-11T00:59:27.000Z"),
                    "body": .String("I'm so glad :)"),
                    "member": .Dictionary([
                        "id": .String("fake-member-3"),
                        "nickname": .String("_jose_"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 4
                "id": .String("fake-convo-4"),
                "updated_at": .String("2016-03-11T00:22:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-4"),
                    "nickname": .String("meowtacos"),
                    "meta_line": .String("24GF kitten"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics1.a.ssl.fastly.net/3215/3215981/0005221b-36b5-8f8d-693b-4d695b78c947_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-11T00:22:27.000Z"),
                    "body": .String("That's awesome!"),
                    "member": .Dictionary([
                        "id": .String("fake-member-4"),
                        "nickname": .String("meowtacos"),
                    ])
                ])
            ]),
            
            
            
            .Dictionary([ // 5
                "id": .String("fake-convo-5"),
                "updated_at": .String("2016-03-10T20:41:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-5"),
                    "nickname": .String("hashtagbrazil"),
                    "meta_line": .String("30M Kinkster"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics1.a.ssl.fastly.net/4634/4634686/000524af-28b0-c73d-d811-d67ae1b93019_110.jpg"])
                        
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-10T20:41:27.000Z"),
                    "body": .String("I love that design"),
                    "member": .Dictionary([
                        "id": .String("fake-member-5"),
                        "nickname": .String("hashtagbrazil"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 6
                "id": .String("fake-convo-6"),
                "updated_at": .String("2016-03-10T01:10:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-6"),
                    "nickname": .String("BobRegular"),
                    "meta_line": .String("95GF"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics1.a.ssl.fastly.net/978/978206/0004df12-b6be-f3c3-0ec5-b34d357957a3_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-10T01:10:27.000Z"),
                    "body": .String("Yes"),
                    "member": .Dictionary([
                        "id": .String("fake-member-6"),
                        "nickname": .String("BobRegular"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 7
                "id": .String("fake-convo-7"),
                "updated_at": .String("2016-03-08T01:22:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-7"),
                    "nickname": .String("GothRabbit"),
                    "meta_line": .String("24 Brat"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics2.a.ssl.fastly.net/4625/4625410/00052da5-9c1a-df4c-f3bd-530f944def18_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-08T01:22:27.000Z"),
                    "body": .String("Best munch ever"),
                    "member": .Dictionary([
                        "id": .String("fake-member-7"),
                        "nickname": .String("JohnBaku"),
                    ])
                ])
            ]),
            
            .Dictionary([ // 8
                "id": .String("fake-convo-8"),
                "updated_at": .String("2016-03-02T01:22:27.000Z"),
                "member": .Dictionary([
                    "id": .String("fake-member-8"),
                    "nickname": .String("BiggleWiggleWiggle"),
                    "meta_line": .String("19 CEO"),
                    "avatar": .Dictionary([
                        "status": "sfw",
                        "variants": .Dictionary(["medium": "https://flpics0.a.ssl.fastly.net/0/1/0004c0a3-562e-7bf7-780e-6903293438a0_110.jpg"])
                    ])
                ]),
                "has_new_messages": .Bool(false),
                "is_archived": .Bool(false),
                "last_message": .Dictionary([
                    "created_at": .String("2016-03-02T01:22:27.000Z"),
                    "body": .String("See ya"),
                    "member": .Dictionary([
                        "id": .String("fake-member-8"),
                        "nickname": .String("BiggleWiggleWiggle"),
                    ])
                ])
            ])
        ])
    }
}