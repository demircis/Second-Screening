//
//  SecondViewController.swift
//  Second Screening
//
//  Created by Sinan Demirci on 19.05.18.
//  Copyright © 2018 Sinan Demirci. All rights reserved.
//

import UIKit

class SubtitlesViewController: UIViewController, SrtDelegate {
    
    var srtParser: SrtParser?
    var timer = Timer()
    var startTime: Date?
    var currTime = Date()
    var pauseStarted: Date?
    var pausedTime: TimeInterval = 0.0
    var totalPausedTime:TimeInterval = 0.0
    var timeDifference: TimeInterval = 0.0
    var truncatedTimeDifference: Double = 0.0
    var textToSet: String = ""
    var runtimeToSet: (Int, Int, Int) = (0,0,0)
    var runtime: String = ""
    var isPaused: Bool = false
    var started: Bool = true
    @IBOutlet weak var runtimeText: UITextView!
    @IBOutlet weak var subtitlesText: UITextView!
    @IBOutlet weak var playButton: UIBarButtonItem!
    @IBOutlet weak var pauseButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        playButton.action = #selector(startTimer)
        pauseButton.action = #selector(pauseTimer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func passSrtInfo(fileURL: URL, encoding: String, runtime: String) {
        print("url received")
        self.runtime = runtime
        srtParser = SrtParser(fileUrl: fileURL, enc: encoding)
    }
    
    @objc func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(startDisplayingSubtitles), userInfo: nil, repeats: true)
        if started {
            startTime = timer.fireDate
            started = false
        }
        isPaused = false
        totalPausedTime += pausedTime
    }
    
    @objc func pauseTimer() {
        pauseStarted = Date()
        isPaused = true
    }
    
    @objc func startDisplayingSubtitles() {
        if isPaused {
            pausedTime = Date().timeIntervalSince(pauseStarted!)
            currTime = Date().addingTimeInterval(-(totalPausedTime+pausedTime))
        } else {
            currTime = Date().addingTimeInterval(-totalPausedTime)
        }
        timeDifference = currTime.timeIntervalSince(startTime!)
        truncatedTimeDifference = truncate(number: timeDifference.magnitude)
        textToSet = (srtParser?.readSubtitles(time: truncatedTimeDifference))!
        if textToSet != "" {
            //print(textToSet ?? "nothing")
            //subtitlesText.text = textToSet
        }
        runtimeToSet = secondsToHoursMinutesSeconds(seconds: Int(truncatedTimeDifference))
        runtimeText.text = String(format: "%02d:%02d:%02d / ", runtimeToSet.0, runtimeToSet.1, runtimeToSet.2) + self.runtime
        subtitlesText.text = textToSet
    }
    
    func truncate(number: Double) -> Double {
        return floor(number*1000)/1000
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

}

