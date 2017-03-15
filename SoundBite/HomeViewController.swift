//
//  ViewController.swift
//  SoundBite
//
//  Created by Logan Geefs on 2017-03-11.
//  Copyright © 2017 LoganGeefs. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var listeningLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    
    var drawerView: DrawerView!
    var darkOverlay: UIView!
    
    var statusBarView: UIView!
    
    let alertController = UIAlertController(title: "Save", message: "Title of clip", preferredStyle: .alert)
    
    var listeningLabelAnimationTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.backgroundColor = .white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(tap:))))
        
        listeningLabel.alpha = 0
        finishButton.alpha = 0
        cancelButton.alpha = 0
        
        listeningLabelAnimationTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(listeningLabelAnimation(timer:)), userInfo: nil, repeats: true)
        
        darkOverlay = UIView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.bounds.width, height: view.bounds.height-UIApplication.shared.statusBarFrame.height))
        darkOverlay.backgroundColor = .black
        darkOverlay.alpha = 0
        
        statusBarView = UIView(frame: CGRect(x: -view.bounds.width*0.8, y: 0, width: view.bounds.width*1.8, height: UIApplication.shared.statusBarFrame.height))
        self.statusBarView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        
        self.view.addSubview(self.statusBarView)
        
        finishButton.titleLabel?.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 24)
        instructionLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 20)

        menuButton.addTarget(self, action: #selector(menuButtonPressed(sender:)), for: .touchUpInside)
        
        recordButton.addTarget(self, action: #selector(recordButtonPressed(sender:)), for: .touchUpInside)
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .touchUpInside)
        
        //drawer view is added/removed each time it's animated
        drawerView = DrawerView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.bounds.width*0.8, height: view.bounds.height-UIApplication.shared.statusBarFrame.height))
        
        setupAlertController()
        
        RecorderController.shared.setSessionAndRecord()
    
    }
    
    func menuButtonPressed(sender: UIButton) {
        
        if !drawerView.isOpen {
            
            drawerView.updateRecordings()
            openDrawer()
            
        } else {
            
            closeDrawer()
            
        }
        
    }
    
    func openDrawer() {
        
        view.addSubview(darkOverlay)
        drawerView.center.x = -view.bounds.width*0.4
        view.addSubview(drawerView)
        
        UIView.animate(withDuration: 0.5) {
            self.drawerView.center.x = self.view.bounds.width*0.4
            self.darkOverlay.alpha = 0.5
        }
        
        drawerView.isOpen = true
        
    }
    
    func closeDrawer() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.drawerView.center.x = -self.view.bounds.width*0.4
            self.darkOverlay.alpha = 0
            
        }, completion: {
            finished in
            
            if finished {
                
                self.drawerView.center.x = self.view.bounds.width*0.4
                self.drawerView.removeFromSuperview()
                self.darkOverlay.removeFromSuperview()
                
            }
            
        })
        
        drawerView.isOpen = false
        
    }

    func recordButtonPressed(sender: UIButton) {
        
        RecorderController.shared.saveSoundbite()
        
        UIView.animate(withDuration: 0.5) {
        
            self.finishButton.alpha = 1
            self.cancelButton.alpha = 1

            self.instructionLabel.alpha = 0
            
        }
        
    }
    
    func setupAlertController() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self]
            alert in
            
            self?.finishButton.alpha = 0
            self?.cancelButton.alpha = 0
            self?.instructionLabel.alpha = 1
            
            if let textField = self?.alertController.textFields?.first {
            
                let filename = "\(textField.text!).m4a"
                let encodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                textField.text = ""
                let filePathToCheck = RecorderController.shared.finishedDirectory.appendingPathComponent(encodedFilename)
                if FileManager.default.fileExists(atPath: filePathToCheck.path) {
                    self?.present(self!.alertController, animated: true)
                    textField.placeholder = "Error: Choose a different name"
                    return
                }
                
                RecorderController.shared.finishRecording(encodedFilename)
                
                self?.listeningLabel.text = "Saving"
                
                self?.perform(#selector(self?.changeListeningLabel), with: self, afterDelay: 3)
                
            }
            
        }
        
        alertController.addTextField {
            textField in
            
            textField.placeholder = "My Soundbite"
            //textField.addTarget(self, action: #selector(self.textFieldValueChanged(textField:)), for: .valueChanged)
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
    }
    
    func finishButtonPressed(sender: UIButton) {
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func cancelButtonPressed(sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete your soundbite?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) {
            alert in
            
            DispatchQueue.main.async {
            
                RecorderController.shared.cancelRecording()
                self.instructionLabel.alpha = 1
                self.finishButton.alpha = 0
                self.cancelButton.alpha = 0
                
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func viewTapped(tap: UITapGestureRecognizer) {
        
        if drawerView.isOpen {
            menuButtonPressed(sender: UIButton())
        }
        
    }
    
    func listeningLabelAnimation(timer: Timer) {
        
        UIView.animate(withDuration: 2) { [weak self] in
            
            if self!.listeningLabel.alpha == 0 {
                
                self?.listeningLabel.alpha = 1
                
            } else {
                
                self?.listeningLabel.alpha = 0
                
            }
            
        }
        
    }
    
    func changeListeningLabel() {
        
        listeningLabel.text = "Listening"
        
    }
    
    /*func textFieldValueChanged(textField: UITextField) {
        
        if textField.text!.characters.count > 0 {
            //save action should be index 1 of alertController actions
            //enable save button
            alertController.actions[1].isEnabled = true
        } else {
            alertController.actions[1].isEnabled = false
        }
        
    }*/

}

