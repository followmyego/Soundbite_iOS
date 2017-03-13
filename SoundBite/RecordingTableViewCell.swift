//
//  RecordingTableViewCell.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-13.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class RecordingTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recordingImageview: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    var recording: Recording! {
        didSet {
            update()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //view = loadViewFromNib()
        //self.addSubview(view)
        
        Bundle.main.loadNibNamed("RecordingTableViewCell", owner: self, options: nil)
        self.addSubview(self.view)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(forClass: self)
        let nib = UINib(nibName: "RecordingTableViewCell", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }*/
    
    fileprivate func update() {
        
        nameLabel.text = recording.name
        dateLabel.text = convertToDateString(recording.creationDate)
        durationLabel.text = convertToTimeString()
        playButton.isEnabled = true
        
    }
    
    fileprivate func convertToDateString(_ date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        let dateString = dateFormatter.string(from: date)
        
        return dateString
        
    }
    
    
    fileprivate func convertToTimeString() -> String {
        
        let minutes = Int(recording.duration) / 60
        let seconds = Int(recording.duration.truncatingRemainder(dividingBy: 60))
        
        return "\(minutes):\(seconds)"
        
    }
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        SoundController.shared.playAudio(recording.url)
        
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        
        
    }
}
