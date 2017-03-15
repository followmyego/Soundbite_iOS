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
    
    var currentTimeTick: UIView!
    var timer: Timer!
    
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
        
        currentTimeTick = UIView(frame: CGRect(x: -recordingImageview.bounds.width*0.01, y: 0, width: recordingImageview.bounds.width*0.01, height: recordingImageview.bounds.height))
        currentTimeTick.backgroundColor = .white
        recordingImageview.addSubview(currentTimeTick)
        
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
    
    func moveTimeTick(timer: Timer) {
        if player == nil { return }
        let ratio = player.currentTime / player.duration
        currentTimeTick.center.x = (recordingImageview.bounds.width-editButton.bounds.width)*CGFloat(ratio)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(moveTimeTick(timer:)), userInfo: nil, repeats: true)
        
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
        
        //self.parentViewController?.show(EditSoundbitesViewController(), sender: self)
        
    }
    
    func setupPlayer() {
        
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
        timer.invalidate()
        timer = nil
        playButton.setImage(UIImage(named: "playIcon"), for: .normal)
        self.player = nil
        currentTimeTick.center.x = -recordingImageview.bounds.width*0.01
    }
}
