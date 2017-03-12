//
//  Recording.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

class Recording {
        
    var name: String!
    var duration: Double!
    var creationDate: Date!
    var url: URL!
    
    init(_ name: String, _ duration: Double, _ creationDate: Date, _ url: URL) {
        
        self.name = name
        self.duration = duration
        self.creationDate = creationDate
        self.url = url
        
    }
    
}
