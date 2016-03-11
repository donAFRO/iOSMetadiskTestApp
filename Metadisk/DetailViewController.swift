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
        
        
        imagePicker.delegate = self
        
        tempLabel.text = "name: \(bucket!.name)"
    }


    @IBOutlet weak var tempLabel: UILabel!
    
    var bucket: Bucket?
    
    
    
    
    
    
    
    
    @IBAction func addNewPhoto(sender: UIBarButtonItem) {
        howToSelectImage()
    }

    
    
    
    //MARK: - Upload image
    func uploadImageToMetadisk(image: UIImage) {
       print("bucketID: \(self.bucket!.id)")
        let imageData: NSData = UIImagePNGRepresentation(image)!
       
        Alamofire.upload(
            .POST,
            "https://api.metadisk.org/buckets/\(self.bucket!.id)/files", headers: General.headers,
            multipartFormData: { multipartFormData in
                multipartFormData.appendBodyPart(data: imageData, name: "test1")
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { JSON in
                        print(JSON)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    //MARK: - How to upload photo
    
    // create confirmation about upload
    func presentAlert(pickedImage: UIImage) {
        var alert = UIAlertController()
        alert = UIAlertController(title: "Upload this photo?", message: "Do you want to upload this photo to Metadisk?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
            print("Handle Ok Logic here")
            
            self.uploadImageToMetadisk(pickedImage)
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




