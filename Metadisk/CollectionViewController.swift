//
//  CollectionViewController.swift
//  Metadisk
//
//  Created by Jan Potuznik on 13.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import UIKit
import Alamofire
import MobileCoreServices
import SwiftWebSocket



class CollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    var bucket: Bucket? // current bucket
    
    var photoObjects: [NSData]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = bucket!.name
        
        
        

        
        
        // create loading label
        loadingLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2, 30, 300, 100))
        loadingLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2.5)
        loadingLabel.textAlignment = NSTextAlignment.Center
        loadingLabel.text = "Uploading Photo"
        loadingLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        loadingLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        self.view.addSubview(loadingLabel)
        showloadingLabel(false)
        
        
        downloadMetaInformation()
        
        imagePicker.delegate = self
        
    }



    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! CollectionViewCell
    
        // Configure the cell
        
        cell.backgroundColor = UIColor.redColor()
        
        cell.imageView.image = self.photos[1]
        cell.label.text = "\(indexPath.row)"
    
        return cell
    }
    
    

    

    @IBAction func addNewPhoto(sender: UIBarButtonItem) {
        howToSelectImage()
        
    }
    
    
    
    
    
    //MARK: - Websocket
    
    func connectToWebSocket(channel: String, token: String, hash: String){
        let request = NSMutableURLRequest(URL: NSURL(string:"\(channel)")!)
        request.addValue("token", forHTTPHeaderField: "\(token)")
        request.addValue("hash", forHTTPHeaderField: "\(hash)")
//        let ws = WebSocket(request: request)
        
//        ws.event
        
        
    }
    
    
    
    
    
    //MARK: - Download stuff
    
    var photos = [UIImage(named: "storjLabs"), UIImage(named: "IMG_0783")]
    
    
    func downloadImage(token: String, indexInArray: Int) {
        
        let hash = metaArray[indexInArray].hash
        
        let modifiedHeader = ["Authorization": "Basic \(General.base64Credentials)", "x-token": "\(token)"]
        print("modifHea: \(modifiedHeader)")
        
        Alamofire.request(.GET, "https://api.metadisk.org/buckets/\(self.bucket!.id)/files/\(hash)", headers: modifiedHeader).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("IMAGE")
                print(JSON)
                
                
                let response = JSON as! NSArray
                
                for res in response {
                    let channel = res.objectForKey("channel") as! String
                    
                    let hash = res.objectForKey("hash") as! String
                    let token = res.objectForKey("token") as! String
                    
                    self.connectToWebSocket(channel, token: token, hash: hash)

                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                }
                
        }
    }
    
    //start download
    func startDownloadViaWebSocket(channel: String, hash: String, operation: String, token: String) {
       
    }
    
    
    //get token for PULL operation
    func getPullToken(indexInArray: Int) {
        
        let parameters = [
            "operation": "PULL"
        ]
        
        Alamofire.request(.POST, "https://api.metadisk.org/buckets/\(self.bucket!.id)/tokens",headers: General.headers, parameters: parameters, encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                //                    print("response: \(JSON)")
                
                let token = JSON.objectForKey("token") as! String
//                let hash = JSON.objectForKey("hash") as! String
                
                print("token: \(token)")
                
                self.downloadImage(token, indexInArray: indexInArray)
                
            case .Failure(let error):
                print("Error: \(error)")
                
                
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    //class that stores metadata in bucket
    var metaArray = [MetaData]()
    
    //Download metadata about stuff that are in this bucket
    func downloadMetaInformation() {
        Alamofire.request(.GET, "https://api.metadisk.org/buckets/\(self.bucket!.id)/files", headers: General.headers).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("METADATA")
                print(JSON)
                
                self.metaArray.removeAll()
                
                let response = JSON as! NSArray
                
                for res in response {
                    let hash = res.objectForKey("hash") as! String
                    let filename = res.objectForKey("filename") as! String
                    
                    let mimetype = res.objectForKey("mimetype") as! String
                    let size = res.objectForKey("size") as! Int
                    
                    self.metaArray.append(MetaData(fileName: filename, hash: hash, mimetype: mimetype, size: Int64(size)))
    
                    if mimetype.hasSuffix("png") {
                        self.getPullToken(self.metaArray.count - 1)
                    }
                    
                }
                
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                }
                
        }
    }
    
    
    
    
    //MARK: - Upload image
    
    
    //get token for Uploading image
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
    
    
    
    
    
    
    
    //MARK: - Uploading label
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


    
    

