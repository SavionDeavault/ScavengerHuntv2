//
//  InventoryTabItem.swift
//  ScavengerHuntv2
//
//  Created by Savion DeaVault on 12/18/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit

class InventoryTabItem: UITabBarItem {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
      print("tapped!")
      return true
    }
    
}
