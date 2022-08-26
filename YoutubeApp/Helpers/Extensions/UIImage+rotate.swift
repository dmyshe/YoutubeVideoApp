//
//  UIImage+rotate.swift
//  YoutubeApp
//
//  Created by Дмитро  on 24.08.2022.
//

import UIKit

extension UIImage {

   func rotateImage(orientation: UIImage.Orientation) -> UIImage {
      guard let cgImage = self.cgImage else { return UIImage() }
      switch orientation {
           case .right:
          return UIImage(cgImage: cgImage, scale: 2.0, orientation: .up)
           case .down:
               return UIImage(cgImage: cgImage, scale: 2.0, orientation: .right)
           case .left:
               return UIImage(cgImage: cgImage, scale: 2.0, orientation: .down)
           default:
               return UIImage(cgImage: cgImage, scale: 2.0, orientation: .left)
       }
   }
}
