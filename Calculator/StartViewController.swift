//
//  StartViewController.swift
//  Calculator
//
//  Created by LeonLiang on 2018/6/17.
//  Copyright © 2018年 LeonLiang. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import SwiftySound

class StartViewController: UIViewController {
    
    let player = SKTAudio()

    @IBOutlet weak var pikaLogoView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gif = UIImage.gif(name: "pikaLogo")
        pikaLogoView.image = gif
        // Do any additional setup after loading the view.
        
        //创建语音配置
        let initString = "appid=5b24a225"  //APPID
        
        //所有服务启动前，需要确保执行createUtility
        IFlySpeechUtility.createUtility(initString);
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        Sound.stopAll()
        Sound.play(file: "登录音", fileExtension: "wav", numberOfLoops: -1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("require init")
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    


}
