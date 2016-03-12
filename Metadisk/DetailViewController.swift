//
//  DetailViewController.swift
//  Metadisk
//
//  Created by Jan Potuznik on 11.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices

class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = bucket!.name
        
        
        
        loadingLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2, 30, 300, 100))
        loadingLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.5)
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.text = "Uploading Photo"
        loadingLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        loadingLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        self.view.addSubview(loadingLabel)
        
        showloadingLabel(false)
        
        
        downloadImages()
        
        imagePicker.delegate = self
        
    }


    @IBOutlet weak var tempLabel: UILabel!
    
    var bucket: Bucket?
    
    
    
    
    
    
    
    
    @IBAction func addNewPhoto(sender: UIBarButtonItem) {
        howToSelectImage()
    }

    
    
    //MARK: - Download stuff
    
    var files = [String]()
    
    func downloadImages() {
        Alamofire.request(.GET, "https://api.metadisk.org/buckets/\(self.bucket!.id)/files", headers: General.headers).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Downloaded stuff in bucket: \(JSON)")
                
                self.files.removeAll()
                
                let response = JSON as! NSArray
                
                for res in response {
                    let hash = res.objectForKey("hash") as! String
                    let filename = res.objectForKey("filename") as! String
                    
                    self.files.append(hash)
                    self.files.append(filename)

                    
                }
                
                self.tempLabel.text = "Pocet filu: \(self.files.count/2)"
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                }
                
        }
    }
    
    
    
    
    //MARK: - Upload image
    
    func getToken(image: UIImage) {
        let parameters = [
            "operation": "PUSH"
        ]
        
        Alamofire.request(.POST, "https://api.metadisk.org/buckets/\(self.bucket!.id)/tokens",headers: General.headers, parameters: parameters, encoding: .JSON).responseJSON {
            response in switch response.result {
                case .Success(let JSON):
//                    print("response: \(JSON)")
                    let res = JSON
                    
                    let token = res.objectForKey("token") as! String
                
                    self.uploadImageToMetadisk(image, token: token)
                
                case .Failure(let error):
                    print("Error: \(error)")
       
            
            }
        }
    }
    
    
    
    
    func uploadImageToMetadisk(image: UIImage, token: String) {
        
        
        showloadingLabel(true)
        
        let imageData: NSData = UIImagePNGRepresentation(image)!
        
        let imageSize = imageData.length
        
        let modifiedHeader = ["Authorization": "Basic \(General.base64Credentials)", "x-token": "\(token)", "x-Filesize": "\(imageSize)"]
        print("modifHea: \(modifiedHeader)")
        
        
        Alamofire.upload(.PUT, "https://api.metadisk.org/buckets/\(self.bucket!.id)/files", headers: modifiedHeader,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "test6", fileName: "test6.png", mimeType: "image/png")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { JSON in
                        print("--------------")
                        print(JSON)
                        self.showloadingLabel(false)

                    }
                case .Failure(let encodingError):
                    print("!!!!!!!!!!!!!!!!!!!")
                    print(encodingError)
                    self.showloadingLabel(false)
                }
            }
        )
        
        
        
    }
    
    
    
    
    
    var loadingLabel = UILabel()
    
    func showloadingLabel(show: Bool) {
        if show {
            
            loadingLabel.hidden = false
            loadingLabel.alpha = 1
            UIView.animateWithDuration(0.6, delay: 0.3, options:[.Repeat, .Autoreverse], animations: { _ in
                self.loadingLabel.alpha = 0
                }, completion: nil)
        }
        else {
            loadingLabel.hidden = true
            loadingLabel.alpha = 0
            loadingLabel.layer.removeAllAnimations()
        }
    }
    
    
    
    
    
    
    
    
    
    //MARK: - How to upload photo
    
    // create confirmation about upload
    func presentAlert(pickedImage: UIImage) {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Upload this photo?", message: "Do you want to upload this photo to Metadisk?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Ok Logic here")
            
            self.getToken(pickedImage)
        }))
        
        let imageView = UIImageView(frame: CGRectMake(220, 10, 40, 40))
        imageView.image = pickedImage
        imageView.contentMode = .ScaleAspectFit
        alert.view.addSubview(imageView)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    // picking the image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presentAlert(pickedImage)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController()
    
    
    func howToSelectImage() {
        
        //Create the AlertController
        let actionSheetController = UIAlertController(title: "New photo", message: "How do you want add the photo?", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        let takePictureAction = UIAlertAction(title: "Take Photo", style: .Default) { action -> Void in
            //Launch camera
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
                self.imagePicker.mediaTypes = [kUTTypeImage as String]
                self.imagePicker.allowsEditing = false
                self.presentViewController(self.imagePicker, animated: true, completion: nil)
            }
        }
        actionSheetController.addAction(takePictureAction)
        
        
        //Chose from camera roll
        let choosePictureAction = UIAlertAction(title: "Choose From Camera Roll", style: .Default) { action -> Void in
            //Code for picking from camera roll goes here
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .PhotoLibrary
            self.presentViewController(self.imagePicker, animated: true, completion: nil)
            
        }
        actionSheetController.addAction(choosePictureAction)
        
        //We need to provide a popover sourceView when using it on iPad
        actionSheetController.popoverPresentationController?.sourceView = self.view
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
}




