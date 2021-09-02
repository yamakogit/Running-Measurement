//
//  SaveRunningViewController.swift
//  RunningMeasurement
//
//  Created by Fumiya Tanaka on 2020/08/09.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
/*
//start_アクション通知
enum ActionIdentifier: String {
    case acitonone
}
//end_アクション通知
*/
 
class SaveRunningViewController: UIViewController, UNUserNotificationCenterDelegate {

    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var cadenceLabel: UILabel!
    @IBOutlet var paceLabel: UILabel!
    
    @IBOutlet var saveButton: UIButton!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    var locationManager: CLLocationManager = CLLocationManager()
    var saveData: UserDefaults = UserDefaults.standard  //配列保存
    var cadence: Int = 0
    var distance: Int = 0
    var duration: Int = 0
    
//追加↓一行 8/20 軌跡追加
    //走行した場所の緯度と経度のペアを要素とした配列
    //例:[["latitude": 64, "longtitude": 120], ["latitude": 40, "longtitude": 100]]
    var coordinates: [[String: Double]] = []

//↓追加〜 8/18 m表示→ km m 表示に変更
    var kiromater: Int = 0
    var mater: Int = 0
//↑〜追加 8/18 m表示→ km m 表示に変更
    
    var pace: Int = 0
    var paceMinutes: Int = 0
    var paceSeconds: Int = 0
    var pacea: Int = 0
    
    //ここから
    let unit_cadence = NSLocalizedString("steps/s", comment: "")
    let save_alertTitle = NSLocalizedString("Save Running Record", comment: "")
    let save_alertmessage = NSLocalizedString("Save running record.\nCheck result ”History” tab.", comment: "")
    //ここまで
    
    let savePlayer = try! AVAudioPlayer(data: NSDataAsset(name: "save")!.data)
    @IBAction func tapSaveButton(){
        savePlayer.currentTime = 0
        savePlayer.play()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let minutes = duration / 60
        let seconds = duration % 60
        
        activityIndicator.isHidden = true
        
        //保存ボタン
        saveButton.layer.cornerRadius = 8  //角を角丸に設定
        saveButton.layer.shadowColor = UIColor.systemGray4.cgColor  //影の色を設定
        saveButton.layer.shadowOffset = .init(width: 2, height: 2)  //影の方向を設定
        saveButton.layer.shadowRadius = 8  //影のぼかしを設定
        saveButton.layer.shadowOpacity = 0.2  //影の色の透明度を設定
        //保存ボタン
        
        activityIndicator.layer.cornerRadius = 5
        
        
        
//↓追加〜 8/18 m表示→ km m 表示に変更
        
        kiromater = distance / 1000
        mater = distance % 1000
//↑〜追加 8/18 m表示→ km m 表示に変更
        if distance != 0 {
        pacea = duration * 1000
        pace = pacea / distance
        paceMinutes = pace / 60
        paceSeconds = pace % 60
            
            //MARK:ペース表示
            if paceMinutes < 10 {
                if paceMinutes != 0 {
                    if paceSeconds < 10 {
                        if paceSeconds != 0 {
                            paceLabel.text = "0\(paceMinutes):0\(paceSeconds)/km"//09:01
                        } else {
                            paceLabel.text = "0\(paceMinutes):00/km"//09:00
                        }
                    } else {
                        paceLabel.text = "0\(paceMinutes):\(paceSeconds)/km"//09:12
                    }
                } else {
                    if paceSeconds < 10 {
                        if paceSeconds != 0 {
                            paceLabel.text = "00:0\(paceSeconds)/km"//00:01
                        } else {
                            paceLabel.text = "00:00/km"//00:00
                        }
                    } else {
                        paceLabel.text = "00:\(paceSeconds)/km"//00:12
                    }
                }
            } else {
                if paceSeconds < 10 {
                    if paceSeconds != 0 {
                        paceLabel.text = "\(paceMinutes):0\(paceSeconds)/km"//10:01
                    } else {
                        paceLabel.text = "\(paceMinutes):00/km"//10:00
                    }
                } else {
                    paceLabel.text = "\(paceMinutes):\(paceSeconds)/km"//10:12
                }
            }
            //MARK:ペース表示
        } else {
        paceLabel.text = "--:--/km"
        }
//編集↓一行 8/18 m表示→ km m 表示に変更
        //元:distanceLabel.text = "(distance)m"
        //編集後:distanceLabel.text = "\(kiromater) km\(mater)m"
        distanceLabel.text = "\(kiromater) km\(mater)m"
        if minutes < 10 {
            if minutes != 0 {
                if seconds < 10 {
                    if seconds != 0 {
                        durationLabel.text = "0\(minutes):0\(seconds)"//09:01
                    } else {
                        durationLabel.text = "0\(minutes):00"//09:00
                    }
                } else {
                    durationLabel.text = "0\(minutes):\(seconds)"//09:12
                }
            } else {
                if seconds < 10 {
                    if seconds != 0 {
                        durationLabel.text = "00:0\(seconds)"//00:01
                    } else {
                        durationLabel.text = "00:00"//00:00
                    }
                } else {
                    durationLabel.text = "00:\(seconds)"//00:12
                }
            }
        } else {
            if seconds < 10 {
                if seconds != 0 {
                    durationLabel.text = "\(minutes):0\(seconds)"//10:01
                } else {
                    durationLabel.text = "\(minutes):00"//10:00
                }
            } else {
                durationLabel.text = "\(minutes):\(seconds)"//10:12
            }
        }
        cadenceLabel.text = "\(cadence) \(unit_cadence)"
        
    }
    
    @IBAction func save() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        //配列保存
        let dictionary: [String: Any] = [
            "cadence": cadence,
            "distance": distance,
            "duration": duration,
            "date": Date(),
            //編集↓一行 8/22 計測履歴詳細画面-地図 適正表示
            /*元:"currentLocationLatitude": locationManager.location?.coordinate.latitude,
            "currentLocationLongitude": locationManager.location?.coordinate.longitude,        */
            "locations": coordinates
        ]
        var currentData = saveData.array(forKey: "running") ?? []
        currentData.append(dictionary)
        saveData.set(currentData, forKey: "running")
        dismiss(animated: true, completion: nil)
        //配列保存
        
        //バッジ
        let tabBarItem = tabBarController?.viewControllers?[3].tabBarItem
        tabBarItem?.badgeValue = "New"
        tabBarItem?.badgeColor = UIColor.systemRed
        
        activityIndicator.stopAnimating()
        //ランニング計測 Top画面 へ
        self.navigationController?.popToRootViewController(animated: true)
        
        //画面 値 受け渡し方
        //let tabBarController = presentingViewController as! UITabBarController
        
        //tabBarController.selectedIndex = 3
        // タブ 変更 ↑ ↓
        //self.tabBarController?.selectedIndex = 3
        
        /*
        //start_アクション通知
        let actionone = UNNotificationAction(identifier: ActionIdentifier.acitonone.rawValue, title: "計測履歴画面へ", options: [.foreground])
        let category = UNNotificationCategory(identifier: "category_select", actions: [actionone], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self
        //end_アクション通知
        */
        //start_通知
        let content = UNMutableNotificationContent()
        content.title = "\(save_alertTitle)"
        content.body = "\(save_alertmessage)"
        content.sound = UNNotificationSound.default
        // content.categoryIdentifier = "category_select"
        let request = UNNotificationRequest(identifier: "dataSave", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //end_通知
        
    }
    /*
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Swift.Void) {
        switch response.actionIdentifier {
        case ActionIdentifier.acitonone.rawValue:
            self.tabBarController?.s
     electedIndex = 3
        default:
            break
        }
    }
 */
}
