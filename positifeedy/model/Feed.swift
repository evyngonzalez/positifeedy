//
//  Feed.swift
//  positifeedy
//
//  Created by iMac on 24/09/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import Foundation


class FeedResponse: NSObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case ok
        case info = "result"
    }
    
    
    var ok : Bool?
    var info : FeedInfo
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ok = try container.decode(Bool.self, forKey: .ok)
        info = try container.decode(FeedInfo.self, forKey: .info)
        
    }
}

class FeedInfo : NSObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case arrFeedData = "entries"
    }
    

    var arrFeedData : [Feed]?
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        arrFeedData = try container.decode([Feed]?.self, forKey: .arrFeedData)
        
    }
    
}

class timeStampandData : Decodable
{
    var title : String?
    var link : String?
    var desc : String?
    var guid : String?
    var time : String?
    var timestamp : String?
    
    var title_pos : String?
    var desc_pos : String?
    var feed_type : String?
    var feed_url : String?
    var feed_image : String?
    var feed_video : String?
    var documentID: String?
    
    init(title: String?,link: String?,desc: String?,guid: String,time: String?, timestamp: String,title_pos: String,desc_pos: String,feed_type: String,feed_url: String,feed_image: String,feed_video: String,documentID: String) {
        
        self.title = title
        self.link = link
        self.desc = desc
        self.guid = guid
        self.time = time
        self.timestamp = timestamp
        self.title_pos = title_pos
        self.desc_pos = desc_pos
        self.feed_type = feed_type
        self.feed_url = feed_url
        self.feed_image = feed_image
        self.feed_video = feed_video
        self.documentID = documentID
        
    }
    
    
}

class Feed : NSObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        
        case  title
        case  link
        case  desc = "description"
        case  guid
        case  time
        case  timestamp
    }
    
    var title : String?
    var link : String?
    var desc : String?
    var guid : String?
    var time : String?
    var timestamp : Int?
    
    required init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        link = try container.decode(String?.self, forKey: .link)
        desc = try container.decode(String.self, forKey: .desc)
        guid = try container.decode(String?.self, forKey: .guid)
        time = try container.decode(String.self, forKey: .time)
        timestamp = try container.decode(Int?.self, forKey: .timestamp)
    }
}


class FeedDetails: NSObject, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case desc = "description"
        case homepage
    }
    
    var title : String?
    var desc : String?
    var homepage : String?
    
    required init(from decoder: Decoder) throws {
           
           let container = try decoder.container(keyedBy: CodingKeys.self)
           title = try container.decode(String.self, forKey: .title)
           desc = try container.decode(String?.self, forKey: .desc)
           homepage = try container.decode(String?.self, forKey: .homepage)
       }
       
}

struct NotificationQuote: Codable {
    
    var author : String?
    var timestamp : String?
    var quote_title : String?
    
    init(author: String?,timestamp: String?,quote_title: String) {
        
        self.author = author
        self.timestamp = timestamp
        self.quote_title = quote_title
    }
    
}


struct AnswerItem: Codable {
    
    var link : String?
    var point : String?
    var question : String?
    var timestamp : String?
    var answer : String?
    
    init(link: String?,point: String?,question: String?,timestamp: String?,answer: String) {
        
        self.link = link
        self.point = point
        self.question = question
        self.timestamp = timestamp
        self.answer = answer
        
    }
     
}


struct QuestionListItem: Codable {
    
    var link : String?
    var point : String?
    var question : String?
    var timestamp : String?
    
    init(link: String?,point: String?,question: String?,timestamp: String?) {
        
        self.link = link
        self.point = point
        self.question = question
        self.timestamp = timestamp
        
    }
    
    
}

struct OnlyTimeStamp : Codable {
    
    var timestamp : Int!
    init(timestamp : Int?)
    {
        
        self.timestamp = timestamp
    }
    
}

struct Positifeedy: Codable {
    var title : String?
    var desc : String?
    var feed_type : String?
    var feed_url : String?
    var feed_image : String?
    var feed_video : String?
    var timestamp : String?
    var documentID: String?

    init(title: String?, desc: String?, feed_type: String?, feed_url: String?, feed_image: String?, feed_video: String?, timestamp: String?, documentID: String?) {
        self.title = title
        self.desc = desc
        self.feed_type = feed_type
        self.feed_url = feed_url
        self.feed_image = feed_image
        self.feed_video = feed_video
        self.timestamp = timestamp
        self.documentID = documentID
    }
}

struct PositifeedAllSet: Codable {
    
    var title : String?
    var desc : String?
    var feed_type : String?
    var feed_url : String?
    var feed_image : String?
    var feed_video : String?
    var timestamp : String?
    var documentID: String?
    var link : String?
    var guid : String?
    var time : String?
    var description_d : String?

    init(title: String?, desc: String?, feed_type: String?, feed_url: String?, feed_image: String?, feed_video: String?, timestamp: String?, documentID: String?,link: String,guid: String,time: String,description_d: String) {
        
        self.title = title
        self.desc = desc
        self.feed_type = feed_type
        self.feed_url = feed_url
        self.feed_image = feed_image
        self.feed_video = feed_video
        self.timestamp = timestamp
        self.documentID = documentID
        
        self.link = link
        self.guid = guid
        self.time = time
        self.description_d = description_d
    }
      
    
}

struct AnswerFeed: Codable {
    
    var answer : String?
    var current_date : String?
    var link : String?
    var point : String?
    var question : String?
    var audio_url : String?
    var type : String?
    var timestamp : String?
    var play_time : String?

    init(answer: String?, current_date: String?, link: String?, point: String?, question: String?, timestamp: String?,type: String?,audio_url: String?,play_time: String?) {
        self.answer = answer
        self.current_date = current_date
        self.link = link
        self.point = point
        self.question = question
        self.timestamp = timestamp
        self.audio_url = audio_url
        self.type = type
        self.play_time = play_time
        
    }
}
