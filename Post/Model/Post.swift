//
//  Post.swift
//  Post
//
//  Created by Albert Yu on 6/24/19.
//  Copyright © 2019 AlbertLLC. All rights reserved.
//

import Foundation



struct Post: Codable {
    var text: String
    var timestamp: TimeInterval
    var username: String
    
    init(username: String, text: String, timestamp: TimeInterval = Date().timeIntervalSince1970){
        self.text = text
        self.timestamp = timestamp
        self.username = username
    }
    
    var date: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: Date(timeIntervalSince1970: timestamp))
    }
}
