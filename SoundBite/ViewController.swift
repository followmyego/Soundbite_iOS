//
//  ViewController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var readyButton: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var soundController: SoundController!
    
    var startTimer: Timer!
    
    var drawerView: DrawerView!
    
    var statusBarView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.backgroundColor = .white
        
        finishButton.alpha = 0
        cancelButton.alpha = 0
        
        statusBarView = UIView(frame: CGRect(x: -view.bounds.width*0.8, y: 0, width: view.bounds.width*1.8, height: UIApplication.shared.statusBarFrame.height))
        self.statusBarView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        
        self.view.addSubview(self.statusBarView)
        
        readyButton.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 24)
        instructionLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 20)
        
        startTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(activateSoundbiteButton(timer:)), userInfo: nil, repeats: false)

        menuButton.addTarget(self, action: #selector(menuButtonPressed(sender:)), for: .touchUpInside)
        
        recordButton.isEnabled = false
        recordButton.addTarget(self, action: #selector(recordButtonPressed(sender:)), for: .touchUpInside)
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .touchUpInside)
        
        drawerView = DrawerView(frame: CGRect(x: -view.bounds.width*0.8, y: UIApplication.shared.statusBarFrame.height, width: view.bounds.width*0.8, height: view.bounds.height-UIApplication.shared.statusBarFrame.height))
        view.addSubview(drawerView)
        
        soundController = SoundController.shared
        soundController.startRecording()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func menuButtonPressed(sender: UIButton) {
        
        if !drawerView.isOpen {
        
            UIView.animate(withDuration: 0.5) {
            
                self.view.center.x = self.view.bounds.width*1.3
            
            }
            
        } else {
            
            UIView.animate(withDuration: 0.5) {
                
                self.view.center.x = self.view.bounds.width*0.5
                
            }
            
        }
        
        drawerView.isOpen = !drawerView.isOpen
        
    }

    func recordButtonPressed(sender: UIButton) {
        
        soundController.saveSoundbite()
        
        UIView.animate(withDuration: 0.5) {
        
            self.finishButton.alpha = 1
            self.cancelButton.alpha = 1

            self.instructionLabel.alpha = 0
            
        }
        
    }
    
    func activateSoundbiteButton(timer: Timer) {
        
        recordButton.isEnabled = true
        startTimer.invalidate()
        startTimer = nil
        
    }
    
    func finishButtonPressed(sender: UIButton) {
        
        soundController.finishedSoundbite()
        
    }
    
    func cancelButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            alert in
            
            DispatchQueue.main.async {
            
                self.soundController.restartRecording()
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

}

