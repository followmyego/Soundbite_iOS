//
//  SoundController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

protocol SoundControllerDelegate {
    
    
    
}

struct DirectoryNames {
    
    static let rawfiles = "rawfiles"
    static let soundbits = "soundbits"
    static let finishedFiles = "soundbites"
    
}

class SoundController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    var delegate: SoundControllerDelegate?
    
    let session = AVAudioSession.sharedInstance()
    
    var recorder: AVAudioRecorder!
    var player: AVAudioPlayer!
    
    var markers = [Int]()
    
    var startTime = Date()
    
    override init() {
        super.init()
        
        self.createDirectory(DirectoryNames.rawfiles)
        self.createDirectory(DirectoryNames.soundbits)
        self.createDirectory(DirectoryNames.finishedFiles)
        
        self.setupRecorder()
        self.startRecording()
        
    }
    
    func saveSoundbite() {
        
        let markerDouble = Date().timeIntervalSince(startTime)
        
        let marker = Int(markerDouble)
        
        self.markers.append(marker)
        
    }
    
    func finishedSoundbite() {
        
        self.stopRecording()
        
        let audioURL = self.recorder.url
        
        let asset = AVAsset.init(url: audioURL)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryPath = documentsDirectory.appendingPathComponent(DirectoryNames.soundbits)
        exportAsset(asset, directoryPath)
        
    }
    
    func exportAsset(_ asset: AVAsset, _ directory: URL) {
        
        let fileManager = FileManager.default
        
        for marker in self.markers {
            if marker < 10 { continue }
            let soundbitName = "\(getFileCount(DirectoryNames.soundbits)).m4a"
            let soundbitPath = directory.appendingPathComponent(soundbitName)
            if fileManager.fileExists(atPath: soundbitPath.absoluteString) {
                print("File exists")
            }
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            exporter?.outputFileType = AVFileTypeAppleM4A
            exporter?.outputURL = soundbitPath
            let startTime = CMTimeMake(Int64(marker - 10), 1)
            let stopTime = CMTimeMake(Int64(marker), 1)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter?.timeRange = exportTimeRange
            
            exporter?.exportAsynchronously() {
                switch exporter!.status {
                case .cancelled:
                    print("Export failed")
                    break
                case .failed:
                    print("Export cancelled")
                    break
                default:
                    print("Export Successfully Finished")
                    break
                }
            }
        }
        
    }
    
    func getFileCount(_ directoryName: String) -> Int {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryPath = documentsDirectory.appendingPathComponent(directoryName)
        let dirContents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath.path)
        let count = dirContents?.count
        return count ?? 0
    }
    
    func createDirectory(_ name: String) {
    
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent(name)
        
        if FileManager.default.fileExists(atPath: dataPath.path) {
            return
        }
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
        
    }
    
    func setupRecorder() {
        
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH:mm:ss"
        //let currentFileName = "recording-\(format.string(from: Date())).m4a"
        let currentFileName = "recording\(getFileCount(DirectoryNames.rawfiles)).m4a"
        print("Current filename: \(currentFileName)")
        print()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let rawFileDirectory = documentsDirectory.appendingPathComponent(DirectoryNames.rawfiles)
        let soundFileURL = rawFileDirectory.appendingPathComponent(currentFileName)
        print("Writing to url: '\(soundFileURL)'")
        print()
        
        /*if FileManager.default.fileExists(atPath: soundFileURL.absoluteString) {
            // probably won't happen. want to do something about it?
            print("File \(soundFileURL.absoluteString) exists")
        }*/
        
        let recordSettings:[String : AnyObject] = [
            AVFormatIDKey:             NSNumber(value: kAudioFormatAppleLossless),
            AVEncoderAudioQualityKey : NSNumber(value:AVAudioQuality.max.rawValue),
            AVEncoderBitRateKey :      NSNumber(value:320000),
            AVNumberOfChannelsKey:     NSNumber(value:2),
            AVSampleRateKey :          NSNumber(value:44100.0)
        ]
        
        do {
            recorder = try AVAudioRecorder(url: soundFileURL, settings: recordSettings)
            recorder.delegate = self
            recorder.prepareToRecord()
            recorder.record()
        } catch let error {
            recorder = nil
            print(error.localizedDescription)
        }
        
    }
    
    func startRecording() {
        
        if player != nil && player.isPlaying {
            player.stop()
        }
        
        if recorder == nil {
            print("recorder nil")
            /*recorder.setTitle("Pause", for: .normal)
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recordWithPermission(true)*/
            return
        }
        
        if recorder != nil && recorder.isRecording {
            print("pausing")
            recorder.pause()
            //recordButton.setTitle("Continue", for: .normal)
            
        } else {
            print("recording")
            /*recordButton.setTitle("Pause", for:UIControlState())
            playButton.isEnabled = false
            stopButton.isEnabled = true
            recorder.record()*/
            recordWithPermission(false)
        }
        
    }
    
    func recordWithPermission(_ setup:Bool) {

        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    self.recorder.record()
                    print("WORKS")
                    
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("requestRecordPermission unrecognized")
        }
        
    }
    
    func setSessionPlayAndRecord() {
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch let error as NSError {
            print("could not set session category")
            print(error.localizedDescription)
        }
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("could not make session active")
            print(error.localizedDescription)
        }
        
    }
    
    func stopRecording() {
        
        self.recorder.stop()
        print(self.recorder.url)
        
    }
    
    func deleteAllRecordings() {
        let docsDir =
            NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: docsDir)
            var recordings = files.filter( { (name: String) -> Bool in
                return (name.hasPrefix("recording") && name.hasSuffix("m4a"))
            })
            for i in 0 ..< recordings.count {
                let path = docsDir + "/" + recordings[i]
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(docsDir)")
            print(error.localizedDescription)
        }
        
    }
    
    func startPlaying() {
        
        var url:URL?
        if self.recorder != nil {
            url = self.recorder.url
        } else {
            return
        }
        
        print("playing \(url)")
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url!)
            player.delegate = self
            player.prepareToPlay()
            player.volume = 1.0
            player.play()
        } catch let error as NSError {
            self.player = nil
            print(error.localizedDescription)
        }
        
    }
        
    
}
