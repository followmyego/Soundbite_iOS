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

class DrawerView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var player: AVAudioPlayer!
    
    var headerView: UIView!
    var headerLabel: UILabel!
    var subHeaderLabel: UILabel!
    
    var tableView: UITableView!
    
    var recordings = [Recording]()
    
    var isOpen = false
    
    var views = [UIView]()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        self.backgroundColor = .white
                
        /*self.layer.shadowOffset = CGSize(width: self.bounds.width*0.25, height: 5)
        self.layer.shadowOpacity = 0.25
        self.layer.shadowRadius = 10*/
        
        headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height*0.22))
        headerView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 238/255, blue: 238/255, alpha: 1)
        self.addSubview(headerView)
        
        headerLabel = UILabel(frame: CGRect(x: self.bounds.width*0.15, y: self.bounds.height*0.075, width: self.bounds.width*0.8, height: self.bounds.height*0.15))
        headerLabel.text = "My Bites"
        headerLabel.textColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        headerLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 28)
        headerLabel.sizeToFit()
        self.addSubview(headerLabel)
        
        subHeaderLabel = UILabel(frame: CGRect(x: self.bounds.width*0.15, y: headerLabel.center.y + headerLabel.bounds.height*0.66, width: self.bounds.width*0.8, height: self.bounds.height*0.1))
        subHeaderLabel.text = "0 out of 5"
        subHeaderLabel.textColor = UIColor(colorLiteralRed: 255/255, green: 156/255, blue: 132/255, alpha: 1)
        subHeaderLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 18)
        subHeaderLabel.sizeToFit()
        //self.addSubview(subHeaderLabel)
        
        let tableViewY = headerView.bounds.height
        
        tableView = UITableView(frame: CGRect(x: self.bounds.width*0.05, y: tableViewY, width: self.bounds.width*0.9, height: self.bounds.height-tableViewY))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordingTableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        self.addSubview(tableView)
        
        /*var yHeight = headerView.bounds.height
        
        var i = 0
        
        for recording in recordings {
            let view = RecordingViewCell(frame: CGRect(x: self.bounds.width*0.05, y: yHeight, width: self.bounds.width*0.9, height: self.bounds.height*0.2), recording)
            view.isUserInteractionEnabled = true
            views.append(view)
            self.addSubview(view)
            
            i += 1
            
            yHeight += view.bounds.height
        }*/
        
    }
    
    func updateRecordings() {
        
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
            let url = URL(fileURLWithPath: url.path)
            print(url)
            let asset = AVAsset(url: url)
            let name = url.deletingPathExtension().lastPathComponent
            if asset.duration.seconds == 0 || asset.creationDate == nil { break }
            let recording = Recording(name, asset.duration.seconds, asset.creationDate!.dateValue!, url)
            
            recordings.append(recording)
        }
        
        recordings.sort(by: { $0.creationDate!.timeIntervalSince1970 > $1.creationDate!.timeIntervalSince1970 })
        
        subHeaderLabel.text = "\(recordingURLs.count) out of 5"
        
        tableView.reloadData()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! RecordingTableViewCell
        
        let recording = recordings[indexPath.row]
        
        cell.recording = recording
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.bounds.height*0.2
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recording = recordings[indexPath.row]
            
            RecorderController.shared.delete(recording: recording)
            
            self.recordings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        
    }
    
}
