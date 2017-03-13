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
    
    var recording: Recording
    
    var titleLabel: UILabel!
    var recordingImageView: UIImageView!
    var playButton: UIButton!
    var editButton: UIButton!
    var dateLabel: UILabel!
    var recordingDurationLabel: UILabel!
    
    init(frame: CGRect, _ recording: Recording) {
        self.recording = recording
        super.init(frame: frame)
        
        self.setup()
        
    }
    
    func setup() {
        
        let width = self.bounds.size.width
        let height = self.bounds.size.height
        
        self.titleLabel = UILabel(frame: CGRect(x: width*0.01, y: height*0.01, width: width*0.98, height: height*0.25))
        self.titleLabel.text = self.recording.name
        self.titleLabel?.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.titleLabel?.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 18)
        self.addSubview(titleLabel)
        
        self.recordingImageView = UIImageView(frame: CGRect(x: width*0.01, y: height*0.3, width: width*0.98, height: height*0.4))
        recordingImageView.isUserInteractionEnabled = true
        self.recordingImageView.image = UIImage(named: "soundbiteImageSaved")
        //called at end of this fucntion: contentView.addSubview(recordingImageView)
        
        self.playButton = UIButton(frame: CGRect(x: 0, y: 0, width: recordingImageView.bounds.width*0.15, height: recordingImageView.bounds.height))
        self.playButton.setImage(UIImage(named: "playIcon"), for: .normal)
        playButton.imageView?.isUserInteractionEnabled = true
        playButton.imageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(playButtonPressed(sender:))))
        playButton.isUserInteractionEnabled = true
        recordingImageView.addSubview(playButton)
        
        self.editButton = UIButton(frame: CGRect(x: recordingImageView.bounds.width*0.85, y: 0, width: recordingImageView.bounds.width*0.15, height: recordingImageView.bounds.height))
        self.editButton.setImage(UIImage(imageLiteralResourceName: "editPencil"), for: .normal)
        editButton.addTarget(self, action: #selector(editButtonPressed(sender:)), for: .touchUpInside)
        recordingImageView.addSubview(editButton)
        
        self.dateLabel = UILabel(frame: CGRect(x: width*0.01, y: height*0.75, width: width*0.49, height: height*0.2))
        self.dateLabel.text = "\(recording.creationDate!)"
        self.dateLabel.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.dateLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 14)
        self.addSubview(dateLabel)
        
        self.recordingDurationLabel = UILabel(frame: CGRect(x: width*0.5, y: height*0.75, width: width*0.49, height: height*0.2))
        self.recordingDurationLabel.text = "\(recording.duration!)"
        self.recordingDurationLabel.textColor = UIColor(colorLiteralRed: 203/255, green: 203/255, blue: 203/255, alpha: 1)
        self.recordingDurationLabel.textAlignment = .right
        self.recordingDurationLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 14)
        self.addSubview(recordingDurationLabel)
        
        self.addSubview(recordingImageView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playButtonPressed(sender: UITapGestureRecognizer) {
        
        SoundController.shared.playAudio(self.recording.url)
        
    }
    
    func editButtonPressed(sender: UIButton) {
        
        
        
    }
    
}
