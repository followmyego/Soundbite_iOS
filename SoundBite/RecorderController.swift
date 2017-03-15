//
//  SoundController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

/*
 
 #FF5F5F
 #FF9C84
 #B16654
 #FFEEEE
 #CBCBCB
 
*/

struct DirectoryNames {
    
    static let rawfiles = "rawfiles"
    static let soundbits = "soundbits"
    static let finishedFiles = "soundbites"
    
}

class RecorderController: NSObject, AVAudioRecorderDelegate {
    
    static let shared = RecorderController()
    
    let fileManager = FileManager.default
    
    var audioRecorder: AVAudioRecorder!
    
    var lastRecordPath: URL!
    
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    var rawDirectory: URL!
    var bitsDirectory: URL!
    var finishedDirectory: URL!
    
    var startDate = Date()
    var markers = [Int]()
    
    fileprivate lazy var recordingSettings: [String: AnyObject] = {
        
        return [
            
            AVFormatIDKey:             NSNumber(value:kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:1),
            AVSampleRateKey :          NSNumber(value:44100.0)
            
        ]
        
    }()
    
    override init() {
        super.init()
        
        createDirectory(DirectoryNames.rawfiles)
        createDirectory(DirectoryNames.soundbits)
        createDirectory(DirectoryNames.finishedFiles)
        
        rawDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.rawfiles)
        bitsDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.soundbits)
        finishedDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.finishedFiles)
        
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionRouteDidChange(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
        
    }
    
    func startRecording() {
    
        let rawURL = rawDirectory.appendingPathComponent("\(getFileCount(rawDirectory)).m4a")
        let url = URL(fileURLWithPath: rawURL.path)
        
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            audioRecorder.record()
        } catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func rename(file fromPath: URL, to newName: String) {
        
        var destinationPath = fromPath.deletingPathExtension()
        destinationPath = destinationPath.appendingPathComponent("\(newName).m4a")
        
        do {
            try FileManager.default.moveItem(at: fromPath, to: destinationPath)
        } catch {
            print(error)
        }
        
    }
    
    func delete(recording: Recording) {
        
        if let url = recording.url {
        
            do {
                try fileManager.removeItem(at: URL(fileURLWithPath: url.path))
            } catch let error {
                print(error.localizedDescription)
            }
            
        } else {
            print("Invalid url")
        }
        
    }
    
    func finishRecording(_ soundbiteName: String) {
        
        if audioRecorder != nil && audioRecorder.isRecording {
            
            audioRecorder.stop()
            
            let url = audioRecorder.url
            let asset = AVAsset(url: url)
            AssetExporter.shared.exportAsset(asset, bitsDirectory, soundbiteName, markers)
            
            audioRecorder = nil
            
            setSessionAndRecord()
            
        }
        
    }
    
    func cancelRecording() {
        
        if audioRecorder != nil && audioRecorder.isRecording {
            
            audioRecorder.deleteRecording()
            
        }
        
    }
    
    func saveSoundbite() {
        let marker = Int(Date().timeIntervalSince(startDate))
        self.markers.append(marker)
        print(marker)
    }
    
    /*
    
    setuprecorder
    record
    export
    merge
    save
    if file exists
        false
    else
        true
    
    */
    
    fileprivate func createDirectory(_ name: String) {
        
        let dataPath = documentsDirectory.appendingPathComponent(name)
        
        if fileManager.fileExists(atPath: dataPath.path) {
            return
        }
        
        do {
            try fileManager.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
    }
    
    fileprivate func deleteAllRecordings(_ directoryPath: URL) {
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
            var recordings = files.filter( { (name: String) -> Bool in
                return (name.hasSuffix("m4a"))
            })
            for i in 0 ..< recordings.count {
                
                let path = directoryPath.appendingPathComponent(recordings[i]).path
                
                print("Removing \(path)")
                
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("Could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("Could not get contents of directory at \(directoryPath)")
            print(error.localizedDescription)
        }
        
    }
    
    fileprivate func recordWithPermission() {
        
        if (AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            
            AVAudioSession.sharedInstance().requestRecordPermission() { [weak self]
                granted in
                
                if granted {
                    print("Permission to record granted")
                    self?.audioRecorder.record()
                } else {
                    print("Permission to record not granted")
                }
            }
        } else {
            print("Request RecordPermission unrecognized")
        }
        
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        
        
    }
    
    @objc fileprivate func audioSessionRouteDidChange(notification: Notification) {
        
        print("AVAudioSessionRouteDidChange notification received")
        
        
    }
    
    fileprivate func getFileCount(_ directory: URL) -> Int {
        
        let dirContents = try? fileManager.contentsOfDirectory(atPath: directory.path)
        let count = dirContents?.count
        return count ?? 0
    }
    
    func setSessionAndRecord() {
        
        deleteAllRecordings(rawDirectory)
        deleteAllRecordings(bitsDirectory)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
            session.requestRecordPermission() { [weak self]
                granted in
                
                if granted {
                    print("Permission granted")
                    self?.startDate = Date()
                    self?.markers.removeAll()
                    self?.startRecording()
                } else {
                    print("Permission denied")
                }
                
            }
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
        
    }
    
}
