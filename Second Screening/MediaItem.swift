//
//  MediaItem.swift
//  Second Screening
//
//  Created by Sinan Demirci on 19.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit
import Alamofire
import SSZipArchive

struct MediaInformation {
    var type: String
    var imdbID: String
    var runtime: String
    var seasonAndEpisode: String
    var cover: UIImage
    var title: String
    var episodeTitle: String
    var subtitle: String
    var fileName:String
    var encoding: String
    var link: String
}

class MediaItem: NSObject {
    
    var mediaType: String
    var imdbID: String
    var runtime: String
    var seasonAndEpisode: String
    var coverImage: UIImage
    var mediaTitle: String
    var episodeTitle: String
    var subtitleTitle: String
    var fileName: String
    var encoding: String
    var downloadLink: URL
    var fileManager: FileManager
    var srtFilePath: URL

    init(info: MediaInformation) {
        self.mediaType = info.type
        self.imdbID = info.imdbID
        self.runtime = info.runtime
        self.seasonAndEpisode = info.seasonAndEpisode
        self.coverImage = info.cover
        self.mediaTitle = info.title
        self.episodeTitle = info.episodeTitle
        self.subtitleTitle = info.subtitle
        self.fileName = info.fileName
        self.encoding = info.encoding
        self.downloadLink = URL(string: info.link)!
        self.fileManager = FileManager()
        self.srtFilePath = URL(fileURLWithPath: "")
    }
    
    func downloadSubtitlesZip(completion: @escaping (URL, String) -> Void) {
        let saveUrl = self.subtitleTitle + ".zip"
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let directoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let file = directoryUrl.appendingPathComponent(saveUrl, isDirectory: false)
            return (file, [.createIntermediateDirectories, .removePreviousFile])
        }
        Alamofire.download(downloadLink, to: destination).responseData { response in
            if response.result.error == nil {
                do {
                    let downloadPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Subtitles")
                    if !self.fileManager.fileExists(atPath: downloadPath.path) {
                        try self.fileManager.createDirectory(at: downloadPath, withIntermediateDirectories: true, attributes: [:])
                        print("directory created")
                    }
                    self.srtFilePath = downloadPath.appendingPathComponent(self.fileName)
                    if self.fileManager.fileExists(atPath: self.srtFilePath.path) {
                        completion(self.srtFilePath, self.encoding)
                    } else {
                        print("unzipping file")
                        SSZipArchive.unzipFile(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(saveUrl).path, toDestination: downloadPath.path)
                        self.srtFilePath = downloadPath.appendingPathComponent(self.fileName)
                        completion(self.srtFilePath, self.encoding)
                    }
                    print("downloaded .srt file")
                } catch {
                    print("Unzipping error")
                }
            } else {
                print("no download")
            }
        }
    }
}
