//
//  SoundController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

struct DirectoryNames {
    
    static let rawfiles = "rawfiles"
    static let soundbits = "soundbits"
    static let finishedFiles = "soundbites"
    
}

class SoundController: NSObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    static let shared = SoundController()
        
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
        
    }
    
    func saveSoundbite() {
        
        let markerDouble = Date().timeIntervalSince(startTime)
        
        let marker = Int(markerDouble)
        
        self.markers.append(marker)
        
        print(marker)
        
    }
    
    func finishedSoundbite() {
        
        self.stopRecording()
        
        let audioURL = self.recorder.url
        
        let asset = AVAsset.init(url: audioURL)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let directoryPath = URL(fileURLWithPath: documentsDirectory.appendingPathComponent(DirectoryNames.soundbits).path)
        deleteAllRecordings(directoryPath)
        exportAsset(asset, directoryPath)
        
    }
    
    func restartRecording() {
        
        if recorder != nil && recorder.isRecording {
            recorder.deleteRecording()
        }
        
    }
    
    func exportAsset(_ asset: AVAsset, _ directory: URL) {
        
        let fileManager = FileManager.default
        
        let filesToExport = markers.count
        var exportedFiles = 0
        
        for marker in self.markers {
            let soundbitName = "\(getFileCount(DirectoryNames.soundbits)).m4a"
            let soundbitURL = URL(fileURLWithPath: directory.appendingPathComponent(soundbitName).path)
            if fileManager.fileExists(atPath: soundbitURL.absoluteString) {
                print("File exists")
            }
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            exporter?.outputFileType = AVFileTypeAppleM4A
            exporter?.outputURL = URL(fileURLWithPath: soundbitURL.path)
            let startTime = CMTimeMake(Int64(marker - 10), 1)
            let stopTime = CMTimeMake(Int64(marker), 1)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter?.timeRange = exportTimeRange
            
            exporter?.exportAsynchronously() {
                switch exporter!.status {
                case .failed:
                    print("Export failed")
                    break
                case .cancelled:
                    print("Export cancelled")
                    break
                default:
                    print("Export Successfully Finished")
                    break
                }
            
                exportedFiles += 1
                if exportedFiles == filesToExport {
                    //DispatchQueue.main.async {
                        self.mergeAudio()
                    //}
                }
                
            }
        }
        
    }
    
    func mergeAudio() {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let soundbitDirectoryPath = documentsDirectory.appendingPathComponent(DirectoryNames.soundbits)
        
        //get all audio files from directory
        
        let soundbits = try? FileManager.default.contentsOfDirectory(atPath: soundbitDirectoryPath.path)
        
        var mergeURLs = [URL]()
        
        for soundbit in soundbits! {
            //let soundbitURL = URL(fileURLWithPath: soundbitDirectoryPath.appendingPathComponent(soundbit).path)
            let soundbitPath = soundbitDirectoryPath.appendingPathComponent(soundbit)
            let soundbitURL = URL(fileURLWithPath: soundbitPath.path)
            mergeURLs.append(soundbitURL)
        }
        
        let composition = AVMutableComposition()
        
        for i in 0..<mergeURLs.count {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            
            let avAsset = AVURLAsset(url: mergeURLs[i])
            let track = avAsset.tracks(withMediaType: AVMediaTypeAudio)[0]
            let timeRange = CMTimeRangeMake(kCMTimeZero, track.timeRange.duration)
            
            try? compositionTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
            
        }
        
        let finishedFilesDirectoryPath = documentsDirectory.appendingPathComponent(DirectoryNames.finishedFiles)
        let finishedFileURL = finishedFilesDirectoryPath.appendingPathComponent("\(getFileCount(DirectoryNames.finishedFiles)).m4a")
        
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileTypeAppleM4A
        assetExport?.outputURL = finishedFileURL
        
        assetExport?.exportAsynchronously {
            switch assetExport!.status {
            case .failed:
                print("Failed")
                break
            case .cancelled:
                print("Cancelled")
                break
            default:
                print("Successfully exported!")
                break
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
            recordWithPermission()
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
            recordWithPermission()
        }
        
    }
    
    func recordWithPermission() {

        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    self.setupRecorder()
                    self.recorder.record()
                    print("WORKS")
                    
                } else {
                    print("Permission to record not granted")
                }
            })
        } else {
            print("request RecordPermission unrecognized")
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
    
    func deleteAllRecordings(_ directoryPath: URL) {
        
        let fileManager = FileManager.default
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directoryPath.path)
            var recordings = files.filter( { (name: String) -> Bool in
                return (name.hasPrefix("recording") && name.hasSuffix("m4a"))
            })
            for i in 0 ..< recordings.count {
                let path = directoryPath.appendingPathComponent(recordings[i]).path
                
                print("removing \(path)")
                do {
                    try fileManager.removeItem(atPath: path)
                } catch let error as NSError {
                    NSLog("could not remove \(path)")
                    print(error.localizedDescription)
                }
            }
            
        } catch let error as NSError {
            print("could not get contents of directory at \(directoryPath)")
            print(error.localizedDescription)
        }
        
    }
    
    func playAudio(_ url: URL) {
        
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
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
