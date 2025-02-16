//
//  Extensions.swift
//  ChatMeUp
//
//  Created by Sina Eradat on 2/14/25.
//

import UIKit

extension UIView {
    
    /// Add subviews to a given view
    /// - Parameter views: Child views to be added
    func addSubViews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
    
    
    ///  The width of the view
    var width: CGFloat {
        return frame.size.width
    }
    
    
    /// The height of the view
    var hight: CGFloat {
        return frame.size.height
    }
    
    
    /// The top of the view
    var top: CGFloat {
        return frame.origin.y
    }
    
    
    /// The bottom of the view
    var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }
    
    
    /// The left of the view
    var left: CGFloat {
        return frame.origin.x
    }
    
    
    /// The right of the view
    var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
    
}
