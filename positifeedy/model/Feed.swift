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