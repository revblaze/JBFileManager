//
//  EditViewController.swift
//  JBFileManager
//
//  Created by Justin Mathilde on 06/02/2017.
//  Copyright © 2017 JB. All rights reserved.
//

import UIKit

class EditViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet var lblFileName: UILabel!
    
    var filePath: String = ""
    var fileName: String = ""
    
    var fileSize : UInt64 = 0
    var fileDate : Date? = nil
    
    var txtFileName : UITextField! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        recognizer.direction = .right
        self.view.addGestureRecognizer(recognizer)
        
        lblFileName.text = fileName
        
        do {
            
            let attr    = try FileManager.default.attributesOfItem(atPath: filePath)
            
            fileSize    = attr[FileAttributeKey.size] as! UInt64
            fileDate    = attr[FileAttributeKey.modificationDate] as? Date
            
        } catch {
            
            print("Error")
        }        
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
            
            self.navigationItem.leftBarButtonItem = nil
            
        }
        
        // Do any additional setup after loading the view.
    }

    @IBAction func btnSaveClicked() {
        
        do {
            
            try FileManager.default.moveItem(atPath: self.filePath, toPath: filePath.replacingOccurrences(of: self.fileName, with: txtFileName.text!))
            
            fileName = txtFileName.text!
            filePath = filePath.replacingOccurrences(of: self.fileName, with: txtFileName.text!)
            
            lblFileName.text = fileName
            
        } catch let error as NSError {
            
            print("Ooops! Something went wrong: \(error)")
        }

    }
    
    func swipeRight(recognizer : UISwipeGestureRecognizer) {
        
        self.performSegue(withIdentifier: "backFromEdit", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell
        
        if indexPath.row == 0 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            
            let txtName:UITextField! = cell.viewWithTag(100) as! UITextField!
            txtName.text = fileName
            
            txtFileName = txtName
            
        } else if indexPath.row == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath)
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            
            let lblSize:UILabel! = cell.viewWithTag(100) as! UILabel!
            lblSize.text = formatter.string(from: fileDate!)
            
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            
            let lblModify:UILabel! = cell.viewWithTag(100) as! UILabel!
            lblModify.text = String.init(format: "%d bytes", fileSize)
        }
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
