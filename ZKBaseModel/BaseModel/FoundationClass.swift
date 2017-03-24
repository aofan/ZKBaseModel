//
//  FoundationClass.swift
//  ZKBaseModel
//
//  Created by zhikai.li on 2017/3/21.
//  Copyright © 2017年 zhikai.li. All rights reserved.
//

import UIKit

/// 系统类判断
class FoundationClass {
    
    /// 系统类集合
    static let class_Set = NSSet(array: [NSURL.classForCoder(),
                                   NSDate.classForCoder(),
                                   NSValue.classForCoder(),
                                   NSDecimalNumber.classForCoder(),
                                   NSNumber.classForCoder(),
                                   NSData.classForCoder(),
                                   NSMutableData.classForCoder(),
                                   NSError.classForCoder(),
                                   NSArray.classForCoder(),
                                   NSMutableArray.classForCoder(),
                                   NSDictionary.classForCoder(),
                                   NSMutableDictionary.classForCoder(),
                                   NSString.classForCoder(),
                                   NSMutableString.classForCoder(),
                                   NSAttributedString.classForCoder(),
                                   NSSet.classForCoder(),
                                   NSMutableSet.classForCoder(),
                                   ])
    
    
    /// 是否是框架中的类
    ///
    /// - Parameter any_class: 类
    /// - Returns: 是、否
    static func isFoundationClass( any_class : AnyClass ) -> Bool {
        
        if any_class == NSObject.classForCoder() {
            return true
        }
        
        var result : Bool = false
        
        FoundationClass.class_Set.enumerateObjects({ (foundationClass, stop) in
            
            if any_class.isSubclass(of: foundationClass as! AnyClass) {
                
                result = true
                
                stop.initialize(to: true)
            }
            

        })
        
        return result
        
    }

}
