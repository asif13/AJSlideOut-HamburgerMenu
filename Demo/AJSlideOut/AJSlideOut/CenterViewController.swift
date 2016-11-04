//
//  CenterViewController.swift
//  AJSlideOut
//
//  Created by Asif Junaid on 11/4/16.
//  Copyright © 2016 Asif Junaid. All rights reserved.
//

import Foundation
import UIKit
class CenterViewController:UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func slideOut(_ sender: UIButton) {
        delegate?.toggleLeftPanel!()
    }
    
}
