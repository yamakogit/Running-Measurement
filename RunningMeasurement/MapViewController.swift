//
//  MapViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2020/08/09.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit
import CoreLocation  //位置情報を使用できるようにするため
import MapKit  //Mapを使用できるようにするため
import SafariServices

class MapViewController: UIViewController, CLLocationManagerDelegate ,UITextFieldDelegate, SFSafariViewControllerDelegate {  //位置情報・検索バーを使用できるようにするため
    
    @IBAction func goMapCommentary(_ sender: Any) {
        let url = NSURL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0/%E5%8F%96%E6%89%B1%E8%AA%AC%E6%98%8E%E6%9B%B8?authuser=1#h.tkm59zjowjis")
            
            if let url = url {
                let safariViewController = SFSafariViewController(url: url as URL)
                safariViewController.delegate = self
                present(safariViewController, animated: true, completion: nil)
            }
    }
    
//MARK:↓追加〜 8/17 地図拡大・縮小機能追加
     /*位置情報の更新と拡大/縮小2つの影響で変数mapViewの値が変更される可能性がある。
    　　mapViewが同時に変更されてしまい、アプリが異常終了されてしまうのを防ぐため、
     排他(lock)変数を追加↓*/
    var myLock = NSLock()
    
     //比率を定数として定義
    let goldenRatio = 1.618
//MARK:↑〜追加 8/17 地図拡大・縮小機能追加

    @IBOutlet var mapView: MKMapView!
    var locatioManager: CLLocationManager!
    
//MARK:↓追加〜 8/17 地図拡大・縮小機能追加
      //拡大処理の内容を記述する
    @IBAction func clickZoomin(_ sender: Any) {
        print("[DBG]clickzoomin")
        myLock.lock()
        if (0.0005 < mapView.region.span.latitudeDelta / goldenRatio) {
            
            //エラー箇所↓ "Value of type 'MKCoordinateSpan' has no member 'description'"
              //解決:×〜span.description　○〜span.latitudeDelta.description
            print("[DBG]latitudeDelta-1 : " + mapView.region.span.latitudeDelta.description)
            
            var regionSpan:MKCoordinateSpan = MKCoordinateSpan()
            regionSpan.latitudeDelta = mapView.region.span.latitudeDelta / goldenRatio
            mapView.region.span = regionSpan
            
            
            //エラー箇所↓ "Value of type 'MKCoordinateSpan' has no member 'description'"
              //解決:×〜span.description　○〜span.latitudeDelta.description
            print("[DBG]latitudeDelta-2 : " + mapView.region.span.latitudeDelta.description)
            
        }
        myLock.unlock()
    }
    
      //縮小処理の内容を記述する
    @IBAction func clickZoomout(_ sender: Any) {
        print("[DBG]clickzoomout")
        myLock.lock()
        if (mapView.region.span.latitudeDelta * goldenRatio < 150.0) {
            print("[DBG]latitudeDelta-1 : " + mapView.region.span.latitudeDelta.description)
            var regionSpan:MKCoordinateSpan = MKCoordinateSpan()
            regionSpan.latitudeDelta = mapView.region.span.latitudeDelta * goldenRatio
//            regionSpan.latitudeDelta = mapView.region.span.latitudeDelta * GoldenRatio
            mapView.region.span = regionSpan
            print("[DBG]latitudeDelta-2 : " + mapView.region.span.latitudeDelta.description)
        }
        myLock.unlock()
    }
//MARK:↑〜追加 8/17 地図拡大・縮小機能追加
    
    override func viewDidLoad() {  //元々追加されている
        super.viewDidLoad()  //元々追加されている

        // Do any additional setup after loading the view.
//MARK:追加↓一行 8/16 検索機能追加
        inputText.delegate = self  //Text Fieldのdelegate通知先を設定(Text Fieldを使用できるようにするため)
        
        locatioManager = CLLocationManager()// 変数を初期化
        locatioManager.delegate = self  // delegateとしてself(自インスタンス)を設定
        locatioManager.startUpdatingLocation()  // 位置情報更新を指示
        locatioManager.requestWhenInUseAuthorization()  // 位置情報取得の許可を得る
        
        mapView.showsUserLocation = true  //現在地を地図に表示する
        
    }
    
    //MARK:↓追加〜 8/16 検索機能追加
    @IBOutlet weak var inputText: UITextField!
    
    //検索バーに関するコードを入力する準備
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //キーボードを閉じる
        textField.resignFirstResponder()
        
        //入力された文字を取り出す
        let searchKeyword = textField.text
        
        //入力された文字をpcに表示
        print(searchKeyword)
        
        //CLGeocoderインスタンスを取得
        let geocoder = CLGeocoder()
        
        //入力された文字から位置情報を取得
        geocoder.geocodeAddressString(searchKeyword!, completionHandler: { (placemarks:[CLPlacemark]?, error:Error?) in
            
            //位置情報が存在する場合１件目の位置情報をplacemarkに取り出す
            if let placemark = placemarks?[0] {
                
                //位置情報から緯度経度が存在する場合、経度緯度をtargetCoordinateに取り出す
                if let targetCoordinate = placemark.location? .coordinate{
                    
                    //位置情報をpcに表示
                    print(targetCoordinate)
                    
                    //MKPointAnnotationインスタンスを取得し、ピンを生成
                    let pin = MKPointAnnotation()
                    
                    //ピンを置く場所の緯度経度を設定
                    pin.coordinate = targetCoordinate
                    
                    //ピンのタイトルを設定
                    pin.title = searchKeyword
                    
                    //ピンを地図に置く
                    self.mapView.addAnnotation(pin)
                    
                    //エラー箇所↓ 8/17　緯度経度を中心にして半径500mの範囲を表示
                    self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                    
                }
            }
        })
        
        //デフォルト動作を行うのでtrueを返す
        return true
    }
//MARK:↑〜追加 8/16 検索機能追加
    
//MARK:↓追加〜 8/17 地図切替機能追加
    @IBAction func changeMapButtonAction(_ sender: AnyObject) {
        //mapTypeプロパティー値トグル
        //標準(.standard)→航空写真(.satellite)→航空写真+標準(.hybrid)
        //→ 3D Flyover(satelliteFlyover)→3D Flyover+標準 (.hybridFlyover)
        if mapView.mapType == .standard {
            mapView.mapType = .satellite
        } else  if mapView.mapType == .satellite {
            mapView.mapType = .hybrid
        } else  if mapView.mapType == .hybrid {
            mapView.mapType = .satelliteFlyover
        } else  if mapView.mapType == .satelliteFlyover {
            mapView.mapType = .hybridFlyover
        } else {
            mapView.mapType = .standard
        }
    }
//MARK:↑〜追加 8/17 地図切替機能追加
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]){
        let longitude = (locations.last?.coordinate.longitude.description)!
        let latitude = (locations.last?.coordinate.latitude.description)!
        
        print("[DBG]longitude : " + longitude)
        print("[DBG]latitude : " + latitude)
        
        //画面中央を現在地に設定↓
        //myLock.lock()
        //mapView.setCenter((locations.last?.coordinate)!, animated: true)
        //myLock.unlock()

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
    //MARK:追加〜 8/22 現在地ボタン
    @IBAction func nowPlace(_ sender: Any){  //Main.StoryBoard上の現在地Buttonと関連付けを行うため

    var region:MKCoordinateRegion = mapView.region  //現在地を格納するため
    region.center = mapView.userLocation.coordinate  //現在地を中央に設定
    //拡大の設定
    region.span.latitudeDelta = 0.02  //緯度0.02°分に設定
    region.span.longitudeDelta = 0.02  //経度の幅を0.02°分に設定
    
    mapView.setRegion(region, animated: true)}  //現在地へ拡大して移動する際、アニメーションで滑らかに拡大/移動するよう設定
    //MARK:〜追加 8/22 現在地ボタン
}
