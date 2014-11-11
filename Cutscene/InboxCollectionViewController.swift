//
//  InboxCollectionViewController.swift
//  Cutscene
//
//  Created by Andrew Lyons on 06 Nov 14.
//  Copyright (c) 2014 Andrew Lyons. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "Cell"

class InboxCollectionViewController: UICollectionViewController, PHPhotoLibraryChangeObserver
{
    // MARK: - PUBLIC VARS
    // MARK: - PRIVATE VARS
    var images: PHFetchResult! = nil
    let imageManager = PHCachingImageManager()

    // MARK: - INTERFACE BUILDER OUTLETS & ACTIONS
    @IBAction func onTapPhoto(sender: UITapGestureRecognizer)
    {
        performSegueWithIdentifier("cameraSegue", sender: sender.view)  // Send the cell's imageView that was tapped.
    }

    // MARK: - OVERRIDE FUNCS
    override func viewDidLoad()
    {
        super.viewDidLoad()
        images = PHAsset.fetchAssetsWithMediaType(.Image, options: nil)
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView.registerClass(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - HELPER FUNCS
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotosCollectionViewCell
    
        // Configure the cell
        cell.imageManager = imageManager
        cell.imageAsset = images[indexPath.item] as? PHAsset
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "cameraSegue"
        {
// Why doesn't this work???
//        switch segue.identifier
//        {
//        case "cameraSegue":
            var toViewControler = segue.destinationViewController as CameraViewController
            // TODO: change to get the image from the tapped cell.
            toViewControler.originalImage = UIImage(named: "original_scene2")
            
//        default:
//            break
        }
    }

    // MARK: PHPhotoLibraryChangedObserver
    func photoLibraryDidChange(changeInstance: PHChange!)
    {
        let changeDetails = changeInstance.changeDetailsForFetchResult(images)
        
        self.images = changeDetails.fetchResultAfterChanges
        dispatch_async(dispatch_get_main_queue())
        {
            // Loop through the visible cell indices
            let indexPaths = self.collectionView.indexPathsForVisibleItems()
            for indexPath in indexPaths as [NSIndexPath]
            {
                if changeDetails.changedIndexes.containsIndex(indexPath.item)
                {
                    let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as PhotosCollectionViewCell
                    cell.imageAsset = changeDetails.fetchResultAfterChanges[indexPath.item] as? PHAsset
                }
            }
        }
    }

    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool 
    {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool 
    {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool 
    {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool 
    {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) 
    {
    
    }
    */

}
