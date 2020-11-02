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
    
    static let feedURL = "https://api.rssapi.net/v1/8f09a62bbe4baad7d4695d580c09023e/combine?url[]=https://www.mindful.org/feed/&url[]=https://tinybuddha.com/feed/&url[]=https://www.blunt-therapy.com/feed/&url[]=https://thetreatmentspecialist.com/feed/&url[]=https://mybrainsnotbroken.com/feed/&url[]=http://www.defyingmentalillness.com/feed/&url[]=https://mindworks.org/feed/&url[]=https://www.mindfulness-garden.com/feed/&url[]=https://mindfulminutes.com/feed/&url[]=https://natashatracy.com/feed/&url[]=https://www.psychologytoday.com/us/blog/both-sides-the-couch/feed&url[]=http://mrsmindfulness.com/category/articles/feed/"
    
    struct Font {
        static let  medium = "SF-Pro-Display-Medium"
        
        static let regular = "SF-Pro-Display-Regular"
        
        static let  semibold = "SF-Pro-Display-Semibold"
    }
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
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
    
    func trim() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    func isValidateUrl() -> Bool {
        var urlRegEx = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        var urlTest = NSPredicate.withSubstitutionVariables(predicate)
        return predicate.evaluate(with: self)
    }
    
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
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
    
    class func jsonStringToObject(_ string: String) -> AnyObject? {
        
        let data = string.data(using: .utf8)!
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments)
            return jsonObject as AnyObject
            
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
    
    class func objectToJsonString(_ object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
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
    
    var timestampString: String?
    {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "en_US_POSIX")
        calendar.timeZone = TimeZone.current
        
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.calendar = calendar
        
        guard let timeString = formatter.string(from: self, to: Date()) else {
            return nil
        }
        
        let formatString = NSLocalizedString("%@", comment: "")
        return String(format: formatString, timeString)
    }
    
    func timestamp() -> Int64 {
        
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    
    static func date(timestamp: Int64) -> Date {
        
        let interval = TimeInterval(TimeInterval(timestamp) / 1000)
        return Date(timeIntervalSince1970: interval)
    }
    
    func isExpiredNow() -> Bool {
        
        print("time :" , self.timeIntervalSince1970 , "now :" , Date().timeIntervalSince1970)
        
        return self.timeIntervalSince1970 <= Date().timeIntervalSince1970
    }
    
    func serverDateTimeToTodayFormat( isShort: Bool = true ) -> String {

        if Calendar.current.isDateInToday(self) {
            return self.nSDateToStringDate( format: "hh:mm a")
        }else if Calendar.current.isDateInYesterday(self ) {
            return  isShort ? "Yesterday" : self.nSDateToStringDate( format: "'Yesterday' hh:mm a")
        }else if Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0 < 7{
            return self.nSDateToStringDate( format: isShort ? "EEEE" : "EEEE hh:mm a")
        }else{
            return self.nSDateToStringDate( format: isShort ? "MM/dd/yyyy" : "MM/dd/yyyy 'at' hh:mm a")
        }
    }
    
    func nSDateToStringDate ( format: String) -> String {
        let dateFormat =  DateFormatter()
        dateFormat.dateFormat = format;
        return dateFormat.string(from: self)
    }
    
    var day: Int {
        return Calendar.current.dateComponents([.day], from: self).day ?? 0
    }
    
    var month: Int {
        return Calendar.current.dateComponents([.month], from: self).month ?? 0
    }
    
    var year: Int {
        return Calendar.current.dateComponents([.year], from: self).year ?? 0
    }
    
    var hour: Int {
        return Calendar.current.dateComponents([.hour], from: self).hour ?? 0
    }
    
    var minute: Int {
        return Calendar.current.dateComponents([.minute], from: self).minute ?? 0
    }
    
    var second: Int {
        return Calendar.current.dateComponents([.second], from: self).second ?? 0
    }
    
}

extension NSDictionary {
    
    func removeNullFromDict () -> NSDictionary
    {
        guard let dic = self.mutableCopy() as? NSMutableDictionary else {
            return self
        }
        
        for (key, value) in dic {
            
            let val : NSObject = value as! NSObject;
            if(val.isEqual(NSNull()))
            {
                dic.setValue("", forKey: (key as? String)!)
            }
            else
            {
                dic.setValue(value, forKey: key as! String)
            }
            
        }
        return dic;
    }
    
}

extension UIView {
    
    func cornerRadius( _  radius : CGFloat ) {
        layer.cornerRadius = radius
        clipsToBounds = true
    }
    
    func setDesignedBorder(radius: CGFloat, width: CGFloat) {
        self.backgroundColor = #colorLiteral(red: 0.4823529412, green: 0.9647058824, blue: 0.6705882353, alpha: 1)
        self.layer.cornerRadius = radius
        self.layer.borderWidth = width
        self.layer.borderColor = UIColor.clear.cgColor
    }
}



extension UIViewController {
    
    func showAlert(title: String ,message: String, linkHandler: ((UIAlertAction) -> Void)? ){
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Ok", style: .default, handler:linkHandler))
        self.present(alertController, animated: true, completion: nil);
    }
    
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
                
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Avenir-Heavy", size: 17)
        titleLabel.sizeToFit()
        
        self.navigationItem.titleView = titleLabel
    }
   
}

extension UITableView
{
    func setAndLayoutTableHeaderView(header: UIView) {
        self.tableHeaderView = header
        header.setNeedsLayout()
        header.layoutIfNeeded()
        header.frame.size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        self.tableHeaderView = header
    }
    
    func scrollToBottom()
    {
        DispatchQueue.main.async {
            
            if self.numberOfSections > 0,
                self.numberOfRows(inSection:  self.numberOfSections - 1) > 0 {
                let indexPath = IndexPath(
                    row: self.numberOfRows(inSection:  self.numberOfSections - 1) - 1,
                    section: self.numberOfSections - 1)
                self.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func scrollToTop() {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            self.scrollToRow(at: indexPath, at: .top, animated: false)
        }
    }
}

extension UIImage {
    func compressTo(_ expectedSizeInMb:Int) -> Data? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return data
            }
        }
        return nil
    }
}


