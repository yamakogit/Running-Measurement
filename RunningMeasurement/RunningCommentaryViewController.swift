//
//  RunningCommentaryViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2020/10/06.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit
import WebKit

class RunningCommentaryViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0/%E5%8F%96%E6%89%B1%E8%AA%AC%E6%98%8E%E6%9B%B8?authuser=1#h.daylgdit512j") {
            self.webView.load(URLRequest(url: url))
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func goBackRunning(_ sender: Any) {
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
