//
//  ViewController.swift
//  RunningMeasurement
//
//  Created by Fumiya Tanaka on 2020/08/06.
//  Copyright © 2020 Fumiya Tanaka. All rights reserved.
//

import UIKit

class StartRunningViewController: UIViewController {

    @IBOutlet weak var pedometerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        pedometerButton.layer.cornerRadius = 8
        pedometerButton.layer.shadowColor = UIColor.systemGray4.cgColor
        pedometerButton.layer.shadowOffset = .init(width: 2, height: 2)
        pedometerButton.layer.shadowRadius = 8
        pedometerButton.layer.shadowOpacity = 0.2
    }
}

