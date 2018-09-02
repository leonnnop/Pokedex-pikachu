//
//  audioPlayer.swift
//  Calculator
//
//  Created by LeonLiang on 2018/6/19.
//  Copyright © 2018年 LeonLiang. All rights reserved.
//

import Foundation
import AVFoundation

public class SKTAudio: NSObject, AVAudioPlayerDelegate {
    
    var audioPlayer: AVAudioPlayer!
    var audioPlayer_pika: AVAudioPlayer!
    //var timer:Timer!
    //let minInterval = 10
    //let maxInterval = 16
    
    
    
    func playBackgroundMusic(name: String) {
        let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "wav")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: bundleURL!)
            audioPlayer.play()
            audioPlayer.numberOfLoops = -1
            
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer.stop()
    }
    
    func playPika(name:String) {
        let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "wav")
        do {
            audioPlayer_pika = try AVAudioPlayer(contentsOf: bundleURL!)
            audioPlayer_pika.play()
            //audioPlayer_pika.numberOfLoops = 1
            
        } catch let err {
            print("播放失败:\(err.localizedDescription)")
        }
        //    timer.
    }
    
    func stopPika() {
        audioPlayer_pika.stop()
    }
    
    func isPlaying()->Bool {
        if (audioPlayer_pika) != nil {
            return audioPlayer_pika.isPlaying
        }
        else {
            return false
        }
    }
    
    
    
    //func startTimer() {
    //    // 启用计时器，控制每N秒执行一次getNetData方法
    //    timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.minInterval),target:self,selector:#selector(self.timerFunc),userInfo:nil,repeats:true)
    //}
    //func stopTimer() {
    //    timer.invalidate()
    //}
    
    //MARK: AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        println("finished playing (flag)")
        
        if player == audioPlayer {
            playBackgroundMusic(name: "背景音1")
        }
//        delay(5.0, task: {
//            self.playBackgroundMusic()
//        })
    }
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer!, error: Error!) {
//        println("(error.localizedDescription)")
    }
}


