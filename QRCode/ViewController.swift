//
//  ViewController.swift
//  QRCode
//
//  Created by Ricardo Anjos on 25/10/15.
//  Copyright © 2015 Ricardo Anjos. All rights reserved.
//

import UIKit

class ViewController: UIViewController,ScannerViewControllerDelegate {
    @IBOutlet weak var lblBarcode: UILabel!
    var scannerVC: ScannerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        scannerVC = segue.destinationViewController as! ScannerViewController
        scannerVC.delegate = self
    }
    
    func barcodeObtained(viewController: ScannerViewController, data: String) {
        self.lblBarcode.text = data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}