//
//  DetailViewController.swift
//  JBFileManager
//
//  Created by Justin Bush on 27/01/2017.
//  Copyright © 2017 Justin Bush. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var txtDetail: UITextView!
    @IBOutlet var lblFileName: UILabel!

    func configureView() {
        // Update the user interface for the detail item.
        if let path = self.filePath {
            
            if let txtView = self.txtDetail {
                
                lblFileName.text = "Detail"
                
                do {
                   try txtView.text = String(contentsOfFile: path, encoding: String.Encoding.utf8)
                    
                } catch let error as NSError {
                    
                    NSLog("Unable to create directory \(error.debugDescription)")
                }
            }
        }
    }
    
    @IBAction func btnSaveClicked() {
        
        let content = txtDetail.text
        
        do {
            
            try content?.write(toFile: self.filePath!, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {/* error handling here */}
    }

    @IBAction func btnBackClicked() {
        
       let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
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

