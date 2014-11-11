//
//  CameraViewController.swift
//  Cutscene
//
//  Created by Andrew Lyons on 01 Nov 14.
//  Copyright (c) 2014 Andrew Lyons. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, UIGestureRecognizerDelegate
{
    // MARK: - PUBLIC VARS
    var originalImage: UIImage!     // Set by previous view
    
    // MARK: - PRIVATE VARS
    // Constants
    let kResizeBorder: CGFloat = 3
    let kResizeHandleVisible: CGFloat = 20
    let kResizeHandleTarget: CGFloat = 44
    
    // Pan/scale event variables:
    var panOriginStart = CGPoint()      // Original position at start of pan
    var panLocationStart = CGPoint()    // Finger location at start of pan
    var scaleStartFrame = CGRect()      // Cut frame dimentions at start of pinch
    var resizeStartFrame = CGRect()     // Cut frame dimentions at start of resize
    
    // MARK: - INTERFACE BUILDER OUTLETS & ACTIONS
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var cutView: UIView!
    @IBOutlet weak var cutImageView: UIImageView!
    @IBOutlet weak var topLeftHandleView: UIView!
    @IBOutlet weak var topRightHandleView: UIView!
    @IBOutlet weak var bottomLeftHandleView: UIView!
    @IBOutlet weak var bottomRightHandleView: UIView!
    @IBOutlet weak var topLeftHandleWhite: UIView!
    @IBOutlet weak var topRightHandleWhite: UIView!
    @IBOutlet weak var bottomLeftHandleWhite: UIView!
    @IBOutlet weak var bottomRightHandleWhite: UIView!
    
    @IBOutlet var panImageGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var pinchImageGestureRecognizer: UIPinchGestureRecognizer!
    
    // Pan anywhere on screen
    @IBAction func onPanImage(sender: UIPanGestureRecognizer)
    {
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began
        {
            // Record pan start:
            panOriginStart.x = cutView.frame.origin.x
            panOriginStart.y = cutView.frame.origin.y
        }
        else if sender.state == UIGestureRecognizerState.Changed
        {
            // Move cut with pan:
            cutView.frame.origin.x = panOriginStart.x + translation.x
            cutView.frame.origin.y = panOriginStart.y + translation.y
        }
        else if sender.state == UIGestureRecognizerState.Ended
        {
            keepCutViewInsideScreen()
        }
    }
    
    // Pinch anywhere on screen
    @IBAction func onPinch(sender: UIPinchGestureRecognizer)
    {
        var scale = sender.scale
        var height = cutView.frame.height
        var width = cutView.frame.width
        
        if sender.state == UIGestureRecognizerState.Began
        {
            scaleStartFrame = cutView.frame
        }
        else if sender.state == UIGestureRecognizerState.Changed
        {
            var newFrame = CGRect()
            
            newFrame.size.width = scaleStartFrame.width * scale
            newFrame.size.height = scaleStartFrame.height * scale
            newFrame.origin.x = scaleStartFrame.origin.x
            newFrame.origin.y = scaleStartFrame.origin.y
        }
        else if sender.state == UIGestureRecognizerState.Ended
        {
            
        }
    }
    
    // Pan top left resize handle
    @IBAction func onPanHandle(sender: UIPanGestureRecognizer)
    {
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began
        {
            resizeStartFrame.origin.x = cutView.frame.origin.x
            resizeStartFrame.origin.y = cutView.frame.origin.y
            resizeStartFrame.size.width = cutView.frame.size.width
            resizeStartFrame.size.height = cutView.frame.size.height
        }
        else if sender.state == UIGestureRecognizerState.Changed
        {
            var newX: CGFloat!
            var newY: CGFloat!
            var newWidth: CGFloat!
            var newHeight: CGFloat!
            
            switch sender.view!
            {
            case topLeftHandleView:
                newX = resizeStartFrame.origin.x + translation.x
                newY = resizeStartFrame.origin.y + translation.y
                newWidth = resizeStartFrame.size.width - translation.x
                newHeight = resizeStartFrame.size.height - translation.y
            case topRightHandleView:
                newX = resizeStartFrame.origin.x
                newY = resizeStartFrame.origin.y + translation.y
                newWidth = resizeStartFrame.size.width - translation.x
                newHeight = resizeStartFrame.size.height - translation.y
            case bottomLeftHandleView:
                newX = resizeStartFrame.origin.x + translation.x
                newY = resizeStartFrame.origin.y
                newWidth = resizeStartFrame.size.width - translation.x
                newHeight = resizeStartFrame.size.height + translation.y
            case bottomRightHandleView:
                newX = resizeStartFrame.origin.x
                newY = resizeStartFrame.origin.y
                newWidth = resizeStartFrame.size.width + translation.x
                newHeight = resizeStartFrame.size.height + translation.y
            default:
                break
            }
            cutView.frame.origin.x = newX
            cutView.frame.origin.y = newY
            cutView.frame.size.width = newWidth
            cutView.frame.size.height = newHeight
            adjustCutFrame()
        }
        else if sender.state == UIGestureRecognizerState.Ended
        {
        }
    }
    
    @IBAction func onCancelButton(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - OVERRIDE FUNCS
    override func viewDidLoad()
    {
        super.viewDidLoad()
        originalImageView.image = originalImage
        panImageGestureRecognizer.delegate = self
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer!, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer!) -> Bool
    {
        return true
    }

    // MARK: - HELPER FUNCS
    // UI updater: If outside screen bounds, animate back. Also min size:
    // TODO: Add minimum size enforcement.
    func keepCutViewInsideScreen()
    {
        var newX = cutView.frame.origin.x
        var newY = cutView.frame.origin.y
        var width = cutImageView.frame.width
        var height = cutImageView.frame.height
        var isBroken = false
        
        if newX < 0
        {
            newX = 0
            isBroken = true
        }
        else if newX + width + kResizeBorder*2 > 320
        {
            newX = 320 - width - kResizeBorder*2
            isBroken = true
        }
        
        if newY < 0
        {
            newY = 0
            isBroken = true
        }
        else if newY + height + kResizeBorder*2 > 568
        {
            newY = 568 - height - kResizeBorder*2
            isBroken = true
        }
        
        if isBroken
        {
            UIView.animateWithDuration(0.2, animations:
            { () -> Void in
                self.cutView.frame.origin.x = newX
                self.cutView.frame.origin.y = newY
            })
        }
    }
    
    // Keep the cut image & handles positioned & sized correctly in the cut view frame:
    func adjustCutFrame()
    {
        // Get the view position:
        var width = cutView.frame.size.width
        var height = cutView.frame.size.height

        // Calculate where the invisible resize handles go:
        var topTarget: CGFloat = 0
        var leftTarget: CGFloat = 0
        var rightTarget: CGFloat = width - kResizeHandleTarget
        var bottomTarget: CGFloat = height - kResizeHandleTarget

        // Calculate where the image goes:
        var topImage: CGFloat = kResizeHandleTarget/2
        var leftImage: CGFloat = topImage
        var widthImage: CGFloat = width - kResizeHandleTarget
        var heightImage: CGFloat = height - kResizeHandleTarget

        // Calculate where the visible corners go:
        var topVisible: CGFloat = topImage - kResizeBorder
        var leftVisible: CGFloat = topVisible
        var rightVisible: CGFloat = kResizeHandleTarget/2 + widthImage - kResizeHandleVisible + kResizeBorder
        var bottomVisible: CGFloat = kResizeHandleTarget/2 + heightImage - kResizeHandleVisible + kResizeBorder
        
        // Position the invisible pan targets:
        topLeftHandleView.frame.origin.x = leftTarget
        topLeftHandleView.frame.origin.y = topTarget
        topRightHandleView.frame.origin.x = rightTarget
        topRightHandleView.frame.origin.y = topTarget
        bottomLeftHandleView.frame.origin.x = leftTarget
        bottomLeftHandleView.frame.origin.y = bottomTarget
        bottomRightHandleView.frame.origin.x = rightTarget
        bottomRightHandleView.frame.origin.y = bottomTarget

        // Position the visible corners:
        topLeftHandleWhite.frame.origin.x = leftVisible
        topLeftHandleWhite.frame.origin.y = topVisible
        topRightHandleWhite.frame.origin.x = rightVisible
        topRightHandleWhite.frame.origin.y = topVisible
        bottomLeftHandleWhite.frame.origin.x = leftVisible
        bottomLeftHandleWhite.frame.origin.y = bottomVisible
        bottomRightHandleWhite.frame.origin.x = rightVisible
        bottomRightHandleWhite.frame.origin.y = bottomVisible
        
        // Position the image:
        cutImageView.frame.origin.y = topImage
        cutImageView.frame.origin.x = leftImage
        cutImageView.frame.size.width = widthImage
        cutImageView.frame.size.height = heightImage
    }
}
