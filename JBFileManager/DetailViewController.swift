//
//  DetailViewController.swift
//  JBFileManager
//
//  Created by Justin Mathilde on 27/01/2017.
//  Copyright © 2017 JB. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var txtDetail: UITextView!
    @IBOutlet var lblFileName: UILabel!
    
    var fileName: String = ""
    
    func configureView() {
        // Update the user interface for the detail item.
        if let path = self.filePath {
            
            if let txtView = self.txtDetail {
                
                lblFileName.text = fileName
                
                do {
                   try txtView.text = String(contentsOfFile: path, encoding: String.Encoding.utf8)
                    
                } catch let error as NSError {
                    
                    NSLog("Unable to create directory \(error.debugDescription)")
                }
            }
            
            let saveButton = UIButton.init(type: UIButtonType.custom)
            saveButton.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
            saveButton.setTitle("Save", for: UIControlState.normal)
            saveButton.addTarget(self, action: #selector(btnSaveClicked(_:)), for: UIControlEvents.touchUpInside)
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                
                self.navigationItem.leftBarButtonItem = nil
            }
        }
    }
    
    func btnSaveClicked(_ sender: Any) {
        
        let content = txtDetail.text
        
        do {
            
            try content?.write(toFile: self.filePath!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {/* error handling here */}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let recognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        recognizer.direction = .right
        self.view.addGestureRecognizer(recognizer)
        
        
        lblFileName.text = ""
        
        self.navigationItem.rightBarButtonItem  = nil
        self.navigationItem.leftBarButtonItem   = nil
        
        self.configureView()
    }
    
    func swipeRight(recognizer : UISwipeGestureRecognizer) {
        
        self.performSegue(withIdentifier: "backFromDetail", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var filePath: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
}

