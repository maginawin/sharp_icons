//
//  ListObject.swift
//  SharpIcons
//
//  Created by 王文东 on 2017/12/18.
//  Copyright © 2017年 maginawin. All rights reserved.
//

import Cocoa

enum ListModelType: Int {
    case iOS = 0
    case android = 1
    case macOS = 2
}

struct ListModel: Equatable {
    static func ==(lhs: ListModel, rhs: ListModel) -> Bool {
        return lhs.size == rhs.size && lhs.type == rhs.type
    }
    
    var size: CGFloat = 1024
    var type: ListModelType = .iOS
}

class ListObject: NSObject {
    private let LIST_MODELS_KEY = "listModels"
    
    fileprivate static let instance: ListObject = ListObject()
    
    class var `default`: ListObject {
        return instance
    }
    
    override fileprivate init() {
        
    }
    
    
    func listModels() -> [ListModel] {
        return [
            ListModel(size: 20, type: .iOS),
            ListModel(size: 29, type: .iOS),
            ListModel(size: 40, type: .iOS),
            ListModel(size: 60, type: .iOS),
            ListModel(size: 76, type: .iOS),
            ListModel(size: 83.5, type: .iOS),
            ListModel(size: 30, type: .android),
            ListModel(size: 48, type: .android),
            ListModel(size: 72, type: .android),
            ListModel(size: 96, type: .android),
            ListModel(size: 144, type: .android),
            ListModel(size: 192, type: .android),
            ListModel(size: 512, type: .android),
            ListModel(size: 16, type: .macOS),
            ListModel(size: 32, type: .macOS),
            ListModel(size: 128, type: .macOS),
            ListModel(size: 256, type: .macOS),
            ListModel(size: 512, type: .macOS)
        ]
        
//        guard let arr = UserDefaults.standard.array(forKey: LIST_MODELS_KEY) else {
//            return []
//        }
//
//        return arr as! [ListModel]
    }
    
    func androidModels() -> [ListModel] {
        guard let arr = UserDefaults.standard.array(forKey: LIST_MODELS_KEY) else {
            return []
        }
        
        var models = [ListModel]()
        
        for (_, value) in arr.enumerated() {
            let v = value as! ListModel
            if v.type == .android {
                models.append(v)
            }
        }
        
        return models
    }
    
    func iOSModels() -> [ListModel] {
        guard let arr = UserDefaults.standard.array(forKey: LIST_MODELS_KEY) else {
            return []
        }
        
        var models = [ListModel]()
        
        for (_, value) in arr.enumerated() {
            let v = value as! ListModel
            if v.type == .iOS {
                models.append(v)
            }
        }
        
        return models
    }
    
    func add(model: ListModel) {
        guard var arr = UserDefaults.standard.array(forKey: LIST_MODELS_KEY) else {
            return
        }
        
        arr.append(model)
        
        UserDefaults.standard.set(arr, forKey: LIST_MODELS_KEY)
        UserDefaults.standard.synchronize()
    }
    
    func remove(model: ListModel) {
        guard var arr = UserDefaults.standard.array(forKey: LIST_MODELS_KEY) else {
            return
        }
        
        for (index, value) in arr.enumerated() {
            if model == value as! ListModel {
                arr.remove(at: index)
            }
        }
        
        UserDefaults.standard.set(arr, forKey: LIST_MODELS_KEY)
        UserDefaults.standard.synchronize()
    }
}
