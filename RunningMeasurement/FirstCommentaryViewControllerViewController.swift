//
//  FirstCommentaryViewControllerViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2020/11/08.
//  Copyright © 2020 Koki Yamada. All rights reserved.
//

import UIKit
import WebKit

class FirstCommentaryViewControllerViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    
    let firstCommentary_url = NSLocalizedString("English_urlを入力", comment: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
            if let url = URL(string: "https://sites.google.com/view/k-running/%E3%83%9B%E3%83%BC%E3%83%A0") {
                self.webView.load(URLRequest(url: url))
            }
            // Do any additional setup after loading the view.
        }
    @IBAction func goBackRunning(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
        // Do any additional setup after loading the view.
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
