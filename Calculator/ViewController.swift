//
//  ViewController.swift
//  Calculator
//
//  Created by LeonLiang on 2018/6/16.
//  Copyright © 2018年 LeonLiang. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import SwiftySound

class ViewController: UIViewController, IFlySpeechRecognizerDelegate,IFlyVoiceWakeuperDelegate {
    
    let player = SKTAudio()
    
    func onResult(_ resultDic: NSMutableDictionary!) {
        Wakeuper.stopListening()
        showBubbleView(dialog: "我在哦！")
        _ = delay(bubble_delaytime, task: {
            self.textView.text = ""
            self.Recog.startListening()
        })
    }
    
    func onVolumeChanged(_ volume: Int32) {
    }
    
    
    func onCompleted(_ errorCode: IFlySpeechError!) {
        
    }
    
    func onBeginOfSpeech() {
        textView.text = "开始录了"
    }
    
    func onEndOfSpeech() {
        textView.text = "录完了"
    }
    
    func onResults(_ results: [Any]!, isLast: Bool) {
        var resultStr : String = ""
        
        if let resultDic : Dictionary<String, String> = results[0] as? Dictionary<String, String> {
        
            for key in resultDic.keys {
                resultStr += key
                print(resultStr)

                if wordRecognizationHandling(recgStr: key) {
                    break
                }
            }
            textView.text = resultStr
            if currentTypeFlag {
                if textView.text == "。" || textView.text == "！" || textView.text == "？" {
                    _ = delay(bubble_delaytime+0.5, task: {
                        self.Recog.stopListening()
                        self.showBubbleView(dialog: "溜啦！")
                        _ = delay(self.bubble_delaytime, task: {
                            self.textView.text = ""
                            self.Wakeuper.startListening()
                        })
                    })
                }
            }
            else {
                if textView.text == "。" || textView.text == "！" || textView.text == "？" {
                    _ = delay(bubble_delaytime*1.7, task: {
                        self.Recog.stopListening()
                        self.showBubbleView(dialog: "给你一点思考的时间！")
                        _ = delay(self.bubble_delaytime, task: {
                            self.textView.text = ""
                            self.Recog.startListening()
                        })
                    })
                }
            }
        }
        else {
                self.Recog.stopListening()
                self.showBubbleView(dialog: "溜啦！")
                _ = delay(self.bubble_delaytime+0.5, task: {
                    self.textView.text = ""
                    self.Wakeuper.startListening()
                })
            
        }
    }
    
    func pongpong(){
        changePikaGif(name: "pong")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Wakeuper.startListening()
        Sound.stopAll()
Sound.play(file: "背景音1", fileExtension: "wav", numberOfLoops: -1)
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        if Wakeuper.isListening {
            Wakeuper.stopListening()
        }
        else if Recog.isListening {
            Recog.stopListening()
        }
        timer.invalidate()
        Sound.stopAll()
    }
    
    
    
    let Recog :IFlySpeechRecognizer = IFlySpeechRecognizer.sharedInstance() as IFlySpeechRecognizer
    let Wakeuper :IFlyVoiceWakeuper = IFlyVoiceWakeuper.sharedInstance() as IFlyVoiceWakeuper
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
       Recog.delegate = self
        Recog.setParameter("iat", forKey: IFlySpeechConstant.ifly_DOMAIN())
        Recog.setParameter("16000", forKey: IFlySpeechConstant.sample_RATE())
        Recog.setParameter("plain", forKey: IFlySpeechConstant.result_TYPE())
        
        Wakeuper.delegate = self
        let wordPath = Bundle.main.path(forResource: "5b24a225", ofType: "jet")
        
        let ivwResourcePath = IFlyResourceUtil.generateResourcePath(wordPath!)
        Wakeuper.setParameter(ivwResourcePath, forKey: "ivw_res_path")
        Wakeuper.setParameter("0:1450;1:1450;2:1450;3:1450;", forKey: "ivw_threshold")
        Wakeuper.setParameter("wakeup", forKey: "ivw_sst")
        Wakeuper.setParameter("1", forKey: "keep_alive")

    }

    func changePikaGif(name:String = "pikaHomeHi") {
        
        let temp = Int(arc4random()%3)
        
        let pikaImgs = ["pikaThor","pikaNinja","pikaCaptain"]
        let pikaFriendImgs = ["pikaDate","pikaFriend1","pikaFriend2"]
        var gif = UIImage.gif(name: pikaImgs[temp])

        if name == "换装" {
            gif = UIImage.gif(name: pikaImgs[temp])
        }
        else if name == "找朋友" {
            gif = UIImage.gif(name: pikaFriendImgs[temp])
        }
        else {
            gif = UIImage.gif(name: name)
        }
        pika.image = gif
    }
    
    func wordRecognizationHandling(recgStr:String)->Bool {
        
        var flag = false
        var tempPassDict = passDict
        var tempChatDict = chatDict
        var tempAudioDict = audioDict
        var tempAnswerDict = puzzleAnswerDict
        
        if loveOrPuzzleFlag {
            tempAnswerDict = puzzleAnswerDict
        }
        else {
            tempAnswerDict = loveStoryAnswerDict
        }
        
        switch currentSceneType {
        case scene.HOME:
            tempPassDict = self.passDict
            tempChatDict = self.chatDict
            tempAudioDict = self.audioDict
            break
        case scene.PARK:
            tempPassDict = self.parkPassDict
            tempChatDict = self.parkChatDict
            tempAudioDict = self.parkAudioDict
            break
        case scene.SEASIDE:
            tempPassDict = self.seaPassDict
            tempChatDict = self.seaChatDict
            tempAudioDict = self.seaAudioDict
            break
        }
     
        if !currentTypeFlag {
            flag = true
            if recgStr.positionOf(sub: tempAnswerDict[puzzleNumber]) != -1 {
                self.showBubbleView(dialog: "你太厉害啦！",audio:"pikalove")
                self.currentTypeFlag = true
            }
            else if recgStr.positionOf(sub: "告诉") != -1 || recgStr.positionOf(sub: "不知道") != -1 {
                self.showBubbleView(dialog: "那告诉你咯，答案是："+tempAnswerDict[puzzleNumber],audio:"pikalove")
                self.currentTypeFlag = true
            }
            else if recgStr.positionOf(sub: "。") != -1 || recgStr.positionOf(sub: "！") != -1 || recgStr.positionOf(sub: "？") != -1 {
                
            }
            else {
                self.showBubbleView(dialog: "不对不对！再来一次！",audio:"pikalove")
            }
        }
        else {
            for (key, value) in tempChatDict {
                print("字典 key \(key) -  字典 value \(value)")
                if recgStr.positionOf(sub: key) != -1 {
                    flag = true
                    if key == "猜谜语" || key == "土味情话" {
                        if key == "土味情话" {
                            self.loveOrPuzzleFlag = false
                        }
                        else {
                            self.loveOrPuzzleFlag = true
                        }
                        self.showBubbleView(dialog: value,audio: tempAudioDict[key]!)
                        self.puzzleGame()
                        
                        _ = delay(10){
                            
                        }
                    }
                    else if key == "去公园" {                        self.showBubbleView(dialog: value,audio: tempAudioDict[key]!)
                        self.changePikaGif(name: tempPassDict[key]!)
                         sceneChangingHandling(sceneType: scene.PARK)
                    }
                    else if key == "去海边" {
                    self.showBubbleView(dialog: value,audio: tempAudioDict[key]!)
                        self.changePikaGif(name: tempPassDict[key]!)
                         sceneChangingHandling(sceneType: scene.SEASIDE)

                    }
                    else if key == "回家" {
                    self.showBubbleView(dialog: value,audio: tempAudioDict[key]!)
                        self.changePikaGif(name: tempPassDict[key]!)
                        sceneChangingHandling(sceneType: scene.HOME)
                    }
                    else {
                        pongpong()
                        _ = delay(pongpong_delaytime) {
                            self.changePikaGif(name: tempPassDict[key]!)
                            self.showBubbleView(dialog: value,audio: tempAudioDict[key]!)
                        }
                    }
                }
            }
        }
        return flag
    }
    
    var currentTypeFlag = true
    var loveOrPuzzleFlag = true
    // true->puzzle false->love
    // false->puzzlegame true->wordrecognization
    var puzzleNumber = 0
    
    func puzzleGame() {
        
        var tempQueDict = puzzleDict
        
        if loveOrPuzzleFlag {
            tempQueDict = puzzleDict
        }
        else {
            tempQueDict = loveStoryDict
        }
        
        self.currentTypeFlag = false
        let temp = Int(arc4random()%UInt32(tempQueDict.count))
        self.puzzleNumber = temp
        let value:String = tempQueDict[temp]
        _ = delay(bubble_delaytime, task: {
            print(value)
            self.showBubbleView(dialog: value,audio: self.audioDict["猜谜语"]!,flag:true)
        })
    }
    
  
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gif = UIImage.gif(name: "pikaHomeHi")
        pika.image = gif
        
        pika.contentMode = UIViewContentMode.scaleAspectFit
        hideBubbleView()

        timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.minInterval),target:self,selector:#selector(self.timerFunc),
            userInfo:nil,repeats:true)
        
        
    }
    
    @objc func timerFunc(){
        let tempInterval = Int(arc4random()%UInt32(maxInterval - minInterval))
        _ = delay(TimeInterval(tempInterval), task: {
            if !self.player.isPlaying() {
                self.player.playPika(name: self.defaultPikaAudio)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func startButtonTouchUp(_ sender: UIButton) {
        changeScene(sceneType: scene.HOME)
    }
    
    func showBubbleView(dialog: String, audio:String = "pikaaaa", flag:Bool = false) {
        
        bubbleImgView.isHidden = false
        bubbleTextView.isHidden = false
        bubbleTextView.text = dialog
        
        _ = delay(bubble_delaytime, task: {
            self.hideBubbleView()
        })
    
        if !player.isPlaying() && dialog != "溜啦！" {
            player.playPika(name: audio)
        }
    }
    
    func hideBubbleView() {
        bubbleImgView.isHidden = true
        bubbleTextView.isHidden = true
    }
    
    func flashView() {
        view.bringSubview(toFront: loadingPikaView)
        view.bringSubview(toFront: pika)
        view.bringSubview(toFront: bubbleImgView)
        view.bringSubview(toFront: bubbleTextView)

    }
    
    func changeScene(sceneType:scene) {
        let transition = CATransition()
        transition.duration = 1
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionFade
        
        pika.isHidden = true
        bubbleTextView.isHidden = true
        bubbleImgView.isHidden = true

        self.backgroundImg.layer.add(transition, forKey: "a")
        self.backgroundImg.image = UIImage(named: "loading.png")
        
        loadingPikaView.isHidden = false
        let gif = UIImage.gif(name: "pika")
        loadingPikaView.layer.add(transition, forKey: "a")
        loadingPikaView.image = gif

        
        _ = delay(1.5, task: {
            self.backgroundImg.layer.add(transition, forKey: "a")
            self.backgroundImg.image = UIImage(named: self.sceneTypesDict[sceneType]!)
            self.pika.isHidden = false
            self.bubbleTextView.isHidden = false
            self.bubbleImgView.isHidden = false
            self.loadingPikaView.isHidden = true
        })
        
        _ = delay(2, task: {
            self.flashView()
        })
       
    }
    
    func sceneChangingHandling(sceneType:scene) {
        self.changeScene(sceneType: sceneType)
        self.currentSceneType = sceneType
        var imgString = ""
        switch currentSceneType {
        case scene.HOME:
            imgString = "bubble_home.png"
            break
        case scene.PARK:
            imgString = "bubble_park.png"
            break
        case scene.SEASIDE:
            imgString = "bubble_seaside.png"
            break
        }
        
        bubbleImgView.image = UIImage(named: imgString)
    }
    
    enum scene {
        case HOME
        case SEASIDE
        case PARK
    }
    
    let sceneTypesDict:[scene:String] = [scene.HOME:"home.jpg",scene.SEASIDE:"seaside.png",scene.PARK:"park.png"]
    var currentSceneType:scene = scene.HOME
    @IBOutlet weak var bubbleTextView: UITextView!
    @IBOutlet weak var pika: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var bubbleImgView: UIImageView!
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var loadingPikaView: UIImageView!


    let pongpong_delaytime:double_t = 0.8
    let bubble_delaytime:double_t = 1.5
    let minInterval = 15
    let maxInterval = 21

    
    // home
    let chatDict:[String:String] = ["吃":"沉迷学习还没有来得及吃饭呢~","开心":"很开心呢！","你真棒":"嘿嘿！","你真菜":"知道了，学无止境~","头发":"不好意思，我没有头发~","木头人":"谁动谁就输～","换装":"我好看吗？","去公园":"走咯！","去海边":"出发吧！","游戏":"带你上分带你飞！","猜谜语":"哼哼，接招吧！","土味情话":"准备好心动吧！"]
    let passDict:[String:String] = ["吃":"pikaHomeHi","开心":"pikaHomeHi","你真棒":"pikaHappy","你真菜":"pikaSad","头发":"pikaHomeHi","木头人":"pika321","换装":"换装","去公园":"pikaParkHi","去海边":"pikaSeaHi","游戏":"pikaPlay","猜谜语":"pikaHomeHi","土味情话":"pikaHomeHi"]
    let audioDict:[String:String] = ["吃":"pikaeat","开心":"pikahey","你真棒":"pikahey","你真菜":"pikasad","头发":"pikahair","木头人":"pika123","换装":"pikacloth","去公园":"pikaaaa","去海边":"pikaaaa","游戏":"supermario","猜谜语":"pikami","土味情话":"pikalove"]
    // seaside
    let seaChatDict:[String:String] = ["晒":"我是晒不黑的！","开心":"我很开心，一起晒太阳吧！","渴":"也许可以来两杯椰子汁！","学习":"好久不学习，我有点慌。。。","椰子树":"如果你能爬上去，我就叫你爸爸！","冲浪":"是时候展现真正的技术了！","戴帽子":"我帅炸了！","回家":"回家洗澡澡！"]
    let seaPassDict:[String:String] = ["晒":"pikaSeaHi","开心":"pikaSeaHi","渴":"pikaSeaHi","学习":"pikaSeaHi","椰子树":"pikaSeaHi","冲浪":"pikaSurf","戴帽子":"pikaSea","回家":"pikaHomeHi"]
    let seaAudioDict:[String:String] = ["晒":"pikaaaa","开心":"pikaeat","渴":"pikami","学习":"pikasad","椰子树":"pikahair","冲浪":"pika123","戴帽子":"pikahey","回家":"pikalove"]
    // park
    let parkChatDict:[String:String] = ["高兴":"出来玩当然高兴，哼，傻傻的！","累":"不累，我不想回家！","跑":"你来追我呀！","学习":"当然是更喜欢学习啦！","热":"我不怕热。","吃":"我想吃冰淇淋了！","飞":"我要飞得更高！嗷嗷！","过节":"你想吃复活蛋吗？","找朋友":"向大家介绍一下，这是我朋友！","回家":"回家洗澡澡！"]
    let parkPassDict:[String:String] = ["高兴":"pikaParkHi","累":"pikaParkHi","跑":"pikaRun","学习":"pikaParkHi","热":"pikaParkHi","吃":"pikaParkHi","飞":"pikaFly","过节":"pikaCelebrate","找朋友":"找朋友","回家":"pikaHomeHi"]
    
    let parkAudioDict:[String:String] = ["高兴":"pikaeat","累":"pikami","跑":"pikahey","学习":"pikami","热":"pikasad","吃":"pika123","飞":"pikahair","过节":"pika123","找朋友":"pikalove","回家":"pikaaaa"]//谜语
    let puzzleDict:[String] = ["小白加小白等于什么？","视而不见，打一个字！","双木非林，田下有心，打一个词！","一个红豆把包子吃了，猜一个小吃！","黄鼠狼觅食，打一成语！","两个胖子拥抱，打一城市！","老鹰的绝症是什么？","哪里的和尚最少？","什么轮子 只转不走？","风的孩子叫什么？"]
    let puzzleAnswerDict:[String] = ["小白兔","示","相思","豆沙包","见机行事","合肥","恐高症","南边","风车","水起"]
    //土味情话
    let loveStoryDict:[String] = ["我最喜欢喝什么东西?","我最喜欢吃什么东西？","你知道我的缺点吗？","你属什么？","你是什么血型呀？","你知道我跟唐僧的区别是什么吗?"," 你知道我想成为什么人吗?"," 你知道我的心在哪边么？ ","你猜我是喜欢晴天还是雨天？"]
    let loveStoryAnswerDict:[String] = ["呵护你","痴痴地望着你","缺点你","属于你","你的理想型","唐僧取经你娶我","我的人","我这边","有我的每一天"]
    let defaultPikaAudio = "pikaaaa"//自己叫
    
}

