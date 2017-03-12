//
//  DrawerView.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class DrawerView: UIView, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer!
    
    var headerView: UIImageView!
    var headerLabel: UILabel!
    
    var recordingViewCells = [RecordingViewCell]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cleanup() {
        
        for recordingCell in recordingViewCells {
            recordingCell.removeFromSuperview()
        }
        
        recordingViewCells.removeAll()
        
    }
    
    func setup() {
        
        cleanup()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingsDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.finishedFiles)
        
        var recordingURLs = [URL]()
        
        do {
            recordingURLs = try FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: nil, options: [])
        } catch let error {
            print(error)
        }
        
        
        for url in recordingURLs {
            let asset = AVAsset(url: url)
            let name = url.deletingPathExtension().lastPathComponent
            let recording = Recording(name, asset.duration.seconds, asset.creationDate!.dateValue!, url)
            
            let recordingViewCell = RecordingViewCell(frame: CGRect(), recording: recording)
            recordingViewCells.append(recordingViewCell)
        }
        
    }
    
}
