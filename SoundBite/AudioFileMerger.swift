//
//  AudioFileMerger.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-14.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

class AudioFileMerger {
    
    static let shared = AudioFileMerger()
    
    func mergeAudio(_ targetFilename: String) {
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let soundbitDirectoryPath = documentsDirectory.appendingPathComponent(DirectoryNames.soundbits)
        
        //get all audio files from directory
        
        let soundbits = try? FileManager.default.contentsOfDirectory(atPath: soundbitDirectoryPath.path)
        
        var mergeURLs = [URL]()
        
        for i in 0..<soundbits!.count {
            let soundbit = soundbits![i]
            let soundbitPath = soundbitDirectoryPath.appendingPathComponent(soundbit)
            let soundbitURL = URL(fileURLWithPath: soundbitPath.path)
            mergeURLs.append(soundbitURL)
        }
        
        let composition = AVMutableComposition()
        
        for i in 0..<mergeURLs.count {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: CMPersistentTrackID())
            
            let avAsset = AVURLAsset(url: mergeURLs[i])
            let track = avAsset.tracks(withMediaType: AVMediaTypeAudio).first!
            let timeRange = CMTimeRangeMake(kCMTimeZero, track.timeRange.duration)
            
            try? compositionTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
            
        }
        
        let finishedFilesDirectoryPath = documentsDirectory.appendingPathComponent(DirectoryNames.finishedFiles)
        let finishedFileURL = finishedFilesDirectoryPath.appendingPathComponent(targetFilename)
        
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
    
}
