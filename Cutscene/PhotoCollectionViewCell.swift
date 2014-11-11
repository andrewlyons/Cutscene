//
//  PhotoCollectionViewCell.swift
//  Cutscene
//
//  Created by Andrew Lyons on 06 Nov 14.
//  Copyright (c) 2014 Andrew Lyons. All rights reserved.
//

import UIKit
import Photos

class PhotosCollectionViewCell: UICollectionViewCell
{
    // MARK: - PUBLIC VARS
    var imageManager: PHImageManager?
    var imageAsset: PHAsset?
    {
        didSet
        {
            self.imageManager?.requestImageForAsset(imageAsset!, targetSize: CGSize(width: 80, height: 80), contentMode: .AspectFill, options: nil)
            { image, info in
                self.photoImageView.image = image
            }
        }
    }

    // MARK: - INTERFACE BUILDER OUTLETS & ACTIONS
    @IBOutlet weak var photoImageView: UIImageView!
}