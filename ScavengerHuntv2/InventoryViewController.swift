//
//  InventoryViewController.swift
//  ScavengerHuntv2
//
//  Created by Savion DeaVault on 12/12/19.
//  Copyright © 2019 Savion DeaVault. All rights reserved.
//

import UIKit
import CoreData

class InventoryViewController: UIViewController {
    
    var viewController : ViewController? = ViewController(nibName: nil, bundle: nil)
                                        
    @IBOutlet weak var diamondsImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        diamondsImageView.image = UIImage.gifImageWithName("diamond1")
        diamondsImageView.largeContentTitle = "Test!"
        textField.isEnabled = false
        
        let managedContext =
        AppDelegate.persistentContainer().viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Inventory")
        request.returnsObjectsAsFaults = false
        do{
            let results = try managedContext.fetch(request)
            for item in results as! [NSManagedObject] {
                let diamondMarkersCount = item.value(forKey: "diamondmarkers") as! Int
                print(diamondMarkersCount)
                textField.text = "x\(diamondMarkersCount) diamonds"
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}
