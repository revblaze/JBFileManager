//
//  MasterViewController.swift
//  JBFileManager
//
//  Created by Justin Bush on 27/01/2017.
//  Copyright © 2017 Justin Bush. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    var lstFile:Array<String> = Array()
    var lstFileType:Array<String> = Array()
    
    var isMove:Bool = false
    var fromPath:String = ""
    var moveFileName:String = ""
    
    //let path = Bundle.main.resourcePath!
    //let path = FileManager.default.currentDirectoryPath
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var curPath:String = ""
    var dirName:String = ""
    
    var pasteButton:UIBarButtonItem? = nil
    
    @IBOutlet var lblDirName:UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.navigationItem.leftBarButtonItem = self.editButtonItem
        
//        pasteButton = UIBarButtonItem(title: "Paste", style: .done, target: self, action: #selector(pasteObject(_:)))
//        self.navigationItem.leftBarButtonItem = nil
        
        let backButton = UIButton.init(type: UIButtonType.custom)
        backButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton.setImage(UIImage.init(named: "Back"), for: UIControlState.normal)
        backButton.addTarget(self, action: #selector(btnBackClicked(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        if curPath == "" {
            
            curPath = appDelegate.rootPath
            dirName = "My Documents"
        }
        
        if appDelegate.rootPath == curPath {
            
            self.navigationItem.leftBarButtonItem = nil
        }
        
        lblDirName.text = dirName
        
        let addButton = UIButton.init(type: UIButtonType.custom)
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.setImage(UIImage.init(named: "Add"), for: UIControlState.normal)
        addButton.addTarget(self, action: #selector(btnAddClicked(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        loadFiles()
    }
    
    func loadFiles() {
        
        do {
            let filelist = try FileManager.default.contentsOfDirectory(atPath: curPath)
            
            lstFile.removeAll()
            lstFileType.removeAll()
            
            for filename in filelist {
                
                let filepath = curPath + "/" + filename
                
                let attribs:NSDictionary = try FileManager.default.attributesOfItem(atPath: filepath) as NSDictionary
                
                let type = attribs["NSFileType"] as! String
                
                lstFile.append(filename)
                lstFileType.append(type)
            }
            
            self.tableView.reloadData()
            
        } catch {
            // failed to read directory – bad permissions, perhaps?
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pasteObject(_ sender: Any) {
        
        do {
            
            let toPath = curPath + "/" + moveFileName
            
            try FileManager.default.moveItem(atPath: fromPath, toPath: toPath)
            
            fromPath        = ""
            moveFileName    = ""
            isMove          = false
            self.navigationItem.leftBarButtonItem = nil
            
            loadFiles()
            
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
    }
    
    func btnBackClicked(_ sender: Any) {
        
        let _ = self.navigationController?.popViewController(animated: true)
    }

    func btnAddClicked(_ sender: Any) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let fileAction = UIAlertAction(title: "New File", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.showAlert(isFile: true)
        })
        
        let dirAction = UIAlertAction(title: "New Directory", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.showAlert(isFile: false)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alertController.addAction(fileAction)
        alertController.addAction(dirAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(isFile:Bool){
        
        let strInput:String
        
        if isFile == true {
            strInput = "Please input file name"
        }
        else {
            strInput = "Please input directory name"
        }
        
        let alertController = UIAlertController(title: nil, message: strInput, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Create", style: .default, handler: {
            alert -> Void in
            
            let textField = alertController.textFields![0] as UITextField!
            
            if textField?.text == "" {
                
                self.showAlertMessage(strMessage: "You must type a name")
                
            } else {
                
                if(self.checkFileName(isFile: isFile, strName: (textField?.text)!)) {
                    
                    self.addFile(isFile: isFile, strName: (textField?.text)!)
                    
                } else {
                    
                    self.showAlertMessage(strMessage: "There is already a file with the same name in this location")
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField(configurationHandler: { (textField : UITextField!) -> Void in
            textField.placeholder = "Name"
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertMessage(strMessage:String){
        
        let alertController = UIAlertController(title: "Warning", message: strMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func addFile(isFile:Bool, strName:String){
        
        if isFile == true {
            
            let filePath = curPath + "/" + strName + ".txt"
            FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
            
        } else {
            
            let filePath = curPath + "/" + strName
            do {
                try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        loadFiles()
    }
    
    func checkFileName(isFile:Bool, strName:String) -> Bool {

        for i in 0..<lstFile.count{
            
            if isFile == true {
                
                let temp = strName + ".txt"
                if temp == lstFile[i]{
                    
                    if lstFileType[i] == "NSFileTypeRegular" {
                        return false
                    } else {
                        break;
                    }
                }
                
            } else {
                
                if strName == lstFile[i]{
                    
                    if lstFileType[i] == "NSFileTypeDirectory" {
                        return false
                    } else {
                        break;
                    }
                }
                
            }
        }
        
        return true
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {

                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.filePath = curPath + "/" + lstFile[indexPath.row]
            }
        }
    }
    
    @IBAction func backFromDetail(segue: UIStoryboardSegue) {
        
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "showDetail" {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
            
                if lstFileType[indexPath.row] == "NSFileTypeDirectory" {
                    
                    let controller = storyboard?.instantiateViewController(withIdentifier: "MasterViewController") as! MasterViewController
                    controller.curPath = curPath + "/" + lstFile[indexPath.row]
                    controller.dirName = lstFile[indexPath.row]
                        
                    self.navigationController?.pushViewController(controller, animated: true)
                    
                    return false
                    
                }
            }
        }
        
        return true
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lstFile.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let imgType = cell.viewWithTag(100) as! UIImageView
        
        imgType.image = UIImage.init(named: "File")
        
        if lstFileType[indexPath.row] == "NSFileTypeDirectory" {
            
            imgType.image = UIImage.init(named: "Folder")
        }
        
        let lblName = cell.viewWithTag(101) as! UILabel
        lblName.text = lstFile[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in

            let filePath = self.curPath + "/" + self.lstFile[indexPath.row]
            
            do {
                try FileManager.default.removeItem(atPath: filePath)
            
                self.lstFile.remove(at: indexPath.row)
                self.lstFileType.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
        }
        
        delete.backgroundColor = UIColor.init(red: 255/255.0, green: 45/255.0, blue: 85/255.0, alpha: 1.0)
        
        let move = UITableViewRowAction(style: .default, title: "Move") { action, index in
            
            let filePath = self.curPath + "/" + self.lstFile[indexPath.row]
            
            self.fromPath       = filePath
            self.isMove         = true
            self.moveFileName   = self.lstFile[indexPath.row]
            self.navigationItem.leftBarButtonItem = self.pasteButton
            
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        move.backgroundColor = UIColor.init(red: 52/255.0, green: 170/255.0, blue: 220/255.0, alpha: 1.0)

        return [delete, move]

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            
//             let filePath = curPath + "/" + lstFile[indexPath.row]
//            
//            do {
//                try FileManager.default.removeItem(atPath: filePath)
//                
//                lstFile.remove(at: indexPath.row)
//                lstFileType.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .fade)
//                
//            } catch let error as NSError {
//                NSLog("Unable to create directory \(error.debugDescription)")
//            }
//            
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
    }
}

