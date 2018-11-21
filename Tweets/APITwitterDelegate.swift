//
//  APITwitterDelegate.swift
//  Tweets
//
//  Created by Mbongeni NDLOVU on 2018/10/06.
//  Copyright © 2018 mndlovu. All rights reserved.
//

import Foundation

protocol APITwitterDelegate: class {
    
    func processRecievedTweets(tweets: [Tweet])
    func handleError(error: NSError)
}
