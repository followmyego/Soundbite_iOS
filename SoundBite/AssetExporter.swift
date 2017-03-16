//
//  ExportController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-14.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import Foundation
import AVFoundation

class AssetExporter {
    
    static let shared = AssetExporter()
    
    init() {}
    
    func exportAsset(_ asset: AVAsset, _ directory: URL, _ targetFilename: String, _ markers: [Int], completion: @escaping (_ success: Bool) -> Void) {
        
        let fileManager = FileManager.default
        
        var lastMarker = 0
        
        var exporters = [AVAssetExportSession]()
        
        for i in 0..<markers.count {
            let marker = markers[i]
            let soundbitName = "\(i).m4a"
            let soundbitURL = URL(fileURLWithPath: directory.appendingPathComponent(soundbitName).path)
            if fileManager.fileExists(atPath: soundbitURL.absoluteString) {
                print("File exists")
            }
            let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
            exporter?.outputFileType = AVFileTypeAppleM4A
            exporter?.outputURL = soundbitURL
            var timeStart = lastMarker
            if marker - timeStart > 10 { timeStart = marker - 10 }
            let startTime = CMTimeMake(Int64(timeStart), 1)
            print("marker=\(marker), timestart=\(timeStart)")
            let stopTime = CMTimeMake(Int64(marker), 1)
            let exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime)
            exporter?.timeRange = exportTimeRange
            exporters.append(exporter!)
            lastMarker = marker
        }
        
        let filesToExport = markers.count
        var exportedFiles = 0
        
        for i in 0..<exporters.count {
            let exporter = exporters[i]
            exporter.exportAsynchronously() {
                switch exporter.status {
                case .failed:
                    print("Export failed")
                    print(exporter.error?.localizedDescription ?? "Unknown Error")
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
                    AudioFileMerger.shared.mergeAudio(targetFilename) {
                        success in
                        
                        completion(success)
                        
                    }
                }
                
            }
        }
        
    }
    
}
