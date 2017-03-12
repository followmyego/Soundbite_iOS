//
//  ViewController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    var soundController: SoundController!
    
    var startTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(activateSoundbiteButton(timer:)), userInfo: nil, repeats: false)

        recordButton.isEnabled = false
        recordButton.addTarget(self, action: #selector(recordButtonPressed(sender:)), for: .touchUpInside)
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
        menuButton.addTarget(self, action: #selector(menuButtonPressed(sender:)), for: .touchUpInside)
        
        soundController = SoundController()
        soundController.startRecording()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func recordButtonPressed(sender: UIButton) {
        
        soundController.saveSoundbite()
        
    }
    
    func activateSoundbiteButton(timer: Timer) {
        
        recordButton.isEnabled = true
        startTimer.invalidate()
        startTimer = nil
        
    }
    
    func finishButtonPressed(sender: UIButton) {
        
        soundController.finishedSoundbite()
        
    }
    
    func menuButtonPressed(sender: UIButton) {
        
        
        
    }

}

