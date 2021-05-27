//
//  Constants.swift
//  positifeedy
//
//  Created by Evyn Gonzalez  on 9/12/20.
//  Copyright © 2020 Evyn Gonzalez . All rights reserved.
//

import Foundation
import AVKit

struct Constants {
    struct Storyboard {
    
        static let welcomeViewController = "HomeVC"
    }
}

let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)

let arrFeedy: [[String: String]] = [
    [ "desc" : "Big Buck Bunny tells the story of a giant rabbit with a heart bigger than himself. When one sunny day three rodents rudely harass him, something snaps... and the rabbit ain't no bunny anymore! In the typical cartoon tradition he prepares the nasty rodents a comical revenge.\n\nLicensed under the Creative Commons Attribution license\nhttp://www.bigbuckbunny.org",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg",
      "title" : "Big Buck Bunny",
      "feed_type" : "video",
      "timestamp" : "1537571653",
    ],
    [ "desc" : "The first Blender Open Movie from 2006. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4" ,
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg",
      "title" : "Elephant Dream",
      "feed_type" : "image",
      "timestamp" : "1535681029"
    ],
    [ "desc" : "HBO GO now works with Chromecast -- the easiest way to enjoy online video on your TV. For when you want to settle into your Iron Throne to watch the latest episodes. For $35.\nLearn how to use Chromecast with HBO GO and more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4" ,
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg",
      "title" : "For Bigger Blazes",
      "feed_type" : "video",
      "timestamp" : "1532092541"
    ],
    [ "desc" : "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when Batman's escapes aren't quite big enough. For $35. Learn how to use Chromecast with Google Play Movies and more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg",
      "title" : "For Bigger Escape",
      "feed_type" : "text",
      "timestamp" : "1531535656"
    ],
    [ "desc" : "Introducing Chromecast. The easiest way to enjoy online video and music on your TV. For $35.  Find out more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg",
      "title" : "For Bigger Fun",
      "feed_type" : "image",
      "timestamp" : "1530659502"
    ],
    [ "desc" : "Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for the times that call for bigger joyrides. For $35. Learn how to use Chromecast with YouTube and more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4" ,
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg",
      "title" : "For Bigger Joyrides",
      "feed_type" : "image",
      "timestamp" : "1530053998"
    ],
    [ "desc" :"Introducing Chromecast. The easiest way to enjoy online video and music on your TV—for when you want to make Buster's big meltdowns even bigger. For $35. Learn how to use Chromecast with Netflix and more at google.com/chromecast.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg",
      "title" : "For Bigger Meltdowns",
      "feed_type" : "text",
      "timestamp" : "1528502966"
    ],
    [ "desc" : "Sintel is an independently produced short film, initiated by the Blender Foundation as a means to further improve and validate the free/open source 3D creation suite Blender. With initial funding provided by 1000s of donations via the internet community, it has again proven to be a viable development model for both open 3D technology as for independent animation film.\nThis 15 minute film has been realized in the studio of the Amsterdam Blender Institute, by an international team of artists and developers. In addition to that, several crucial technical and creative targets have been realized online, by developers and artists and teams all over the world.\nwww.sintel.org",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg",
      "title" : "Sintel",
      "feed_type" : "video",
      "timestamp" : "1527903091"
    ],
    [ "desc" : "Smoking Tire takes the all-new Subaru Outback to the highest point we can find in hopes our customer-appreciation Balloon Launch will get some free T-shirts into the hands of our viewers.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg",
      "title" : "Subaru Outback On Street And Dirt",
      "feed_type" : "text",
      "timestamp" : "1524184566"
    ],
    [ "desc" : "Tears of Steel was realized with crowd-funding by users of the open source 3D creation tool Blender. Target was to improve and test a complete open and free pipeline for visual effects in film - and to make a compelling sci-fi film in Amsterdam, the Netherlands.  The film itself, and all raw material used for making it, have been released under the Creatieve Commons 3.0 Attribution license. Visit the tearsofsteel.org website to find out more about this, or to purchase the 4-DVD box with a lot of extras.  (CC) Blender Foundation - http://www.tearsofsteel.org",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg",
      "title" : "Tears of Steel",
      "feed_type" : "video",
      "timestamp" : "1522528746"
    ],
    [ "desc" : "The Smoking Tire heads out to Adams Motorsports Park in Riverside, CA to test the most requested car of 2010, the Volkswagen GTI. Will it beat the Mazdaspeed3's standard-setting lap time? Watch and see...",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/VolkswagenGTIReview.jpg",
      "title" : "Volkswagen GTI Review",
      "feed_type" : "image",
      "timestamp" : "1520827391"
    ],
    [ "desc" : "The Smoking Tire is going on the 2010 Bullrun Live Rally in a 2011 Shelby GT500, and posting a video from the road every single day! The only place to watch them is by subscribing to The Smoking Tire or watching at BlackMagicShine.com",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WeAreGoingOnBullrun.jpg",
      "title" : "We Are Going On Bullrun",
      "feed_type" : "image",
      "timestamp" : "1520035876"
    ],
    [ "desc" : "The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.The Smoking Tire meets up with Chris and Jorge from CarsForAGrand.com to see just how far $1,000 can go when looking for a car.",
      "feed_video" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4" ,
      "feed_image" : "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/WhatCarCanYouGetForAGrand.jpg",
      "title" : "What care can you get for a grand?",
      "feed_type" : "video",
      "timestamp" : "1518057679"
    ]
]

var arrTheme = [[String: Any]]()

//let arrTheme:[[String: Any]] = [
//    [
//        "themeId":1,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Ffreevideo1.mp4?alt=media&token=0839524c-49bc-40a7-a5c5-a223913c146f",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_0.png?alt=media&token=744b99f7-f816-4ab3-bd31-2e4709c30b7e",
//        "isFree":true,
//        "isVideo":true,
//        "maxColor" : "#38332A"
//    ],
//    [
//        "themeId":2,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Ffreevideo2.mp4?alt=media&token=9feb45e7-ab3d-46bc-a1e2-900f65597bdb",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_1.png?alt=media&token=e549cf21-3ba7-4007-8caa-1ef9c0b8087a",
//        "isFree":true,
//        "isVideo":true,
//        "maxColor":"030501"
//    ],
//    [
//        "themeId":3,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Ffreevideo3.mp4?alt=media&token=421c4a31-23c9-4c72-96a0-577aebe8d0e9",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_2.png?alt=media&token=fcfca2e2-478d-4f9c-b1bc-757c2593d857",
//        "isFree":true,
//        "isVideo":true,
//        "maxColor":"212118"
//    ],
//    [
//        "themeId":4,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Fpaidvideo1.mp4?alt=media&token=b55a7018-5da6-4622-82a7-b4af67bff602",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_3.png?alt=media&token=42f6fcca-f870-4637-86a6-35c6d1fcb5ec",
//        "isFree":false,
//        "isVideo":true,
//        "maxColor":"798590"
//    ],
//    [
//        "themeId":5,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Fpaidvideo2.mp4?alt=media&token=02af6d8e-cdbb-4dc3-b639-7accccfcdd6c",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_4.png?alt=media&token=8f802e5e-109f-4730-8245-93dd44846e89",
//        "isFree":false,
//        "isVideo":true,
//        "maxColor":"1F2F3D"
//    ],
//    [
//        "themeId":6,
//        "themeUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2Fpaidvideo3.mp4?alt=media&token=f444bf90-7153-46a5-821d-249e81af4346",
//        "thumbUrl":"https://firebasestorage.googleapis.com/v0/b/positifeedy-2020a.appspot.com/o/themes%2FthumbImage_5.png?alt=media&token=f45afd5d-6eba-4eff-885d-c90274be8fcb",
//        "isFree":false,
//        "isVideo":true,
//        "maxColor":"A6CAFE"
//    ],
//
//]

//var dict = NSDictionary()

var dict = NSDictionary()
//    [
//    "SELF LOVE":[
//        "Messages":["Today, I choose me.",
//                    "I am worthy of infinite compassion.",
//                    "I feel profound empathy and love for others and their own unique paths.",
//                    " I choose to stop apologizing for being me.",
//                    "I am at peace with all that has happened in my life.",
//                    "My life is filled with joy and abundance.",
//                    "Happiness flows from me",
//                    "I will surround myself with positive people who will help bring the best out in me.",
//                    "I am willing to keep going, when things get tough, to achieve the success I deserve",
//                    "My body is beautiful and expresses my spirit.",
//                    "I am grounded, peaceful, and centered.",
//                    "I respect my limitations and thank myself for the things I am able to accomplish.",
//                    "My life is full of happiness and love",
//                    "I release my negative thoughts, embracing positivity and optimism.",
//                    "I feel pride in myself.",
//                    "I am not the sum of my mistakes.",
//                    "I have everything I need.",
//                    "I feel beautiful, I am beautiful",
//                    "I am empowered to create change in my life",
//                    "I will focus on the bright side.",
//                    "I follow my own expectations, not the expectations of others.",
//                    "I am in control of my own actions.",
//                    "I overflow with creativity and good ideas.",
//                    "I do not judge myself or others.",
//                    "I did not get up today to “just” be average. I will excel!",
//                    "I am not my negative thoughts or emotions.",
//                    "I am becoming the person I want to be.",
//                    "I have the tools I need to achieve my dreams.",
//                    "When I practice self-love, I become more lovable.",
//                    "The universe conspires to help me succeed.",
//                    "I control my fears, they do not control me.",
//                    "I love the person that I am.",
//                    "I am whole alone.",
//                    "Today, I choose myself.",
//                    "I have faith in my abilities.",
//                    "My life is full of love.",
//                    "I will stand my ground and defend myself.",
//                    "I respect myself.",
//                    "I have worth and inner beauty.",
//                    "I will care for myself as much as I care for others.",
//                    "I deserve to be happy and successful",
//                    "I am competent, smart and able",
//                    "My opinions are valid and well-reasoned",
//                    "I am growing and changing for the better",
//                    "I believe in myself, my skills, and abilities",
//                    "My life is a gift and I will make the most out of it",
//                    "I will let go of negativity about myself",
//                    "I see the best in other people",
//                    "My body is sacred and I will take care of it",
//                    "I recognise my good qualities, and there are many",
//                    "I am worthy of my successes",
//                    "My flaws are what make me unique and I will work towards loving them",
//                    "I am confident with my plan for my life",
//                    "I accept that I am not perfect and have the courage to change what I can",
//                    "My decisions are sound and reasoned and I will stand by them",
//                    "I will continue to pursue the knowledge I need to succeed",
//                    "I love what I do and do what I am good at",
//                    "All of my actions lead to success",
//                    "I have a beautiful smile",
//                    "I love myself",
//                    "I deserve to be happy and successful.",
//                    "I have to power to change myself.",
//                    "I can forgive and understand others and their motives.",
//                    "I can make my own choices and decisions.",
//                    "I am free to choose to live as I wish and to give my priorities to my desires.",
//                    "I can choose happiness whenever I wish no matter what my circumstances.",
//                    "I am flexible and open to change in every aspect of my life."],
//        "Image":"",
//        "Description":"",
//        "Title":"Self Love"
//    ],
//    "STRESS":[
//        "Messages":["I replace my anger with understanding and compassion.",
//                    "I release the past and live fully in the present moment.",
//                    "All my problems have a solution.",
//                    "With every breath out, I release stress in my body.",
//                    "I breathe deeply, exercise regularly, and feed only good nutritious food to my body.",
//                    "I am surrounded by people who encourage and support healthy choices.",
//                    "My world is a peaceful, loving, and joy-filled place to live.",
//                    "I sow the seeds of peace wherever I go."],
//        "Image":"",
//        "Description":"",
//        "Title":"Managing stress"
//    ],
//    "MOTIVATION": [
//        "Messages": ["I refuse to give up because I haven’t tried all possible ways.",
//    "I adopt the mindset to praise myself.",
//    "I cannot give up and will never give up.",
//    "Every day in every way, I am becoming more and more successful.",
//    "I see fear as the fuel for my success and take bold action despite fear.",
//    "I always attract only the best of circumstances and the best positive people in my life.",
//    "Self-confidence is what I thrive on. Nothing is impossible, and life is great.",
//    "I always see only the good in others. I attract only positive, confident people.",
//    "I fill my mind with positive and nourishing thoughts.",
//    "There are no limits to what I can achieve in my life.",
//    "Today, I abandon my old habits and take up new, more positive ones.",
//    "I choose love, joy, and freedom, open my heart, and allow wonderful things to flow into my life.",
//    "I am full of money-making ideas.",
//    "I awaken in the morning, feeling happy and enthusiastic about life.",
//    "I rest in happiness when I go to sleep, knowing all is well in my world.",
//    "Time is the most valuable resource; therefore, I spend it wisely.",
//    "I have the power to live my dreams.",
//    "I inspire others to be their best self.",
//    "I stand up for what I believe in."],
//        "Image":"",
//        "Description":"",
//        "Title":"Motivation"
//    ],
//    "FAMILY":[
//        "Messages": ["I love my family even if they do not understand me completely.",
//    "I choose to see my family as a gift.",
//    "I feel the love of those who are not physically around me.",
//    "I trust in my own ability to provide well for my family.",
//    "I have so many good people in my life and so many more yet to meet.",
//    "My partner and I share a deep and powerful love for each other.",
//    "My partner and I communicate openly and resolve conflict peacefully and respectfully.",
//    "I have a wonderful partner, and we are both happy and at peace.",
//    "I am able to be fully myself and completely authentic in my love relationship.",
//    "My partner and I have fun together and find new ways to enjoy our time together"],
//        "Image":"",
//        "Description":"",
//        "Title":"Family"
//    ],
//    "CAREER":[
//        "Messages": ["I play a significant role in my own career success.",
//    "I engage in work that impacts this world positively.",
//    "My business is growing, expanding, and thriving.",
//    "I may not understand the good in this situation, but it is there.",
//    "Today will be a gorgeous day to remember.",
//    "I deserve to be employed and paid well for my time, efforts, and ideas. Each day, I am closer, to finding the perfect job for me.",
//    "Mistakes and setbacks are stepping stones to my success because I learn from them.",
//    "I welcome financial abundance. I am capable of wisely handling financial success.",
//    "I am self-reliant, creative, and persistent in whatever I do.",
//    "I deserve to be rich."],
//        "Image":"",
//        "Description":"",
//        "Title":"Career"
//    ]
//]

var videoPlayer = AVPlayer()
var playerLayer:AVPlayerLayer?
//var videoCacheManager : VideoCache?


let defaultGradientColor : UIColor = colorWithHexString(hexString: "#38332A")

extension UIImage{
    func roundedImageWithBorder(width: CGFloat) -> UIImage? {
        let green = UIColor.systemGreen//colorWithHexString(hexString: "#2FD88E")

            let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
            imageView.contentMode = .center
            imageView.image = self
            imageView.layer.cornerRadius = square.width/2
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
            imageView.layer.borderWidth = width
            imageView.layer.borderColor = green.cgColor
            UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
            imageView.layer.render(in: context)
            var result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            result = result?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            return result
        }
    
    func resizedImage() -> UIImage {
        let targetSize = CGSize(width: 30, height: 30)
        return UIGraphicsImageRenderer(size:targetSize).image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
//    func resizedImage() -> UIImage {
//        let im = self
//        let newWidth : CGFloat = 60
//        let scale = newWidth / self.size.width
//        let newHeight = self.size.height * scale
//        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newWidth))
//        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newWidth))
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return newImage!
//    }
    
}
