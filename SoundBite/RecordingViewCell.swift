//
//  CustomTableViewCell.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit

class RecordingViewCell: UIView {
    
    var titleLabel: UILabel!
    var recordingImageView: UIImageView!
    var playButton: UIButton!
    var editButton: UIButton!
    var dateLabel: UILabel!
    var recordingDurationLabel: UILabel!
    
    init(frame: CGRect, recording: Recording) {
        super.init(frame: frame)
        
        setup()
        
    }
    
    func setup() {
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
