//
//  StoryboardControllerProvider.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import Foundation
import UIKit

class StoryboardControllerProvider<T: UIViewController> {
    
    class func controller(from storyboard: UIStoryboard, identifier: String? = nil) -> T? {
        let controllerId = identifier ?? NSStringFromClass(T.classForCoder()).components(separatedBy: ".").last!
        return storyboard.instantiateViewController(withIdentifier: controllerId) as? T
    }
    
    class func controller(storyboardName: String, identifier: String? = nil) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return controller(from: storyboard, identifier: identifier)
    }
}
