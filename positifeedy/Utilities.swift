//
//  Utilities.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import Foundation
import Alamofire

import Firebase

struct Global {

   
    
    
    
 static   let feedURL = "https://api.rssapi.net/v1/8f09a62bbe4baad7d4695d580c09023e/combine?url[]=https://www.mindful.org/feed/&url[]=https://tinybuddha.com/feed/&url[]=https://www.blunt-therapy.com/feed/&url[]=https://thetreatmentspecialist.com/feed/&url[]=https://mybrainsnotbroken.com/feed/&url[]=http://www.defyingmentalillness.com/feed/&url[]=https://mindworks.org/feed/&url[]=https://www.mindfulness-garden.com/feed/&url[]=https://mindfulminutes.com/feed/&url[]=https://natashatracy.com/feed/&url[]=https://www.psychologytoday.com/us/blog/both-sides-the-couch/feed&url[]=http://mrsmindfulness.com/category/articles/feed/"
    
    
    
    struct Font {
        static let  medium = "SF-Pro-Display-Medium"
        
        static let regular = "SF-Pro-Display-Regular"
        
        static let  semibold = "SF-Pro-Display-Semibold"
        
    }
    
}

extension String
{
    func toDate() -> Date
    {
         let f = DateFormatter()
         f.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        return f.date(from: self)!
    }
    
    func getTimeZone() -> TimeZone
    {
        let f = DateFormatter()
         f.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        return f.timeZone
    }
}



enum Images  : String
{
    case blunttherapy = "blunt-therapy"
    case defyingmentalillness  = "defyingmentalillness"
    case  mindfulnessgarden = "mindfulness-garden"
    case mindfulnessminutes = "mindfulminutes"
    
    case mindful = "mindful"
    case mindworks = "mindworks"
    case mrsmindfulness = "mrsmindfulness"
    case  mybrainsnotbroken = "mybrainsnotbroken"
    case natashatracy  = "natashatracy"
    case psychologytoday =  "psychologytoday"
    case thetreamentspecialist =   "thetreamentspecialist"
    case  tinybuddha =  "tinybuddha"
    
    var image : String? {
        
        switch self {
            
        case .blunttherapy:
            return "blunt-therapy.jpg"
        case .defyingmentalillness:
            return "defyingmentalillness.jpg"
        case .mindfulnessgarden:
            return "mindfulness-garden.jpg"
        case .mindfulnessminutes:
            return "mindfulnessminutes.jpg"
        case .mindful:
            return "mindful.png"
        case .mindworks:
            return "mindworks.png"
        case .mrsmindfulness:
            return "mrsmindfulness.jpg"
        case .mybrainsnotbroken:
            return "mybrainsnotbroken.jpg"
        case .natashatracy:
            return "natashatracy.jpg"
        case .psychologytoday:
            return "psychologytoday.png"
        case .thetreamentspecialist:
            return "thetreamentspecialist.png"
        case .tinybuddha:
            return "tinybuddha.png"
        @unknown default:
            return nil
        }
        
        
    }
    
}



extension URL {
    
    var domain: String? {
        let arr = host?.components(separatedBy: ".")
        return arr?.count == 3 ? arr![1] : arr![0]
    }
    
}




class Utilities {
    
    
    static func appName () -> String? {  return Bundle.main.localizedInfoDictionary?["CFBundleName"] as? String
    }
    
static func isPasswordValid(_ password : String) -> Bool {
    
    let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
    return passwordTest.evaluate(with: password)
}
    
}


class NetworkState {
    class func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}


extension Date {
    
    func getElapsedInterval( _ timeZone : TimeZone ) -> String {

        let f = DateFormatter()
        f.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        f.timeZone = timeZone
        let  date = f.date(from: f.string(from: Date()))
        
        let interval = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: date!)

        if let year = interval.year, year > 0 {
            return year == 1 ? "\(year)" + " " + "year ago" :
                "\(year)" + " " + "years ago"
        } else if let month = interval.month, month > 0 {
            return month == 1 ? "\(month)" + " " + "month ago" :
                "\(month)" + " " + "months ago"
        } else if let day = interval.day, day > 0 {
            return day == 1 ? "\(day)" + " " + "day ago" :
                "\(day)" + " " + "days ago"
        }
        else if let houre = interval.hour , houre > 0 {
            return houre == 1 ? "\(houre) " + "hour ago" : "\(houre)" + " " + "hours ago"
        }
        else if let minute = interval.minute , minute > 0 {
            return minute == 1 ? "\(minute) " + "minute ago" : "\(minute)" + " " + "minutes ago"
        }
            
        else {
            return "a moment ago"

        }

    }
    
    
    
    
    func compaterToDate() -> String {
        
        
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .year, .hour, .day]
        formatter.unitsStyle = .full
        formatter.includesApproximationPhrase = false
        formatter.includesTimeRemainingPhrase = false
        
        let difference = formatter.string(from: self, to: Date())!
        print(difference)//output "8 sec
        
        return difference
    }
    
    
}



extension UIView {
    
    func cornerRadius( _  radius : CGFloat ) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
}



extension UIViewController {
    
    
    func setNavBackground()  {
        
         self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           
        let color = #colorLiteral(red: 0.4809715748, green: 0.966379106, blue: 0.6703928709, alpha: 1)
        
        if #available(iOS 13, *)
        {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor =  color // UIColor(red: 37/255, green: 250/255, blue: 168/255, alpha: 1)
            
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()

            
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.compactAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
         else
        {
            
            self.navigationController?.navigationBar.barTintColor = color //  UIColor(red: 37/255, green: 250/255, blue: 168/255, alpha: 1)
           
        }
    }
    func setNavTitle(title : String)  {
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = ""
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 17)
        
        self.navigationItem.titleView = titleLabel
    }
    
    
   
   
}
