//
//  SettingsViewController.swift
//  ScavengerHuntv2
//
//  Created by Savion DeaVault on 12/12/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    
    override func viewDidLoad() {
        tableView.backgroundColor = UIColor.black
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "Characters"
        } else {
            return "TBA"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)
        
        return cell
    }
    
    
    
}
