//
//  InventoryViewController.swift
//  ScavengerHuntv2
//
//  Created by Savion DeaVault on 12/12/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit

class InventoryViewController: UIViewController {
    
    
    @IBOutlet weak var diamondsImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diamondsImageView.image = UIImage.gifImageWithName("diamond1")
        diamondsImageView.largeContentTitle = "Test!"
        textField.isEnabled = false
        
    }
    
    
}
