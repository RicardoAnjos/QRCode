//
//  ScannerViewController.swift
//  QRCode
//
//  Created by Ricardo Anjos on 25/10/15.
//  Copyright © 2015 Ricardo Anjos. All rights reserved.
//

import UIKit
import AVFoundation

//---to be implemented by the view controller calling this view controller---
protocol ScannerViewControllerDelegate {
    
    //---close the current View controller and return the barcode obtained---
    func barcodeObtained(viewController: ScannerViewController,
        data: String)
    
}
class ScannerViewController: UIViewController,
    AVCaptureMetadataOutputObjectsDelegate
{
    //---delegate to handle the barcodeObtained method---
    var delegate: ScannerViewControllerDelegate?
    var captureSession: AVCaptureSession!
    var device : AVCaptureDevice!
    var deviceInput: AVCaptureDeviceInput!
    var metadataOutput : AVCaptureMetadataOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
    var barcodeCapturedView : UIView!
    var audioPlayer:AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //---view to display a border around the captured barcode---
        barcodeCapturedView = UIView()
        barcodeCapturedView.autoresizingMask = [.FlexibleTopMargin , .FlexibleLeftMargin , .FlexibleRightMargin , .FlexibleBottomMargin];
        
        //---draw a yellow border around the barcode scanned---
        barcodeCapturedView.layer.borderColor = UIColor.yellowColor().CGColor
        barcodeCapturedView.layer.borderWidth = 5;
        self.view.addSubview(barcodeCapturedView)
        
        //---set up the AVCaptureSession together with the AVCaptureDevice and AVCaptureDeviceInput---
        captureSession = AVCaptureSession()
        device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(deviceInput)
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
        
        //---set up the delegate for the AVCaptureMetadataOutput so that you can process the scanned barcode---
        metadataOutput = AVCaptureMetadataOutput()
        metadataOutput.setMetadataObjectsDelegate(self,
            queue:dispatch_get_main_queue())
        captureSession.addOutput(metadataOutput)
        metadataOutput.metadataObjectTypes =
            metadataOutput.availableMetadataObjectTypes
        
        //---the layer to preview the video capturing the barcode---
        previewLayer = AVCaptureVideoPreviewLayer(session:captureSession)
        previewLayer.frame = self.view.bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.addSublayer(previewLayer)
        self.view.bringSubviewToFront(barcodeCapturedView)
        
        //---start scanning---
        captureSession.startRunning()
    }
    
    //---fired when the barcode is captured---
    func captureOutput(
        captureOutput: AVCaptureOutput!,
        didOutputMetadataObjects metadataObjects: [AnyObject]!,
        fromConnection connection: AVCaptureConnection!) {
            var barcodeCapturedRect = CGRectZero
            var barCodeObject : AVMetadataMachineReadableCodeObject
            var barcodeScanned = ""
            
            //---types of symbologies recognized---
            let symbologies = [
                AVMetadataObjectTypeUPCECode,
                AVMetadataObjectTypeCode39Code,
                AVMetadataObjectTypeCode39Mod43Code,
                AVMetadataObjectTypeEAN13Code,
                AVMetadataObjectTypeEAN8Code,
                AVMetadataObjectTypeCode93Code,
                AVMetadataObjectTypeCode128Code,
                AVMetadataObjectTypePDF417Code,
                AVMetadataObjectTypeQRCode,
                AVMetadataObjectTypeAztecCode,
                AVMetadataObjectTypeInterleaved2of5Code,
                AVMetadataObjectTypeITF14Code,
                AVMetadataObjectTypeDataMatrixCode
                ]
            
            //---loop through the metadata and see if they match any of the supported symbologies---
            for metadata in metadataObjects {
                for symbology in symbologies{
                    if metadata.type == symbology {
                        //---get the screen coordinates of the barcode scanned---
                        
                        barCodeObject =
                            previewLayer.transformedMetadataObjectForMetadataObject(
                                metadata as! AVMetadataMachineReadableCodeObject) as!
                        AVMetadataMachineReadableCodeObject
                        barcodeCapturedRect = barCodeObject.bounds;
                        barcodeScanned = (metadata as!
                            AVMetadataMachineReadableCodeObject).stringValue
                        
                        //---play a beep sound---
                        playSound()
                        
                        //---outline the barcode that is detected---
                        barcodeCapturedView.frame =
                        barcodeCapturedRect;
                        
                        //---stop the scanning---
                        captureSession.stopRunning()
                        break;
                    }
                }
                if barcodeScanned != "" {
                    break;
                }
                else {
                    barcodeScanned = "No barcode detected"
                }
            }
            
            //---close the window, return the barcode scanned, and return to the previous View controller---
            delegate?.barcodeObtained(self, data: barcodeScanned)
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //---play a beep sound---
    func playSound() {
        let soundFilePath =
        NSBundle.mainBundle().pathForResource("beep",
            ofType:"mp3")
        let fileURL = NSURL(string: soundFilePath!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: fileURL!)
            audioPlayer.play()
        } catch let error as NSError {
            // Handle any errors
            print(error)
        }
    }
}