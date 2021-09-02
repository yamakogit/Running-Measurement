//
//  TabBarViewController.swift
//  RunningMeasurement
//
//  Created by 山田航輝 on 2021/01/17.
//  Copyright © 2021 Koki Yamada. All rights reserved.
//
//課題
import UIKit

class TabBarController: UITabBarController {
        // Do any additional setup after loading the view.
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem){
        switch item.tag {
        case 1:
            /*let alert: UIAlertController = UIAlertController(title: "ランニング計測 トップ画面\nに戻りますか？",message: "現在計測中の記録を保存していない場合、この記録は削除されます。", preferredStyle: UIAlertController.Style.alert)
            let confilmAction: UIAlertAction = UIAlertAction(title: "トップ画面へ", style: UIAlertAction.Style.default, handler:{
                (action: UIAlertAction!) -> Void in
                //↓前の画面へ戻る
                self.navigationController?.popViewController(animated: true)
            })
            
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:nil)
            
            alert.addAction(confilmAction)
            alert.addAction(cancelAction)
            
            //alertを表示
            present(alert, animated: true, completion: nil)
            */
            break
        default:
            break
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
    
}
//課題

