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
    
    var drawerView: DrawerView!
    
    var statusBarView: UIView!
    
    let alertController = UIAlertController(title: "Save", message: "Title of clip", preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.window?.backgroundColor = .white
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(tap:))))
        
        finishButton.alpha = 0
        cancelButton.alpha = 0
        
        statusBarView = UIView(frame: CGRect(x: -view.bounds.width*0.8, y: 0, width: view.bounds.width*1.8, height: UIApplication.shared.statusBarFrame.height))
        self.statusBarView.backgroundColor = UIColor(colorLiteralRed: 255/255, green: 95/255, blue: 95/255, alpha: 1)
        
        self.view.addSubview(self.statusBarView)
        
        readyButton.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 24)
        instructionLabel.font = UIFont(name: "Chalet-NewYorkNineteenEighty", size: 20)

        menuButton.addTarget(self, action: #selector(menuButtonPressed(sender:)), for: .touchUpInside)
        
        recordButton.addTarget(self, action: #selector(recordButtonPressed(sender:)), for: .touchUpInside)
        
        finishButton.addTarget(self, action: #selector(finishButtonPressed(sender:)), for: .touchUpInside)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonPressed(sender:)), for: .touchUpInside)
        
        //drawer view is added/removed each time it's animated
        drawerView = DrawerView(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: view.bounds.width*0.8, height: view.bounds.height-UIApplication.shared.statusBarFrame.height))
        
        SoundController.shared.startRecording()
        
        setupAlertController()
    
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
        
        drawerView.center.x = -view.bounds.width*0.4
        view.addSubview(drawerView)
        
        UIView.animate(withDuration: 0.5) {
            
            self.drawerView.center.x = self.view.bounds.width*0.4
            
        }
        
        drawerView.isOpen = true
        
    }
    
    func closeDrawer() {
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.drawerView.center.x = -self.view.bounds.width*0.4
            
        }, completion: {
            finished in
            
            if finished {
                
                self.drawerView.center.x = self.view.bounds.width*0.4
                self.drawerView.removeFromSuperview()
                
            }
            
        })
        
        drawerView.isOpen = false
        
    }

    func recordButtonPressed(sender: UIButton) {
        
        SoundController.shared.saveSoundbite()
        
        UIView.animate(withDuration: 0.5) {
        
            self.finishButton.alpha = 1
            self.cancelButton.alpha = 1

            self.instructionLabel.alpha = 0
            
        }
        
    }
    
    func setupAlertController() {
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) {
            alert in
            
            if let textField = self.alertController.textFields?.first {
            
                //overwrites any file with same name - fix in future
                let filename = textField.text!
                let encodedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                SoundController.shared.finishedSoundbiting(encodedFilename!)
                SoundController.shared.restartRecording()
                
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
            
                SoundController.shared.restartRecording()
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

