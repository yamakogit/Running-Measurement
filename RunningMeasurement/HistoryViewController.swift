//
//  HistoryViewController.swift
//  RunningMeasurement
//
//  Created by Fumiya Tanaka on 2020/08/09.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit
import SafariServices
import StoreKit  //レビュー依頼_ポップアップ

func formatDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter.string(from: date)
}

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {  //配列保存

    @IBOutlet var tableView: UITableView!
    
    var runningData: [[String: Any]] = []  //ランニングの各記録を格納するため  //配列保存
    var saveData: UserDefaults = UserDefaults.standard  //ランニングの各記録を格納するため  //配列保存
    
    override func viewDidLoad() {  //元々追加されている
        super.viewDidLoad()  //元々追加されている
        tableView.delegate = self  //TableViewを使用できるようにするため  //配列保存
        tableView.dataSource = self  //TableViewを使用できるようにするため  //配列保存
/* 8/20 削除:
        let data = saveData.array(forKey: "running") as? [[String: Any]] ?? []
        runningData = data
        tableView.reloadData()                                                                 */
    }
    
    @IBAction func goHistoryCommentary(_ sender: Any) {
        let url = NSURL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0/%E5%8F%96%E6%89%B1%E8%AA%AC%E6%98%8E%E6%9B%B8?authuser=1#h.g6fllpk0m5a1")
            
            if let url = url {
                let safariViewController = SFSafariViewController(url: url as URL)
                safariViewController.delegate = self
                present(safariViewController, animated: true, completion: nil)
            }
    }
    
    override func viewWillAppear(_ animated: Bool) {  //TableViewをカスタマイズするため
        super.viewWillAppear(animated)  //TableViewをカスタマイズするため
//追加〜 8/20 詳細表示
        let data = saveData.array(forKey: "running") as? [[String: Any]] ?? []  //ラン保存画面で"running"にランの記録を保存したため、そのデータを定数dataに代入  //配列保存
        runningData = data  //定数dataにあるランの記録をrunningDataに代入  //配列保存
//〜追加 8/20 詳細表示
        tableView.reloadData()  //tableViewを読み込み直している  //配列保存
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return runningData.count
    }  //配列保存
    
    //配列保存
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!  //定数cellに、ラン保存画面で"Cell"に保存したラン記録を代入
        let date = runningData[indexPath.row]["date"] as! Date  //定数dateに、ラン保存画面で"date"に保存した「ランをした日付」の記録を代入
        cell.detailTextLabel?.text = formatDate(date: date)  //cellにある「detail」Labelにランをした日付を表示
        let distance = runningData[indexPath.row]["distance"] as! Int  //定数distanceに、ラン保存画面で"distance"に保存した「ランニングの距離」の記録を代入
        cell.textLabel?.text = "\(distance) m"  //cellにある「Title」Labelに「ランニングの距離」を表示
        cell.accessoryType = .disclosureIndicator  //cellの横に > が表示されるように設定
        return cell  //cellの戻り値を設定
    }
    //配列保存
    
    //追加〜 8/20 詳細表示
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let selectedRunningData = runningData[indexPath.row]  //選択した行のデータを定数selectedRunningDataに格納
        //ミス:performSegue(withIndentifier: "toDetail", sender: selectedRunningData)
        performSegue(withIdentifier: "toDetail", sender: selectedRunningData)          //Main.storyboard上のHistoryViewControllerに接続されているSegueを呼び出す
            //"toDetail"はSegueのIdentifierと呼ばれていて、Storyboard上にある呼び出したいSegueのIdentifierと一致している必要がある
        //配列保存
        
        //Start_レビュー依頼_ポップアップ
        SKStoreReviewController.requestReview()
        //End_レビュー依頼_ポップアップ
}
    
    //セル削除機能↓
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            runningData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath as IndexPath], with: UITableView.RowAnimation.automatic)
            UserDefaults.standard.set(runningData, forKey: "running")  //tableViewのCell削除を反映
            tableView.reloadData()  //tableViewを読み込み直している
        }
        
    }
    //セル削除機能↑

    
    //配列保存
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {  //segueを使用するため
        if segue.identifier == "toDetail" {  //toDetailのsegueに対する処理を行い、詳細画面へデータを引き継ぐ
            let nextVC = segue.destination as! HistorydetailsViewController  //次の画面である「計測履歴 詳細画面」を取得する
            nextVC.selectedRunningData = sender as! [String: Any]  //次の画面である「計測履歴 詳細画面」にラン記録を引き継ぐ
        }
    }
    //〜追加 8/20 詳細表示
    //配列保存
    
}
