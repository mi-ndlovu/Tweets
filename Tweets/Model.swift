//
//  Model.swift
//  Tweets
//
//  Created by Mbongeni NDLOVU on 2018/10/05.
//  Copyright © 2018 mndlovu. All rights reserved.
//

import Foundation

struct Tweet: CustomStringConvertible {
    
    let name: String
    let text: String
    let date: String
    
    var description: String {
        return "\(name): \(text)"
    }
    
}
