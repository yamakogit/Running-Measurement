//
//  RunningViewController.swift
//  RunningMeasurement
//
//  Created by Fumiya Tanaka on 2020/08/08.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit  //事前に追加されている
import MapKit  //Mapを使用できるようにするため
import CoreMotion  //歩数機能等を使用できるようにするため
import CoreLocation  //位置情報を使用できるようにするため
import AVFoundation  //音を使用できるようにするため

//編集↓一行 8/21 カメラ機能追加
//元:class RunningViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
class RunningViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{  //Map・カメラ機能・写真機能を使用できるようにするため

    @IBOutlet var runningStatusLabel: UILabel!
    @IBOutlet var runningDistanceLabel: UILabel!
    @IBOutlet var cadenceLabel: UILabel!  //配列保存
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var durationLabel: UILabel!
//    @IBOutlet var stopButton: UIButton!
    @IBOutlet var stopresumeButton: UIButton!
    @IBOutlet var finishButton: UIButton!
    /*MARK:★*/@IBOutlet var paceLabel: UILabel!
    
    let finishPlayer = try! AVAudioPlayer(data: NSDataAsset(name: "finish")!.data)
    @IBAction func tapFinishButton(){
        finishPlayer.currentTime = 0
        finishPlayer.play()
    }
    
    let stopPlayer = try! AVAudioPlayer(data: NSDataAsset(name: "stop")!.data)
    @IBAction func tapStopButton(){
        stopPlayer.currentTime = 0
        stopPlayer.play()
    }
    
//追加〜 8/21 カメラ機能追加
    @IBAction func launchCamera(_ sender: UIButton) {  //Main.StoryBoard上のカメラボタンと関連付けを行うため
        
        let camera = UIImagePickerController.SourceType.camera  //画像の取得方法を「カメラで撮影して取得する」ように設定
        
        if UIImagePickerController.isSourceTypeAvailable(camera){  //カメラ機能がない機器でカメラを開こうとしてクラッシュするのを防ぐため、「カメラ機能がある場合のみ実行する」という条件を追加

            let picker = UIImagePickerController()  //カメラの画面をランニング計測中画面の前面に表示するため
            picker.sourceType = camera  //カメラ機能を使用できるようにするため
            picker.delegate = self  //カメラ機能を使用できるようにするため
            self.present(picker, animated: true)  //カメラの画面をランニング計測中画面の前面に表示するため
        }
    }
    //下4行:写真を保存
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) { //撮影した画像を取得
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage  //撮影した画像を取得
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)  //取得した画像を写真アルバムに保存する
        
        self.dismiss(animated: true)  //カメラ画面を下げる
    }
    
//〜追加 8/21 カメラ機能追加
    
    var activityMotionManager: CMMotionActivityManager = CMMotionActivityManager()
    var locationManager: CLLocationManager = CLLocationManager()
    var pedometer: CMPedometer = CMPedometer()
    var cadence: Int = 0  //配列保存
//追加↓一行 8/22 距離機能 適正化
    var tempDistance: Int = 0
    var distance: Int = 0
    var duration: Int = 0
    var timer: Timer!
    var isStopping: Bool = false
    var start: CLLocationCoordinate2D!
//編集↓一行 8/20 軌跡追加
    //編集前:var end: CLLocationCoordinate2D!
    //編集後:var coordinates: [CLLocationCoordinate2D] = []
    var coordinates: [CLLocationCoordinate2D] = []
    var totalDistance: Int = 0
    
    
//↓追加〜 8/18 m表示→ km m 表示に変更
    var kiromater: Int = 0
    var mater: Int = 0
//↑〜追加 8/18 m表示→ km m 表示に変更
    
    //ここから
    let goodRun = NSLocalizedString("Good Run!", comment: "")
    let letsRun = NSLocalizedString("Let's Run!", comment: "")
    let unit_cadence = NSLocalizedString("steps/s", comment: "")
    let backTop_alertTitle = NSLocalizedString("Back to TOP?", comment: "")
    let backTop_alertmessage = NSLocalizedString("If you don't save this running record, it's delete.", comment: "")
    let backTop_alertbuckButtonTitle = NSLocalizedString("Back to TOP", comment: "")
    let backTop_alertcancelButtonTitle = NSLocalizedString("Cancel", comment: "")

    
    let message_passed = NSLocalizedString("passed!", comment: "")
    let message_totalDistance = NSLocalizedString("Distance", comment: "")
    let message_totalTime = NSLocalizedString("Time", comment: "")
    let message_nowPace = NSLocalizedString("Now Pace", comment: "")
    let message_nowStepspers = NSLocalizedString("Now Steps/s", comment: "")
    
    //MARK:★★★ここでそれぞれLabel用のText代入
    let labeltext_stop = NSLocalizedString("Stop", comment: "")
    let labeltext_resume = NSLocalizedString("Resume", comment: "")
    
    //ここまで
    
    /*MARK:★*/ var paceMinutes: Int = 0
    /*MARK:★*/ var paceSeconds: Int = 0
    /*MARK:★*/ var pace: Int = 0
    /*MARK:★*/ var pacea: Int = 0
    
    override func viewDidLoad() {  //元々追加されている
        super.viewDidLoad()  //元々追加されている
        
        //↓スワイプ 戻る 無効化
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        //戻るボタン 削除
        self.navigationItem.hidesBackButton = true
        //tabBarController 削除
        
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(elapse), userInfo: nil, repeats: true)
        //74-79 ??
        if CMMotionActivityManager.isActivityAvailable() {
            startActivity()
        }
        if CMPedometer.isCadenceAvailable() && CMPedometer.isDistanceAvailable() {
            startRunning()
        }
        locationManager.delegate = self  // delegateとしてself(自インスタンス)を設定
        locationManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        locationManager.startUpdatingLocation()  // 位置情報更新を指示
        locationManager.allowsBackgroundLocationUpdates = true //バックグラウンドで位置情報更新を指示
        mapView.delegate = self  // delegateとしてself(自インスタンス)を設定
        
        
        //ミス↓:start = locationManager.location?.coordinate
        start = locationManager.location!.coordinate  // 画面を開いた時の現在地を変数startに代入
//追加↓一行 8/20 軌跡追加
        coordinates = [locationManager.location!.coordinate] //変数coordinatesに画面を開いた時の現在地を記録
        
    //画面を表示し続ける(スリープさせない)↓
    //  override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(animated)
        //UIApplication.shared.isIdleTimerDisabled = false
        /* ↑上が
            UIApplication.shared.isIdleTimerDisabled = true の時
             →遷移先の画面でも画面を表示し続ける(スリープさせない/設定を維持)
            UIApplication.shared.isIdleTimerDisabled = false の時
             →遷移先の画面では画面がスリープするように(設定を解除)           */
        
    }
    //画面を表示し続ける(スリープさせない)↑
    var notificationSituation = 1
    func startActivity() {
        activityMotionManager.startActivityUpdates(to: .main) { (activity) in
            guard let activity = activity else {
                return
            }
            let isWalkingOrRunning = activity.walking || activity.running
            DispatchQueue.main.async {
                if isWalkingOrRunning {
                    self.runningStatusLabel.text = "\(self.goodRun)"
                    
                } else {
                    self.runningStatusLabel.text = "\(self.letsRun)"
                    
                }
            }
        }
    }
    
    func startRunning() {
        pedometer.startUpdates(from: Date()) { (data, error) in
            if error != nil {
                print(error as Any)
                return
            }
            
            
            DispatchQueue.main.async {  //配列保存
//編集↓一行 8/22 距離機能 適正化
                //元:self.distance += data?.distance?.intValue ?? 0
                self.distance = data?.distance?.intValue ?? 0
                
                self.cadence = data?.currentCadence?.intValue ?? 0  //配列保存
                
//追加↓一行 8/22 距離機能 適正化
                self.totalDistance = self.distance + self.tempDistance  //再開する前の走行距離も含めた距離を計算

//↓追加〜 8/18 m表示→ km m 表示に変更
                self.kiromater = self.totalDistance / 1000  //totalDistanceを÷1000して_kmの数値を求める
                self.mater = self.totalDistance % 1000  //totalDistanceを÷1000したあまりを計算して_mの数値を求める
//↑〜追加 8/18 m表示→ km m 表示に変更
                self.pacea = self.duration * 1000
                self.pace = self.pacea / self.totalDistance
                self.paceMinutes = self.pace / 60
                self.paceSeconds = self.pace % 60
                
//編集↓一行 8/18 m表示→ km m 表示に変更
                //元:self.runningDistanceLabel.text = "\(self.distance)m"
                self.runningDistanceLabel.text = "\(self.kiromater)km\(self.mater)m"
                
                
                
                self.cadenceLabel.text = "\(self.cadence) \(self.unit_cadence)"  //配列保存
                
                //MARK:ペース表示
                if self.paceMinutes < 10 {
                    if self.paceMinutes != 0 {
                        if self.paceSeconds < 10 {
                            if self.paceSeconds != 0 {
                                self.paceLabel.text = "0\(self.paceMinutes):0\(self.paceSeconds)/km"//09:01
                            } else {
                                self.paceLabel.text = "0\(self.paceMinutes):00/km"//09:00
                            }
                        } else {
                            self.paceLabel.text = "0\(self.paceMinutes):\(self.paceSeconds)/km"//09:12
                        }
                    } else {
                        if self.paceSeconds < 10 {
                            if self.paceSeconds != 0 {
                                self.paceLabel.text = "00:0\(self.paceSeconds)/km"//00:01
                            } else {
                                self.paceLabel.text = "00:00/km"//00:00
                            }
                        } else {
                            self.paceLabel.text = "00:\(self.paceSeconds)/km"//00:12
                        }
                    }
                } else {
                    if self.paceSeconds < 10 {
                        if self.paceSeconds != 0 {
                            self.paceLabel.text = "\(self.paceMinutes):0\(self.paceSeconds)/km"//10:01
                        } else {
                            self.paceLabel.text = "\(self.paceMinutes):00/km"//10:00
                        }
                    } else {
                        self.paceLabel.text = "\(self.paceMinutes):\(self.paceSeconds)/km"//10:12
                    }
                }
                //MARK:ペース表示

            }
        }
    }
    
    
    // ↓ alert + 前の画面へ戻る
    @IBAction func hidesBackItem() {
        let alert: UIAlertController = UIAlertController(title: "\(backTop_alertTitle)",message: "\(backTop_alertmessage)", preferredStyle: UIAlertController.Style.alert)
        let confilmAction: UIAlertAction = UIAlertAction(title: "\(backTop_alertbuckButtonTitle)", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            //↓前の画面へ戻る
            self.navigationController?.popViewController(animated: true)
        })
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "\(backTop_alertcancelButtonTitle)", style: UIAlertAction.Style.cancel, handler:nil)
        
        alert.addAction(confilmAction)
        alert.addAction(cancelAction)
        
        //alertを表示
        present(alert, animated: true, completion: nil)
    }
    // ↑ alert + 前の画面へ戻る
    
    @objc
    func elapse() {
        duration += 1
//↓追加〜 8/20 軌跡追加
        //↓1秒ごとに(位置情報を更新)
        if duration % 1 == 0 {  //もしdurationが1で割れる時
            
            
            coordinates.append(locationManager.location!.coordinate)  //現在地を配列に追加
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)  //配列の中の全ての位置情報をもとにMap上に引かれる線を作成
            mapView.addOverlay(polyline)  //Mapに線を追加(この時点ではまだMapに表示されない)
//↑〜追加 8/20 軌跡追加
        }
        let minutes = duration / 60
        let seconds = duration % 60
        
        //MARK:時間表示
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
        //MARK:時間表示
        
        //start_通知機能_距離等_アプリを開いている時(NotBackground)
        if notificationSituation == kiromater {  // if kmと数が等しい時
            let content = UNMutableNotificationContent()
            content.title = "\(kiromater)km \(message_passed)"
            
            if paceMinutes < 10 {
                    if paceSeconds < 10 {
                        if minutes < 10 {
                                if seconds < 10 {
                                    content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):0\(seconds)\n\(message_nowPace): 0\(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 00:00 01:01 00:01 01:00
                                } else {
                                    content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):\(seconds)\n\(message_nowPace): 0\(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 01:11 00:11
                                }
                        } else {
                            if seconds < 10 {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):0\(seconds)\n\(message_nowPace): 0\(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 11:01 11:00

                            } else {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):\(seconds)\n\(message_nowPace): 0\(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 11:11
                            }
                        }
                        //ペース 00:00 01:01 00:01 01:00
                    } else {
                        if minutes < 10 {
                                if seconds < 10 {
                                    content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):0\(seconds)\n\(message_nowPace): 0\(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 00:00 01:01 00:01 01:00
                                } else {
                                    content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):\(seconds)\n\(message_nowPace): 0\(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 01:11 00:11
                                }
                        } else {
                            if seconds < 10 {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):0\(seconds)\n\(message_nowPace): 0\(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                    //時間 11:01 11:00

                            } else {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):\(seconds)\n\(message_nowPace): 0\(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 11:11
                            }
                        }
                        //ペース 01:11 00:11
                    }
            } else {
                if paceSeconds < 10 {
                    if minutes < 10 {
                            if seconds < 10 {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):0\(seconds)\n\(message_nowPace): \(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 00:00 01:01 00:01 01:00
                            } else {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):\(seconds)\n\(message_nowPace): \(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 01:11 00:11
                            }
                    } else {
                        if seconds < 10 {
                            content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):0\(seconds)\n\(message_nowPace): \(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 11:01 11:00

                        } else {
                            content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):\(seconds)\n\(message_nowPace): \(paceMinutes):0\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                            //時間 11:11
                        }
                    }
                    //ペース 11:01 11:00

                } else {
                    if minutes < 10 {
                            if seconds < 10 {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):0\(seconds)\n\(message_nowPace): \(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 00:00 01:01 00:01 01:00
                            } else {
                                content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): 0\(minutes):\(seconds)\n\(message_nowPace): \(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 01:11 00:11
                            }
                    } else {
                        if seconds < 10 {
                            content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):0\(seconds)\n\(message_nowPace): \(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                                //時間 11:01 11:00

                        } else {
                            content.body = "\(message_totalDistance): \(kiromater)km\n\(message_totalTime): \(minutes):\(seconds)\n\(message_nowPace): \(paceMinutes):\(paceSeconds)/km\n\(message_nowStepspers): \(cadence)\(unit_cadence)"
                            //時間 11:11
                        }
                    }
                    //ペース 11:11
                }
            }
            content.sound = UNNotificationSound.default
                let request = UNNotificationRequest(identifier: "runningNotification\(kiromater)", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            notificationSituation += 1 //notificationSituation+1
        }
        //end_通知機能_距離等_アプリを開いている時(NotBackground)
        
    }
    
    @IBAction func stopRunning() {
        
        if isStopping {
            startRunning()
            startActivity()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(elapse), userInfo: nil, repeats: true)
        } else {
//追加〜↓ 8/22 距離機能 適正化
            tempDistance += distance  //tempDistanceにdistanceを足す
            distance = 0  //distanceを初期化
//↑〜追加 8/22 距離機能 適正化
            pedometer.stopUpdates()
            activityMotionManager.stopActivityUpdates()
            timer.invalidate()
        }
        
        isStopping.toggle()
        
        finishButton.isHidden = !isStopping
        
//        var stopButtonTitleRoald = stopresumeButton.currentTitle
//
//        if stopButtonTitleRoald == labeltext_stop {
//            stopresumeButton.setTitle("\(labeltext_resume)", for: .normal)
//        } else {
//            stopresumeButton.setTitle("\(labeltext_stop)", for: .normal)
//        }
        
        
        if isStopping {
            //MARK:★★★停止時のLabelTextを設定（再開）
//            stopButton.setTitle("\(labeltext_stop)", for: .normal)
            stopresumeButton.setTitle("\(labeltext_resume)", for: .normal)
        } else {
            //MARK:★★★計測時のLabelTextを設定（一時停止）
//            stopButton.setTitle("\(labeltext_resume)", for: .normal)
            stopresumeButton.setTitle("\(labeltext_stop)", for: .normal)

            //MARK:★★★上記のコードが一切効かず、StoryBoardで設定したTextが優先されている
        }
    }
    
    @IBAction func finishRunning() {
//↓追加〜 8/20 軌跡追加
        /* coordinates.append(locationManager.location!.coordinate)  終了した時点での現在地を追加する                             */
//↑〜追加 8/20 軌跡追加
        performSegue(withIdentifier: "toResult", sender: nil)
    }
    
    //配列保存
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResult" {
            //次の画面(SaveRunningViewController)に定数nextVCを移行
            let nextVC = segue.destination as! SaveRunningViewController
            nextVC.cadence = cadence  //毎秒歩数情報を移行
            
//編集↓一行 8/22 距離 適正化
            //前:nextVC.distance = distance
            nextVC.distance = totalDistance  //距離情報を移行
            nextVC.duration = duration  //経過時間情報を移行
//↓追加〜 8/20 軌跡追加
            //走行した位置情報を次の画面へ引き継ぐ。1秒毎に追加した位置情報ひとつひとつを次の画面の変数coordinatesに追加
            for coordinate in coordinates {
                nextVC.coordinates.append([
                    //緯度
                    "latitude": coordinate.latitude,
                    //経度
                    "longitude": coordinate.longitude
                ])
            }
//↑〜追加 8/20 軌跡追加
        }
    }
    //配列保存
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        if location == nil {
            return
        }
        mapView.setRegion(MKCoordinateRegion(center: location!.coordinate, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
    }
    
    //ミス:func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let myPolyLineRendere: MKPolylineRenderer = MKPolylineRenderer(overlay: overlay)  //マップに線(PolyLine)を表示する処理
        myPolyLineRendere.lineWidth = 5  //軌跡の太さを5ptに設定
        myPolyLineRendere.strokeColor = UIColor.systemTeal  //軌跡の色をsystemTealに設定
        
        return myPolyLineRendere  //戻り値を設定
        
    }
}
