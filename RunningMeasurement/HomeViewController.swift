//
//  HomeViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2021/01/23.
//  Copyright © 2021 Koki Yamada. All rights reserved.
//

import UIKit
import WebKit
import SafariServices

class HomeViewController: UIViewController, SFSafariViewControllerDelegate {

    //Start_webview_お知らせバナー
    @IBOutlet weak var webView: WKWebView!
    
    
    //ここから
    let verinfo_url = NSLocalizedString("https://sites.google.com/view/k-running-info-eng/%E3%83%9B%E3%83%BC%E3%83%A0", comment: "")
    let gocommentary_url = NSLocalizedString("https://sites.google.com/view/k-running-eng/instruction", comment: "")
    let goform_url = NSLocalizedString("https://docs.google.com/forms/d/e/1FAIpQLSddxTl1-mQxsWgna6zRUp0vokm5yq9ppEBmbkBW-mRdDX3NDw/viewform", comment: "")
    let goNewFunction_url = NSLocalizedString("https://sites.google.com/view/k-running-eng/home/update-new-functions", comment: "")
    //ここまで
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        if let url = URL(string: "\(verinfo_url)") {
            self.webView.load(URLRequest(url: url))
        }
    }
    //End_webview_お知らせバナー
    //Start_button_取扱説明書へ
    @IBAction func gocommentary(_ sender: Any) {
        let url = NSURL(string: "\(gocommentary_url)")
        if let url = url {
            let safariViewController = SFSafariViewController(url: url as URL)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    //End_button_取扱説明書へ
    //Start_button_入力フォームへ
    @IBAction func goform(_ sender: Any) {
        let url = NSURL(string: "\(goform_url)")
        if let url = url {
            let safariViewController = SFSafariViewController(url: url as URL)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    //End_button_入力フォームへ
    //Start_button_新機能を見る
    @IBAction func goNewFunction(_ sender: Any) {
        let url = NSURL(string: "\(goNewFunction_url)")
        if let url = url {
            let safariViewController = SFSafariViewController(url: url as URL)
            safariViewController.delegate = self
            present(safariViewController, animated: true, completion: nil)
        }
    }
    //End_button_新機能を見る
    //Start_button_AppStoreへ
    @IBAction func goAppStore(_ sender: Any) {
        let url = URL(string: "https://apps.apple.com/jp/app/k-running/id1539391383")!
        if UIApplication.shared.canOpenURL(url){
            UIApplication.shared.open(url)
        }
    }
    //End_button_入力フォームへ
    
    /*
    //start_button_ランニング画面へ
    @IBAction func goRunning() {
        self.tabBarController?.selectedIndex = 1
    }
    //end_button_ランニング画面へ
    //start_button_地図画面へ
    @IBAction func goMap() {
        self.tabBarController?.selectedIndex = 2
    }
    //end_button_地図画面へ
    //start_button_計測履歴画面へ
    @IBAction func goHistory() {
        self.tabBarController?.selectedIndex = 3
    }
    //end_button_計測履歴画面へ
*/
 
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        
        if ud.bool(forKey: firstLunchKey){
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            self.performSegue(withIdentifier: "Commentary", sender: nil)
        }
        
    }
}
