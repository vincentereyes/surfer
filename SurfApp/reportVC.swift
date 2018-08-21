//
//  reportVC.swift
//  SurfApp
//
//  Created by Vince Reyes on 7/9/18.
//  Copyright © 2018 VinceReyes. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import SVProgressHUD
import GoogleMobileAds
import Firebase
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

public func getTemps(temps: [Int]) -> [String: Int] {
    var lowest = temps[0]
    var highest = temps[1]
    for i in 0...temps.count - 1 {
        if temps[i] < lowest {
            lowest = temps[i]
        } else if temps[i] > highest {
            highest = temps[i]
        }
    }
    return ["lowest": lowest, "highest": highest]
}

public func getWaves(mins: [Int], maxs: [Int]) -> [String: Int] {
    var lowest = mins[0]
    var highest = maxs[0]
    for i in 0...mins.count - 1 {
        if mins[i] < lowest {
            lowest = mins[i]
        }
        if maxs[0] > highest {
            highest = maxs[0]
        }
    }
    return ["lowest": lowest, "highest": highest]
}

class reportVC: UIViewController, GADBannerViewDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var banner: GADBannerView!
    
    @IBOutlet weak var tableView: UITableView!
    
    var spotId:Int?
    var waveJSON:JSON?
    var messageArray: [Dictionary<String, String>] = [Dictionary<String, String>]()
    
    
    
    @IBOutlet weak var temp1Lbl: UILabel!
    
    @IBOutlet weak var temp2Lbl: UILabel!
    
    @IBOutlet weak var wave1Lbl: UILabel!
    
    @IBOutlet weak var wave2Lbl: UILabel!
    
    @IBOutlet weak var ratingLbl: UILabel!
    
    @IBOutlet weak var msgTxtField: UITextField!
    
    @IBOutlet weak var msgViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var image: UIImageView!

    
    
    
    @IBAction func sendBtnP(_ sender: UIButton) {
        self.view.endEditing(true)
        if msgTxtField.text != ""  && msgTxtField.text!.count < 255 {
            msgTxtField.isEnabled = false
            sendBtn.isEnabled = false
            
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Manila")
            dateFormatter.dateFormat = "MMMM d h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            let messagesDB = Database.database().reference().child("\(spotId!)")
            
            let messageDict = ["Sender": Auth.auth().currentUser?.uid, "MessageBody": msgTxtField.text!, "Date": dateString]
            
            messagesDB.childByAutoId().setValue(messageDict) {
                (error, ref) in
                
                if error != nil {
                    print(error!)
                } else {
                }
            }
            
            msgTxtField.text = ""
            msgTxtField.isEnabled = true
            sendBtn.isEnabled = true
        } else {
            let alert = UIAlertController(title: "Error", message: "Empty message or more than 255 Characters", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {(alert: UIAlertAction!) in
            }))
            self.present(alert, animated: true)
        }
        
    }
    
    @objc func linkTapped(sender:UITapGestureRecognizer) {
        let url = URL(string: "http://magicseaweed.com")
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.items![1].isEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        
        sendBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        msgTxtField.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(linkTapped(sender:)))
        image.addGestureRecognizer(tapGestureRecognizer)
        image.isUserInteractionEnabled = true
        
        SVProgressHUD.show()
        
        banner.adUnitID = "ca-app-pub-2224540103239234/4461064354"
        banner.rootViewController = self
        banner.load(GADRequest())
        
        getWaves("http://magicseaweed.com/api/825844d57095b13e818fbbf4d6e781b3/forecast/?spot_id=\(spotId!)&units=uk&fields=localTimestamp,solidRating,swell.minBreakingHeight,swell.maxBreakingHeight,swell.unit,condition.temperature,condition.unit,condition.weather")
        
        
        // Listen for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        configureTableView()
        
        retrieveMessages()
        
        tableView.separatorStyle = .none
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! messageCell

        if messageArray[indexPath.row]["Sender"] == Auth.auth().currentUser?.uid {
            cell.iconLbl?.text = "😀"
            cell.backgroundColor = UIColor.darkGray
            cell.accessoryType = .none
        } else {
            cell.iconLbl?.text = "🏄‍♂️"
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = .detailButton
        }
        
        cell.msgLbl?.text = messageArray[indexPath.row]["MessageBody"]!
        cell.timeLbl?.text = messageArray[indexPath.row]["Date"]!
    
        
        return cell
        
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    //MARK: - Networking
    /***************************************************************/
    
    func getWaves(_ url:String) {
        Alamofire.request(url).responseJSON { response in
            if response.result.isSuccess {
                let waveJSON: JSON = JSON(response.result.value!)
                self.updateWaveData(waveJSON)
            } else {
                print("connection issue")
            }

        }
    }
    
    func retrieveMessages() {
        let messagesDB = Database.database().reference().child("\(spotId!)")
        
        messagesDB.observe(.childAdded, with: { (snapshot) in
            let value = snapshot.value as! Dictionary<String, String>
            
            let sender = value["Sender"]!
            let date = value["Date"]!
            let text = value["MessageBody"]!

            if UserDefaults.standard.value(forKey: value["Sender"]!) == nil {
                self.messageArray.append(["Sender": sender, "MessageBody": text, "Date": date])
                self.configureTableView()
                self.tableView.reloadData()
                self.scrollToLastRow()
                }
        })
        
    }
    
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
    
    func updateWaveData(_ json: JSON) {
        if let _ = json[0]["solidRating"].int {
            waveJSON = json
//            let forecast = self.tabBarController?.viewControllers?[1] as! forecastVC
//            forecast.waveJSON = waveJSON
            updateUI()
            
        }
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func scrollToLastRow() {
        let indexPath = IndexPath(row: messageArray.count - 1, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            msgViewHeight.constant = keyboardRect.height
        } else {
            msgViewHeight.constant = 50
        }
        
        
    }
    
    func updateUI() {
        let temperature1 = SurfApp.getTemps(temps: [waveJSON![2]["condition"]["temperature"].int!, waveJSON![3]["condition"]["temperature"].int!])
        
        let temperature2 = SurfApp.getTemps(temps: [waveJSON![4]["condition"]["temperature"].int!, waveJSON![5]["condition"]["temperature"].int!])
        
        let wave1 = SurfApp.getWaves(mins: [waveJSON![2]["swell"]["minBreakingHeight"].int!, waveJSON![3]["swell"]["minBreakingHeight"].int!], maxs: [waveJSON![2]["swell"]["maxBreakingHeight"].int!, waveJSON![3]["swell"]["maxBreakingHeight"].int!])
        
        let wave2 = SurfApp.getWaves(mins: [waveJSON![4]["swell"]["minBreakingHeight"].int!, waveJSON![5]["swell"]["minBreakingHeight"].int!], maxs: [waveJSON![4]["swell"]["maxBreakingHeight"].int!, waveJSON![5]["swell"]["maxBreakingHeight"].int!])
        
        let rating = ((waveJSON![2]["solidRating"].int! + waveJSON![3]["solidRating"].int! + waveJSON![4]["solidRating"].int! + waveJSON![5]["solidRating"].int!) / 4)
        
        temp1Lbl.text = "\(temperature1["lowest"]!) - \(temperature1["highest"]!) ° C"
        temp2Lbl.text = "\(temperature2["lowest"]!) - \(temperature2["highest"]!) ° C"
        
        wave1Lbl.text = "\(wave1["lowest"]!) - \(wave1["highest"]!) ft"
        wave2Lbl.text = "\(wave2["lowest"]!) - \(wave2["highest"]!) ft"
        
        
        ratingLbl.text = "\(rating)/5 ⭐️ by: "
        
        
        self.tabBarController?.tabBar.items![1].isEnabled = true
        SVProgressHUD.dismiss()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let flagBtn = UITableViewRowAction(style: .destructive, title: "Report", handler: {(rowAction, indexPath) in
            let flaggedUser = Database.database().reference().child("flaggedUsers").child((self.messageArray[indexPath.row]["Sender"]!))
            flaggedUser.setValue(["uid" : self.messageArray[indexPath.row]["Sender"]!])
            let alert = UIAlertController(title: "User Flagged", message: "User has been flagged and will be reviewed", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {(alert: UIAlertAction!) in
            }))
            self.present(alert, animated: true)
        })
        let blockBtn = UITableViewRowAction(style: .normal, title: "Block", handler: {(rowAction, indexPath) in
            UserDefaults.standard.set(true, forKey: self.messageArray[indexPath.row]["Sender"]!)
            let messagesDB = Database.database().reference().child("\(self.spotId!)")
            messagesDB.removeAllObservers()
            self.messageArray.removeAll()
            self.retrieveMessages()
            let alert = UIAlertController(title: "User Blocked", message: "User has been blocked. Messages from the blocked user will no longer appear", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {(alert: UIAlertAction!) in
            }))
            self.present(alert, animated: true)
        })
        
        if messageArray[indexPath.row]["Sender"] == Auth.auth().currentUser?.uid {
            return []
        } else {
            return [flagBtn, blockBtn]
        }
        
        
    }
    
    func configureTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
    }
    
    
}
