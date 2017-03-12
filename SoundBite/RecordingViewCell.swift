//
//  CustomTableViewCell.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit

class RecordingViewCell: UITableViewCell {
    
    var recording: Recording! {
        didSet {
            self.setup()
        }
    }
    
    var titleLabel: UILabel!
    var recordingImageView: UIImageView!
    var playButton: UIButton!
    var editButton: UIButton!
    var dateLabel: UILabel!
    var recordingDurationLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setup() {
        
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.titleLabel.text = self.recording.name
        self.textLabel?.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.textLabel?.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 18)
        contentView.addSubview(titleLabel)
        
        self.recordingImageView = UIImageView(frame: CGRect.zero)
        self.recordingImageView.image = UIImage(imageLiteralResourceName: "soundbiteImageSaved")
        contentView.addSubview(recordingImageView)
        
        self.playButton = UIButton(frame: CGRect.zero)
        self.playButton.setImage(UIImage(imageLiteralResourceName: "playButton"), for: .normal)
        recordingImageView.addSubview(playButton)
        
        self.editButton = UIButton(frame: CGRect.zero)
        self.editButton.setImage(UIImage(imageLiteralResourceName: "editPencil"), for: .normal)
        recordingImageView.addSubview(editButton)
        
        self.dateLabel = UILabel(frame: CGRect.zero)
        self.dateLabel.text = "\(recording.creationDate)"
        self.dateLabel.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.dateLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 14)
        contentView.addSubview(dateLabel)
        
        self.recordingDurationLabel = UILabel(frame: CGRect.zero)
        self.recordingDurationLabel.text = "\(recording.duration)"
        self.recordingDurationLabel.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.recordingDurationLabel.textAlignment = .right
        self.recordingDurationLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 14)
        contentView.addSubview(recordingDurationLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = contentView.bounds.size.width
        let height = contentView.bounds.size.height
        
        self.titleLabel.frame = CGRect(x: width*0.01, y: height*0.01, width: width*0.98, height: height*0.25)
        self.recordingImageView.frame = CGRect(x: width*0.01, y: height*0.25, width: width*0.98, height: height*0.5)
        self.playButton.frame = CGRect(x: 0, y: 0, width: recordingImageView.bounds.width*0.15, height: recordingImageView.bounds.height)
        self.editButton.frame = CGRect(x: recordingImageView.bounds.width*0.85, y: 0, width: recordingImageView.bounds.width*0.15, height: recordingImageView.bounds.height)
        self.dateLabel.frame = CGRect(x: width*0.01, y: height*0.75, width: width*0.49, height: height*0.2)
        self.recordingDurationLabel.frame = CGRect(x: width*0.5, y: height*0.75, width: width*0.49, height: height*0.2)
        
        
        
    }
    
}
