//
//  ZKBaseModel.swift
//  ZKBaseModel
//
//  Created by zhikai.li on 2017/3/14.
//  Copyright © 2017年 zhikai.li. All rights reserved.
//

import UIKit

/// 字典转模型(值类型只支持对象类型的转换)
public class ZKBaseModel: NSObject {
    
    required override public init(){
        super.init()
    }

    // MARK: - 外部调用初始化方法
    /// 字典转模型
    ///
    /// - Parameter dic: 字典
    /// - Returns: 模型
    static public func dicToModel ( dic : Dictionary<String, AnyObject> )-> ZKBaseModel {
        
        let model : ZKBaseModel = self.init()
        model.dicForModel(dic: dic)
        return model
    }

    
    /// 数组转模型
    ///
    /// - Parameter array: 数组
    /// - Returns: 模型数组
    static public func arrayToModel ( array : Array<Dictionary<String, AnyObject>>) -> Array<ZKBaseModel> {
        
        var arrayModel : Array<ZKBaseModel> = Array<ZKBaseModel>()
        for dic in array {
            arrayModel.append(dicToModel(dic: dic))
        }
        return arrayModel
        
    }
    
    /// 字典转模型（不建议外部调用）
    ///
    /// - Parameter dic: 字典
    private func dicForModel( dic : Dictionary<String, AnyObject>) {
        
        getAllProperties(any_class: self.classForCoder, dic: dic)
        
    }
    
    
    //MARK: - 数据转模型处理
    /// 获取所有的属性（包含继承关系的）
    ///
    /// - Parameters:
    ///   - any_class: 类
    ///   - dic: 字典
    private func getAllProperties( any_class : AnyClass, dic : Dictionary<String, AnyObject> ){
        
         properties(dic: dic, any_class: any_class)
        
        if let super_class = class_getSuperclass(any_class) {
            
            if FoundationClass.isFoundationClass(any_class: super_class) {
                return
            }
            
            getAllProperties(any_class: super_class, dic: dic)
            
        }

    }
    
    
    /// 获取属性处理
    ///
    /// - Parameters:
    ///   - dic: 字典
    ///   - any_class: 类
    private func properties( dic : Dictionary<String, AnyObject>,  any_class : AnyClass) {
        
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        
        let buff = class_copyPropertyList( any_class, count)
        
        let countInt = Int(count[0])
        
        if countInt == 0 {return}
        
        for i in 0...countInt - 1 {
            
            let temp = buff?[i]
            
            guard
            let propertyName = property_getName(temp),
            let propertyAttributes = property_getAttributes(temp)
            else {
                continue
            }
            
            if let propertyNameStr = String.init(utf8String: propertyName),
               let propertyAttributesStr = String.init(utf8String: propertyAttributes) {
                
                // 如: T@"NSNumber",N,&,Vage
                let propertyAttributesArr = propertyAttributesStr.components(separatedBy: ",")
                
                var class_name = propertyAttributesArr[0]
                
                class_name = class_name.replacingOccurrences(of: "T@\"", with: "")
                // 去除之后: NSNumber
                class_name = class_name.replacingOccurrences(of: "\"", with: "")
                
                dataForModelHandle(dic: dic, class_name: class_name, propertyNameStr: propertyNameStr)
                
                print("\(propertyNameStr):::::::\(propertyAttributesStr)")
            }
            
        }
        
        
    }
    
    
    /// 数据转模型处理
    ///
    /// - Parameters:
    ///   - dic: 字典
    ///   - class_name: 类
    ///   - propertyNameStr: 属性名
    private func dataForModelHandle ( dic : Dictionary<String, AnyObject>, class_name : String, propertyNameStr : String) {
        
        // 字典中包含类中属性才处理 否则直接返回
        if dic.keys.contains(propertyNameStr) {
            
            let value = dic[propertyNameStr]
            
            if let any_class =  NSClassFromString(class_name) {
                
                let isFoundationClass : Bool = FoundationClass.isFoundationClass(any_class: any_class)
                //如果是系统框架中的类处理方式
                if isFoundationClass {
                    // 如果是数组的话需要特殊处理
                    if NSStringFromClass(NSArray.self) == class_name {
                        
                        // 反射机制
                        let properties = Mirror(reflecting: self)
                        
                        properties.children.forEach({ ( pro ) in
                            
                            if let propertyName = pro.label {
                                
                                if propertyName == propertyNameStr {
                                    
                                    let model_type = Mirror(reflecting: pro.value).subjectType
                                    
                                    var ch_class_name = String(describing: model_type)
                                    
                                    ch_class_name = getClassName(name: ch_class_name as NSString) as String
                                    
                                    if let base_class : AnyClass = NSClassFromString(ch_class_name){
                                        
                                        if let base_type : ZKBaseModel.Type = base_class as? ZKBaseModel.Type {
                                            
                                            self.setValue(base_type.arrayToModel(array: value as! Array<Dictionary<String, AnyObject>>), forKey: propertyNameStr)
                                            
                                        }
                                        
                                    }else{
                                        self.setValue(value, forKey: propertyNameStr)
                                    }

                                }
                                
                            }
                            
                        })
                            
        
                    }else{
                        // 字典转模型处理
                        self.setValue(value, forKey: propertyNameStr)
                    }
                    
                }else{
                    //如果不是系统框架中的类处理方式
                    
                    let model_type : ZKBaseModel.Type = any_class as! ZKBaseModel.Type
                    
                    let model : ZKBaseModel = model_type.dicToModel(dic: value as! Dictionary<String, AnyObject>)
                    
                    self.setValue(model, forKey: propertyNameStr)
                    
                    
                }
                
            }

            
        }
    }
    
    
    /// 从一串Optional<*******>找到类名字符串
    ///
    /// - Parameter name: 字符串
    /// - Returns: 类名
    private func getClassName(name:NSString)->String!{
        
        var range = name.range(of: "<.*>", options: NSString.CompareOptions.regularExpression)
        if range.location != NSNotFound{
            range.location += 1
            range.length -= 2
            return getClassName(name: name.substring(with: range) as NSString)
        }
        else{
            return swiftClassNameFromString(className: name as String)
        }
    }
    
}



extension NSObject {
    
    /// 类名加上项目名称
    ///
    /// - Parameter className: 类名
    /// - Returns: 项目名称.类名
    func swiftClassNameFromString(className: String) -> String! {
        
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            
            return "\(appName).\(className)"
            
        }
        return nil;
    }
}




