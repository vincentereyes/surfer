//
//  ViewController.swift
//  SurfApp
//
//  Created by Vince Reyes on 7/8/18.
//  Copyright © 2018 VinceReyes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBAction func luBtnP(_ sender: UIButton) {
        performSegue(withIdentifier: "surfSpot", sender: sender)
    }
    
    @IBAction func balerBtnP(_ sender: UIButton) {
        performSegue(withIdentifier: "surfSpot", sender: sender)
    }
    
    @IBAction func cloudBtnP(_ sender: UIButton) {
        performSegue(withIdentifier: "surfSpot", sender: sender)
    }
    
    @IBAction func crystalBtnP(_ sender: UIButton) {
        performSegue(withIdentifier: "surfSpot", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let button = sender as? UIButton {
            
            let destination = segue.destination as! reportVC
            destination.title = button.titleLabel!.text!
            destination.spotId = button.tag
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !launched {
            let alert = UIAlertController(title: "Welcome to Surfer!", message: "We do not tolerate any objectionable content or any abusive behavior. We will ban users that are abusive", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: {(alert: UIAlertAction!) in
            }))
            alert.addAction(UIAlertAction(title: "Disagree", style: .default, handler: {(alert: UIAlertAction!) in
                UserDefaults.standard.set(false, forKey: "launched")
                exit(0)
            }))
            self.present(alert, animated: true)
        }
        
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if error != nil {
                print(error!)
            } else {
                let newUser = Database.database().reference().child("users").child((user!.user.uid))
                newUser.setValue(["uid": user!.user.uid])
            }
        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

