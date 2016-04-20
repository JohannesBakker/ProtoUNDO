//
//  ChoosePictureSourceViewController.swift
//  Proto-UNDO
//
//  Created by Vlad Konon on 07.09.15.
//  Copyright (c) 2015 Curly Brackets. All rights reserved.
//

import UIKit
import AssetsLibrary

class ChoosePictureSourceViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var library:ALAssetsLibrary? = nil
    var assetGroup:ALAssetsGroup? = nil
    var assets:NSMutableArray? = nil
    var selectedIndex:Int = -1;
    var inited:Bool = false
    let cellID:String = "picCell"
    var cellSize:CGSize = CGSizeZero
    var backgroundView:UIView? = nil
    let picker = UIImagePickerController()
    @IBOutlet weak var photoCollection: UICollectionView!
    
    @IBOutlet weak var libraryButton: UIButton!
    @IBOutlet weak var line1: UITextField!
    @IBOutlet weak var line2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        if (!inited){
            selectedIndex = -1;
            let ratio:CGFloat = 1;//16./9.;
            
            self.assets = NSMutableArray();
            let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            cellSize = photoCollection.frame.size;
            cellSize.width /= 2.0;
            cellSize.height = cellSize.width/ratio;// (cellSize.width/16.)*9.;
            layout.itemSize = cellSize;
            layout.minimumLineSpacing = 8;
            layout.minimumInteritemSpacing = 4;
            layout.scrollDirection = UICollectionViewScrollDirection.Horizontal
            photoCollection.collectionViewLayout=layout;
            photoCollection.registerClass( PhotoCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
            
            
            let nib:UINib = UINib(nibName: "PhotoCollectionViewCell", bundle: nil)
            photoCollection.registerNib(nib, forCellWithReuseIdentifier: cellID)
            loadPictures();
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "selectNotification:", name: "cellPhotoTaped", object: nil)
            setBorderForView(line1, color: UIColor(white: 0.33, alpha: 0.5), width: 1, radius: 0);
            setBorderForView(line2, color: UIColor(white: 0.33, alpha: 0.5), width: 1, radius: 0);
            picker.delegate = self
            picker.loadView()
            picker.viewDidLoad()
            inited = true
            
        }
        // Do any additional setup after loading the view.
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    @IBAction func libraryAction(sender: AnyObject) {
        if (selectedIndex>=0){
            let asset:ALAsset? = assets![selectedIndex] as? ALAsset
            let image = getAssetImage(asset)
            sendImage(image)
            
        }
        else{
            photoFromLibrary()
        }
    }
    func sendImage(image:UIImage){
        NSNotificationCenter.defaultCenter().postNotificationName("photoSelectionDone", object: nil, userInfo: ["image" : image ])
        remove()
    }
    @IBAction func photoAction(sender: AnyObject) {
        shootPhoto()
    }
    
    @IBAction func cancelAction(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("photoSelectionCancelled", object: nil, userInfo: nil)
        remove()
    }
    func remove()
    {
        if (self.view.superview != nil){
            var frame:CGRect = self.view.frame;
            frame.origin.y = self.view.superview!.frame.size.height
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.backgroundView!.alpha = 0
                self.view.frame = frame
                }, completion: { (finished:Bool) -> Void in
                    self.backgroundView!.removeFromSuperview()
                    self.view.removeFromSuperview()
            })
        }
    }
    @objc func selectNotification(notification:NSNotification) {
        let userInfo:NSDictionary = notification.userInfo!
        let value: Bool! = (userInfo["value"] as! NSNumber).boolValue
        if (value == true){
            let sender: PhotoCollectionViewCell! = userInfo["sender"] as! PhotoCollectionViewCell
            
            let indexPath:NSIndexPath  = self.photoCollection.indexPathForCell(sender as UICollectionViewCell)!
            selectedIndex = indexPath.row
        }
        else {
            selectedIndex = -1
        }
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateLibraryButton()
        })
    }
    func updateLibraryButton(){
        if (selectedIndex>=0){
            libraryButton.setTitle("Post 1 Photo", forState: UIControlState.Normal)
        }
        else{
            libraryButton.setTitle("Photo Library", forState: UIControlState.Normal)
        }
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    func getAssetImage(asset:ALAsset!) -> UIImage{
        let rep:ALAssetRepresentation = asset.defaultRepresentation();
        return UIImage(CGImage: rep.fullScreenImage().takeUnretainedValue() as CGImageRef )
    }
    func getAssetSmallImage(asset:ALAsset!) -> UIImage{
        let image:Unmanaged<CGImageRef>! = asset.thumbnail()
        return UIImage(CGImage: image.takeUnretainedValue() as CGImageRef)
        
    }
    // collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (assets != nil){
            return assets!.count;
        }
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let index = indexPath.row;
        let cell:PhotoCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(cellID, forIndexPath: indexPath) as? PhotoCollectionViewCell
        if (cell != nil){
            if index < assets!.count {
                let asset:ALAsset? = assets![index] as? ALAsset
                cell!.imageView.image = self.getAssetSmallImage(asset);
            }
        }
        return cell!
    }
    func loadPictures()
    {
        self.library = ALAssetsLibrary();
        library?.enumerateGroupsWithTypes(ALAssetsGroupType(Int32(bitPattern: ALAssetsGroupAll)), usingBlock: { (group:ALAssetsGroup?, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if (group != nil){
                if (group!.valueForProperty(ALAssetsGroupPropertyName) as! String == "Camera Roll"){
                    self.assetGroup = group;
                    
                }
            }
            else{
                self.preparePhotos();
            }
            }, failureBlock: nil);
        
        
    }
    func preparePhotos()
    {
        
        assets?.removeAllObjects()
        assetGroup?.enumerateAssetsUsingBlock({ (result:ALAsset?, index:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
            if (result != nil){
                self.assets?.addObject(result!);
            }
            else{
                self.assets = NSMutableArray(array: self.assets!.reverseObjectEnumerator().allObjects);
            }
        })
        
        photoCollection.reloadData()
        
    }
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    //get a photo from the library. We present as a popover on iPad, and fullscreen on smaller devices.
    func photoFromLibrary() {
        picker.allowsEditing = false //2
        picker.sourceType = .PhotoLibrary //3
        picker.modalPresentationStyle = .FullScreen
        showPicker()
    }
    
    //take a picture, check if we have a camera first.
    func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false
        {
            let alert = UIAlertView(title: "Camera", message: "Camera on your device is not available!", delegate: nil, cancelButtonTitle: "OK");
            alert.show()
            return
        }
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
            || UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil
        {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.cameraCaptureMode = .Photo
            picker.modalPresentationStyle = .FullScreen
            showPicker()
        } else {
            noCamera()
        }
    }
    //MARK: - Delegates
    //What to do when the picker returns with a photo
    @objc func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        sendImage(image);
        self.hidePicker()
    }
    //What to do if the image picker cancels.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.hidePicker()
    }
    func showPicker(){
        // add to window instead view
        let window:UIWindow = UIApplication.sharedApplication().windows.first!
        let frame:CGRect = window.frame
        picker.view.frame = frame;
        picker.viewWillAppear(false)
        window.addSubview(picker.view)
        picker.viewDidAppear(false)
    }
    func hidePicker(){
        picker.viewWillDisappear(false)
        picker.view.removeFromSuperview()
        picker.viewDidDisappear(false)
    }
    
}
