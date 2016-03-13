//
//  BucketsTableViewController.swift
//  Metadisk
//
//  Created by Jan Potuznik on 10.03.16.
//  Copyright © 2016 donAFRO. All rights reserved.
//

import UIKit
import Alamofire

class BucketsTableViewController: UITableViewController {

    
    var buckets = [Bucket]()
    

    
    

    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        let backgroundView = UIView(frame: CGRectZero)
        tableView.tableFooterView = backgroundView
        
        createNoBucketsLabel()
        
        downloadBucketList()
        
        
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buckets.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("bucket", forIndexPath: indexPath)
        let bucket = buckets[indexPath.row]

        cell.textLabel?.text = bucket.name
        cell.detailTextLabel?.text = "Created: \(bucket.created)"
        
        return cell
    }

    
    
    
    
    //MARK: - Prepare for showing bucket detail
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("showCollectionView", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showCollectionView"){
            let controller = (segue.destinationViewController as! CollectionViewController)
            let row = sender!.row //we know that sender is an NSIndexPath here.
            let selectedBucket = buckets[row]
            controller.bucket = selectedBucket
            
        }
        self.tabBarController?.tabBar.hidden = true
    }
    
    
    
    
    
    
    
    //MARK: - Add New Bucket
    @IBAction func addNewBucket(sender: UIBarButtonItem) {
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!)
        {
            textField.placeholder = "Bucket Name"
            tField = textField
        }
        
        

        
        let alert = UIAlertController(title: "Bucket Name", message: "Write new name for a bucket", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Create", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            let newBucketName = tField.text
            self.uploadNewBucket(newBucketName!)
        }))
        self.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    
    func uploadNewBucket(bucketName: String) {
        
        
        
        let parameters = [
            "name": bucketName,
            "storage": 10,
            "transfer": 50
        ]
        
        Alamofire.request(.POST, "https://api.metadisk.org/buckets",headers: General.headers, parameters: parameters as? [String : AnyObject], encoding: .JSON)
        downloadBucketList()
    }
    
    
    
    
    //MARK: - Refresh
    @IBAction func refreshing(sender: UIRefreshControl) {
        downloadBucketList()
    }
    
    
    
    

    //MARK: - Download
    func downloadBucketList() {
        
        Alamofire.request(.GET, "https://api.metadisk.org/buckets", headers: General.headers).responseJSON
            { response in switch response.result {
            case .Success(let JSON):
                print("Success with JSON: \(JSON)")
                
                self.buckets.removeAll()
                
                let response = JSON as! NSArray
                
                for res in response {
                    let id = res.objectForKey("id") as! String
                    let name = res.objectForKey("name") as! String
                    let created = res.objectForKey("created") as! String
                    //                        let pubkeys = res.objectForKey("pubkeys") as! String
                    let status = res.objectForKey("status") as! String
                    let storage = res.objectForKey("storage") as! Int
                    let transfer = res.objectForKey("transfer") as! Int
                    let user = res.objectForKey("user")! as! String
                    
                    self.buckets.append(Bucket(id: id, name: name, status: status, created: created, storage: storage, transfer: transfer, user: user))
                }
                self.refreshControl?.endRefreshing()
                self.tableView.reloadData()

                if self.buckets.count == 0 {
                    self.noBucketsLabel.hidden = false
                } else {
                    self.noBucketsLabel.hidden = true
                }
                
            case .Failure(let error):
                print("Request failed with error: \(error)")
                
                }
                
        }
    }
    


    //MARK: - Create info label
    
    var noBucketsLabel = UILabel()
    
    func createNoBucketsLabel() {
        noBucketsLabel = UILabel(frame: CGRectMake(self.view.frame.size.width/2, 30, 300, 160))
        noBucketsLabel.hidden = true
        noBucketsLabel.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/3)
        noBucketsLabel.textAlignment = NSTextAlignment.Center
        noBucketsLabel.numberOfLines = 0
        noBucketsLabel.text = "You dont have any buckets, add a new Bucket with the + symbol"
        noBucketsLabel.textColor = UIColor(red: 60.0/255.0, green: 60.0/255.0, blue: 60.0/255.0, alpha: 1.0)
        noBucketsLabel.font = UIFont(name: "HelveticaNeue", size: 18)
        self.view.addSubview(noBucketsLabel)
    }
    
    
    
    
    
    //MARK: - Swipes of cells for deleting buckets
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
            let delete = UITableViewRowAction(style: .Normal, title: "Delete") { action, index in
                
                self.deleteBucket(indexPath.row)
                
            }
            delete.backgroundColor = UIColor(red: 239.0/255.0, green: 72.0/255.0, blue: 54.0/255.0, alpha: 1.0)
            return [delete]
        
        
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
   
    func deleteBucket(positionInArray: Int) {

        let bucketForDeletion = buckets[positionInArray]
        let bucketId = bucketForDeletion.id
        
        
        Alamofire.request(.DELETE, "https://api.metadisk.org/buckets/\(bucketId)", headers: General.headers).response
            { response in
                
                print("Response: \(response)")
                
                self.buckets.removeAtIndex(positionInArray)
                self.tableView.reloadData()
                
        }
    }
    

}
