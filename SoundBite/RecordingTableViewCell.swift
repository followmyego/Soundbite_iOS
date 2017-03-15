//
//  RecordingTableViewCell.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-13.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@IBDesignable class RecordingTableViewCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var recordingImageview: UIImageView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var view: UIView!
    
    var player: AVAudioPlayer!
    
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
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
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
        
        var zeroPad1 = ""
        var zeroPad2 = ""
        
        if minutes < 10 {
            zeroPad1 = "0"
        }
        if seconds < 10 {
            zeroPad2 = "0"
        }
        
        return "\(zeroPad1)\(minutes):\(zeroPad2)\(seconds)"
        
    }
    
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        //SoundController.shared.playAudio(recording.url)
        if player != nil {
            if player.isPlaying {
                player.pause()
                playButton.setImage(UIImage(named: "playIcon"), for: .normal)
            } else {
                player.play()
                playButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
            }
        } else {
            setupPlayer()
        }
    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
    }
    
    func setupPlayer() {
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
        
        do {
            try player = AVAudioPlayer(contentsOf: recording.url)
            player.delegate = self
            player.volume = 1.0
            player.prepareToPlay()
            player.play()
            playButton.setImage(UIImage(named: "pauseIcon"), for: .normal)
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setImage(UIImage(named: "playIcon"), for: .normal)
    }
}
