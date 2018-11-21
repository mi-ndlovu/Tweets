//
//  APIController.swift
//  Tweets
//
//  Created by Mbongeni NDLOVU on 2018/10/06.
//  Copyright © 2018 mndlovu. All rights reserved.
//

import Foundation


class APIController {
    
    weak var delegate : APITwitterDelegate?
    let token : String
    var tweets: [Tweet] = []
    
    init(delegate: APITwitterDelegate?, token: String) {
        self.delegate = delegate
        self.token = token
    }
    
    // parameter type Array<Dictionary<String, AnyObject>>
    func parseTwitterResponse(_ dic : [[String: AnyObject]]) {
        for t in dic {
            let tweet = t as NSDictionary
            let name = (tweet.value(forKey: "user")! as AnyObject).value(forKey: "name")! as! String
            let text = tweet.value(forKey: "text")! as! String
            let date = tweet.value(forKey: "created_at") as! String
            let tmp = Tweet(name: name,text: text, date: date)
            self.tweets.append(tmp)
        }
        DispatchQueue.main.async {
            self.delegate?.processRecievedTweets(tweets: self.tweets)
        }
    }
    
    
     //request to twitter to get the last 100 tweets containing a string
    func getTweets(_ tweet: String) {
        self.tweets = []
        let urlStr = "https://api.twitter.com/1.1/search/tweets.json?q=\(tweet.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&lang=en&count=100"
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer " + self.token,forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            if let err = error {
                DispatchQueue.main.async {
                    self.delegate?.handleError(error: err as NSError)
                }
            }
            else if let d = data {
                do {
                    if let dic: NSDictionary = try JSONSerialization.jsonObject(with: d, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                        if let tweets = dic.value(forKey: "statuses") as? [[String:AnyObject]] {
                            if tweets.count != 0 {
                                self.parseTwitterResponse(tweets)
                            }
                            else {
                                DispatchQueue.main.async {
                                    let noob : NSError = NSError.init(domain: "Search Not Found", code: 1, userInfo: [:] )
                                    self.delegate?.handleError(error: noob)
                                }
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let noob : NSError = NSError.init(domain: "Missing search input", code: 1, userInfo: [:] )
                                self.delegate?.handleError(error: noob)
                            }
                        }
                        
                    }
                }
                catch (let err) {
                    DispatchQueue.main.async {
                        self.delegate?.handleError(error: err as NSError)
                    }
                }
            }
        }
        task.resume()
    }
}
