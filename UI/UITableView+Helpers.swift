//
//  UITableView+Helpers.swift
//  iTunesDemoApp
//
//  Created by Pavel Laputsky on 12/2/18.
//  Copyright © 2018 PavalLaputskyPersonal. All rights reserved.
//

import UIKit

extension UITableView {
    
    func instantiateCell<T: UITableViewCell>(at indexPath: IndexPath? = nil, _: T.Type) -> T? {
        let nameSpaceClassName = NSStringFromClass(T.classForCoder())
        let cellIdentifier = nameSpaceClassName.components(separatedBy: ".").last!
        
        guard let indexPath = indexPath else {
            return self.dequeueReusableCell(withIdentifier: cellIdentifier) as? T
        }
        
        return self.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? T
    }
    
    func instantiateSupplementaryView<T: UITableViewHeaderFooterView>(with type: T.Type) -> T? {
        let nameSpaceClassName = NSStringFromClass(T.classForCoder())
        let cellIdentifier = nameSpaceClassName.components(separatedBy: ".").last!
        return self.dequeueReusableHeaderFooterView(withIdentifier: cellIdentifier) as? T
    }
    
    func registerXib(with nibDefaultName: String = "", for cellClass: AnyClass) {
        var nibName = nibDefaultName
        if nibName.isEmpty {
            let nameSpaceClassName = NSStringFromClass(cellClass)
            nibName = nameSpaceClassName.components(separatedBy: ".").last!
        }
        
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forCellReuseIdentifier: nibName)
    }
    
    func registerSupplementaryXib(with nibDefaultName: String = "", for viewClass: AnyClass) {
        var nibName = nibDefaultName
        if nibName.isEmpty {
            let nameSpaceClassName = NSStringFromClass(viewClass)
            nibName = nameSpaceClassName.components(separatedBy: ".").last!
        }
        
        let nib = UINib(nibName: nibName, bundle: Bundle.main)
        register(nib, forHeaderFooterViewReuseIdentifier: nibName)
    }
    
}
