//
//  srtParser.swift
//  Second Screening
//
//  Created by Sinan Demirci on 20.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit
import AVPlayerViewControllerSubtitles

class SrtParser: NSObject {
    
    var parser: Subtitles
    
    init(fileUrl: URL, enc: String) {
        switch enc {
        case "UTF-8":
            parser = Subtitles(file: fileUrl, encoding: .utf8)
        case "MacRoman":
            parser = Subtitles(file: fileUrl, encoding: .macOSRoman)
        case "CP1252":
            parser = Subtitles(file: fileUrl, encoding: .windowsCP1252)
        case "ASCII":
            parser = Subtitles(file: fileUrl, encoding: .ascii)
        case "ISO-8859-1":
            parser = Subtitles(file: fileUrl, encoding: .isoLatin1)
        case "ISO-8859-2":
            parser = Subtitles(file: fileUrl, encoding: .isoLatin2)
        default:
            parser = Subtitles(file: fileUrl, encoding: .windowsCP1252)
        }
    }
    
    func readSubtitles(time: TimeInterval) -> String {
        guard let subtitles = parser.searchSubtitles(at: time) else { return "" }
        return subtitles
    }

}
