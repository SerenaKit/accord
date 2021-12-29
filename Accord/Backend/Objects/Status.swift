//
//  Status.swift
//  Status
//
//  Created by evelyn on 2021-08-27.
//

import Foundation

final class Status: Codable {
    var text: String?
    // var expires_at: String?
    var emoji_name: String?
    var emoji_id: String?
}

final class Activity {
    internal init(applicationID: String? = nil, flags: Int? = nil, emoji: StatusEmoji? = nil, name: String, type: Int, timestamp: Int? = nil, state: String? = nil, details: String? = nil) {
        self.applicationID = applicationID
        self.flags = flags
        self.emoji = emoji
        self.name = name
        self.type = type
        self.timestamp = timestamp
        self.state = state
        self.details = details
    }
    
    static var current: Activity? = nil
    
    var emoji: StatusEmoji?
    var name: String
    var state: String?
    var type: Int
    var timestamp: Int?
    var applicationID: String?
    var flags: Int?
    var details: String?
    var dictValue: [String:Any] {
        var dict: [String:Any] = ["name":name, "type":type, "state":NSNull()]
        if let emoji = emoji {
            dict["emoji"] = emoji.dictValue
        }
        if let state = state {
            dict["state"] = state
        }
        if type == 0 {
            dict["assets"] = [:]
            dict["party"] = [:]
            dict["secrets"] = [:]
        }
        if let applicationID = applicationID {
            dict["application_id"] = applicationID
        }
        if let timestamp = timestamp {
            dict["timestamps"] = ["start":timestamp]
        }
        if let flags = flags {
            dict["flags"] = flags
        }
        if let details = details {
            dict["details"] = details
        }
        print(dict)
        return dict
    }
}

final class StatusEmoji {
    internal init(name: String, id: String, animated: Bool) {
        self.name = name
        self.id = id
        self.animated = animated
    }
    
    var name: String
    var id: String
    var animated: Bool
    var dictValue: [String:Any] {
        return ["name":name, "id":id, "animated":animated]
    }
}

