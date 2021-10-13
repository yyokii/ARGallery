//
//  UIKit+Rotate.swift
//  
//
//  Created by Higashihara Yoki on 2021/10/13.
//

import UIKit

extension UIImage {
    
    /// Re-orientate the image to `.up`.
    public func reorientToUp() -> UIImage? {
        if self.imageOrientation == .up {
            return self
        } else {
            defer { UIGraphicsEndImageContext() }
            UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
            
            self.draw(in: CGRect(origin: .zero, size: self.size))
            return UIGraphicsGetImageFromCurrentImageContext()
        }
    }
}
