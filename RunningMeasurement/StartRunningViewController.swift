//
//  ViewController.swift
//  RunningMeasurement
//
//  Created by Fumiya Tanaka on 2020/08/06.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit  //事前に追加されている
import CoreLocation  //位置情報を使用できるようにするため
import MapKit  //Mapを使用できるようにするため
import AVFoundation
import WebKit
import SafariServices
import UserNotifications //通知機能_許可

class StartRunningViewController: UIViewController, CLLocationManagerDelegate, SFSafariViewControllerDelegate {

    @IBOutlet weak var pedometerButton: UIButton!  //スタートボタンと関連付けを行うため
    @IBOutlet var mapView: MKMapView!  //mapと関連付けを行うため
    @IBOutlet weak var webView: WKWebView!
    
    var locatioManager: CLLocationManager!  //位置情報を格納するための変数を宣言
    var alertController: UIAlertController! //alertの変数
    
    let startPlayer = try! AVAudioPlayer(data: NSDataAsset(name: "start")!.data)
    
    @IBAction func tapStartButton(){
        startPlayer.currentTime = 0
        startPlayer.play()
    }
    
    @IBAction func goRunningCommentary(_ sender: Any) {
    let url = NSURL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0/%E5%8F%96%E6%89%B1%E8%AA%AC%E6%98%8E%E6%9B%B8?authuser=1#h.daylgdit512j")
        
        if let url = url {
            let safariViewController = SFSafariViewController(url: url as URL)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func goAppstore(_ sender: Any){
        let url = URL(string: "https://apps.apple.com/jp/app/k-running/id1539391383")!
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
    
    override func viewDidLoad() {  //事前に追加されている
        super.viewDidLoad()  //事前に追加されている
        pedometerButton.layer.cornerRadius = 8  //角を角丸に設定
        pedometerButton.layer.shadowColor = UIColor.systemGray4.cgColor  //影の色を設定
        pedometerButton.layer.shadowOffset = .init(width: 2, height: 2)  //影の方向を設定
        pedometerButton.layer.shadowRadius = 8  //影のぼかしを設定
        pedometerButton.layer.shadowOpacity = 0.2  //影の色の透明度を設定
        locatioManager = CLLocationManager()  // 変数を初期化
               locatioManager.delegate = self  // delegateとしてself(自インスタンス)を設定
               
               locatioManager.startUpdatingLocation()  // 位置情報更新を指示
               locatioManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
               
               mapView.showsUserLocation = true  //現在地を地図に表示する
        
        super.viewDidLoad()
        if let url = URL(string: "https://sites.google.com/view/k-running-info/%E3%83%9B%E3%83%BC%E3%83%A0") {
            self.webView.load(URLRequest(url: url))
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){ //位置情報更新時に処理を呼び出すためのコード
    let longitude = (locations.last?.coordinate.longitude.description)!  //位置情報の経度を定数longitudeに代入
    let latitude = (locations.last?.coordinate.latitude.description)!  //位置情報の緯度を定数latitudeに代入
    print("[DBG]longitude : " + longitude)// 取得した位置情報の経度をデモの際にPCに表示する
    print("[DBG]latitude : " + latitude)// 取得した位置情報の緯度をデモの際にPCに表示する
    mapView.setCenter((locations.last?.coordinate)!, animated: true)  //現在地を地図の中央に表示する
    mapView.setUserTrackingMode(MKUserTrackingMode.followWithHeading, animated: true) //現在地の方向を表示する
}
    
    
    
    //MARK:alert 準備
    func alert(title:String, message:String) {
        alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true)
    }
    
    //通知準備
    
    
    //MARK: 位置情報 催促 alert ↓
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined: break
        case .restricted:
            alert(title: "位置情報の使用を\n許可してください",message: "位置情報の使用を許可しない場合、\nアプリがクラッシュします。\n正しく使用するには、\n位置情報の使用を許可してください。")
            //start_通知
            let content = UNMutableNotificationContent()
            content.title = "位置情報の使用を許可してください"
            content.body = "位置情報の使用を許可しない場合、\nアプリがクラッシュします。\n正しく使用するには、位置情報の使用を許可してください。"
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: "locationRestrictedNotification", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            //end_通知
        case .authorizedAlways:
            alert(title: "位置情報の許可を[App使用中のみ]にすることをお勧めします",message: "[このApp使用中のみ]でも、\nこのアプリは正常に作動します")
            //start_通知
            let content = UNMutableNotificationContent()
            content.title = "位置情報の許可を[App使用中のみ]にすることをお勧めします"
            content.body = "[App使用中のみ]でも、このアプリは正常に作動します。"
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: "locationAlwaysNotification", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            //end_通知
        case .authorizedWhenInUse: break
            
        @unknown default:
            alert(title: "位置情報の使用を\n許可していますか？",message: "位置情報の使用を許可していない場合、\nアプリがクラッシュします。\n正しく使用するには、\n位置情報の使用を許可してください。")
            //start_通知
            let content = UNMutableNotificationContent()
            content.title = "位置情報の使用を許可していますか？"
            content.body = "位置情報の使用を許可していない場合、\nアプリがクラッシュします。\n正しく使用するには、位置情報の使用を許可してください。"
            content.sound = UNNotificationSound.default
            let request = UNNotificationRequest(identifier: "locationDefaultNotification", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            //end_通知
        }
    }
 //MARK: ↑ 位置情報 催促 alert
    
    //MARK: start_通知機能_許可_催促_alert
    /*
    UNUserNotificationCenter.current().getNotificationSettings{ (settings) in
    switch settings.authorizationStatus {
        case .authorized:
            break
        case .denied:
            break
        case .notDetermined:
            break
        }
    }
 */
    //MARK: end_通知機能_許可_催促_alert
    //バッジ_削除
   
}



