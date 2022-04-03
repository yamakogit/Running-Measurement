//
//  HistorydetailsViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2020/08/10.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit

//追加〜 8/20 詳細表示
import MapKit  //mapを使用できるようにするため
import CoreLocation  //位置情報を使用できるようにするため
//〜追加 8/20 詳細表示

//編集一行↓ 8/20 詳細表示
//元:class HistorydetailsViewController: UIViewController {
class HistorydetailsViewController: UIViewController, MKMapViewDelegate {
    
    //追加〜 8/20 詳細表示
    @IBOutlet var mapView:  MKMapView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var cadenceLabel: UILabel!
    @IBOutlet var elapseTimeLabel: UILabel!
    @IBOutlet var runningFinishedTimeLabel: UILabel!
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var showRunningDateLabel: UILabel!
    
    @IBOutlet weak var designboth保存時刻背景: UIImageView!
    @IBOutlet weak var designboth保存時刻背景影: UIImageView!
    
    @IBOutlet weak var designboth距離背景: UIImageView!
    @IBOutlet weak var designboth距離背景影: UIImageView!
    
    @IBOutlet weak var designboth時間背景: UIImageView!
    @IBOutlet weak var designboth時間背景影: UIImageView!
    
    @IBOutlet weak var designbothペース平均背景: UIImageView!
    @IBOutlet weak var designbothペース平均背景影: UIImageView!
    
    @IBOutlet weak var designboth毎秒歩数背景: UIImageView!
    @IBOutlet weak var designboth毎秒歩数背景影: UIImageView!
    
    //前の画面で選択した記録のデータが入っている
    var selectedRunningData: [String: Any] = [:]  //配列保存
//〜追加 8/20 詳細表示
   
    var unit_cadence = NSLocalizedString("steps/s", comment: "")
    
    override func viewDidLoad() {  //元々追加されている
        super.viewDidLoad()  //元々追加されている
//追加〜 8/20 詳細表示
        mapView.delegate = self  //mapを使用できるようにするため
        //ランニング終了時刻を取得
        let date = selectedRunningData["date"] as! Date  //配列保存
        
        //画面のヘッダー(NavigationBar)に走行した時の日付を表示する
//        navigationItem.title = formatDate(date: date)
        showRunningDateLabel.text = " \(formatDate(date: date))"
        
        //終了時刻をラベルに表示する
        let timeFormmater = DateFormatter()
        timeFormmater.dateStyle = .none
        timeFormmater.timeStyle = .short
        runningFinishedTimeLabel.text = timeFormmater.string(from: date)
        
        //走行距離を取得
        let distance = selectedRunningData["distance"] as! Double
        let distanceInt = selectedRunningData["distance"] as! Int
        //走行距離をラベルに表示
        distanceLabel.text = "\(distance / 1000) km"
        
        //ステップ数を取得
        let cadence = selectedRunningData["cadence"] as! Int  //配列保存
        //ステップ数をラベルに表示
        cadenceLabel.text = "\(cadence)\(unit_cadence)"  //配列保存
        
        
        let duration = selectedRunningData["duration"] as! Int  //経過時間を取得
        
        let minute = duration / 60  //経過時間を÷60して_分の数値を求める
        let second = duration % 60  //経過時間を÷60したあまりを取得して_秒の数値を求める
        
        //経過時間をラベルに表示
        if minute < 10 {
            if minute != 0 {
                if second < 10 {
                    if second != 0 {
                        elapseTimeLabel.text = "0\(minute):0\(second)"//09:01
                    } else {
                        elapseTimeLabel.text = "0\(minute):00"//09:00
                    }
                } else {
                    elapseTimeLabel.text = "0\(minute):\(second)"//09:12
                }
            } else {
                if second < 10 {
                    if second != 0 {
                        elapseTimeLabel.text = "00:0\(second)"//00:01
                    } else {
                        elapseTimeLabel.text = "00:00"//00:00
                    }
                } else {
                    elapseTimeLabel.text = "00:\(second)"//00:12
                }
            }
        } else {
            if second < 10 {
                if second != 0 {
                    elapseTimeLabel.text = "\(minute):0\(second)"//10:01
                } else {
                    elapseTimeLabel.text = "\(minute):00"//10:00
                }
            } else {
                elapseTimeLabel.text = "\(minute):\(second)"//10:12
            }
        }
        if distanceInt != 0 {
        let pacea = duration * 1000
        let pace = pacea / distanceInt
        let paceMinutes = pace / 60
        let paceSeconds = pace % 60
        paceLabel.text = "\(paceMinutes):\(paceSeconds)/km"
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
        } else {
        paceLabel.text = "--:--/km"
        }
        
        //走行した位置のデータを取得
        let locations = selectedRunningData["locations"] as? [[String: Any]] ?? []
        //CLLocationCoordinate2Dを作成(Mapで線を表示するために使用する)
        var coordinates: [CLLocationCoordinate2D] = []
        
        //↓位置情報ひとつひとつを変数coordinatesに追加
        for location in locations {
            //緯度を定数latitudeに代入↓
            let latitude = location["latitude"] as! Double
            //経度を定数longitudeに代入↓
            let longitude = location["longitude"] as! Double
            //緯度・経度を定数coordinateに代入↓
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            coordinates.append(coordinate)  //位置情報をcoordinatesの配列に追加
        }
        let overlay = MKPolyline(coordinates: coordinates, count: coordinates.count)  //配列の中の全ての位置情報をもとにMap上に引かれる線を作成
        mapView.addOverlay(overlay)  //Mapに線を追加(この時点ではまだMapに表示されない)
        //編集〜 8/22 詳細 適正表示
        //前:mapView.setRegion(MKCoordinateRegion(center: coordinates.last!, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
         // 位置情報の要素が1つ以上ある場合↓(のみに限定・ない場合は実施しないコード)
        if !coordinates.isEmpty{
            mapView.setRegion(MKCoordinateRegion(center: coordinates.last!, latitudinalMeters: 100, longitudinalMeters: 100), animated: true)
        }
        //〜編集 8/22 詳細 適正表示
        
        designboth保存時刻背景.layer.cornerRadius = 8
        designboth保存時刻背景影.layer.cornerRadius = 8
        
        designboth距離背景.layer.cornerRadius = 8
        designboth距離背景影.layer.cornerRadius = 8
        
        designboth時間背景.layer.cornerRadius = 8
        designboth時間背景影.layer.cornerRadius = 8
        
        designbothペース平均背景.layer.cornerRadius = 8
        designbothペース平均背景影.layer.cornerRadius = 8
        
        designboth毎秒歩数背景.layer.cornerRadius = 8
        designboth毎秒歩数背景影.layer.cornerRadius = 8
        
        }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {  //マップに線(PolyLine)を表示する処理
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 5  //軌跡の太さを5ptに設定
        renderer.strokeColor = UIColor.systemTeal  //軌跡の色をsystemTealに設定
        return renderer  //rendererの戻り値を設定
    }
}
