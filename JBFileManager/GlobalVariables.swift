//
//  GlobalVariables.swift
//  JBFileManager
//
//  Created by Justin Mathilde on 02/02/2017.
//  Copyright © 2017 JB. All rights reserved.
//

class GlobalVariables {

    var rootPath: String = ""
    var moveFileName: String = ""
    var moveFromPath: String = ""
    
    class var sharedManager : GlobalVariables {
        
        struct Static {
            
            static let instance = GlobalVariables()
        }
        
        return Static.instance
    }
}
