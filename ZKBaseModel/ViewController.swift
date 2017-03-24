//
//  ViewController.swift
//  ZKBaseModel
//
//  Created by zhikai.li on 2017/3/13.
//  Copyright © 2017年 zhikai.li. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let jsonArr = [
            [
                "name": "ok",
                "age":1,
                "job": [
                    "name":"ios开发"
                ],
                "skills":[
                    ["name":"swift"],
                    ["name":"objc"]
                ]
            ],
            [
                "name": "ok2",
                "age":2,
                "job": [
                    "name":"ios开发1"
                ],
                "skills":[
                    ["name":"swift1"],
                    ["name":"objc1"]
                ]
            ]
        ]
        let users = User.arrayToModel(array:jsonArr as Array<Dictionary<String, AnyObject>>) as! Array<User>
        print(users.description)

    }
}



class IOS: ZKBaseModel {
    var updatedAt = ""
    var who = ""
    var publishedAt = ""
    var objectId = ""
    var used = ""
    var type = ""
    var createdAt = ""
    var desc = ""
    var url = ""
}



class Job:ZKBaseModel{
    var name = ""
}


class User:ZKBaseModel{
    
    var say:Array<String>!
    var skills:Array<AnyObject>!
    
    var name:String!
    var age:Int = 0           //基础类型需要初始化
    var job:Job!
}


