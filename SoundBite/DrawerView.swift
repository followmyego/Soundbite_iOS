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

class DrawerView: UIView, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var player: AVAudioPlayer!
    
    var headerView: UIImageView!
    var headerLabel: UILabel!
    
    var tableView: UITableView!
    
    var recordings = [Recording]()
    
    var isOpen = false
    
    var statusBarView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        self.backgroundColor = .white
        
        self.statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: UIApplication.shared.statusBarFrame.height))
        self.statusBarView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        self.addSubview(statusBarView)
        
        headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height*0.25))
        self.addSubview(headerView)
        
        headerLabel = UILabel(frame: CGRect(x: self.bounds.width*0.05, y: self.bounds.height*0.05, width: self.bounds.width*0.9, height: self.bounds.height*0.15))
        headerLabel.text = "Your Bites"
        headerLabel.textColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        headerLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 24)
        self.addSubview(headerLabel)
        
        tableView = UITableView(frame: CGRect(x: self.bounds.width*0.05, y: headerView.bounds.height, width: self.bounds.width*0.9, height: self.bounds.height-headerView.bounds.height), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordingViewCell.self, forCellReuseIdentifier: "Cell")
        self.addSubview(tableView)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let recordingsDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.finishedFiles)
        
        var recordingURLs = [URL]()
        
        do {
            recordingURLs = try FileManager.default.contentsOfDirectory(at: recordingsDirectory, includingPropertiesForKeys: nil, options: [])
        } catch let error {
            print(error)
        }
        
        recordings.removeAll()
        
        for url in recordingURLs {
            let asset = AVAsset(url: url)
            let name = url.deletingPathExtension().lastPathComponent
            let recording = Recording(name, asset.duration.seconds, asset.creationDate!.dateValue!, url)
            
            recordings.append(recording)
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecordingViewCell
        
        cell.recording = self.recordings[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.bounds.height*0.2
        
    }
    
}
