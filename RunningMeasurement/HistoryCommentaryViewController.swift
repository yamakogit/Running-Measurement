//
//  HistoryCommentaryViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2020/11/07.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit
import WebKit

class HistoryCommentaryViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let url = URL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0/%E5%8F%96%E6%89%B1%E8%AA%AC%E6%98%8E%E6%9B%B8?authuser=1#h.g6fllpk0m5a1") {
            self.webView.load(URLRequest(url: url))
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func goBackHistory(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
