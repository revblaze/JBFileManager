//
//  MasterViewController.swift
//  JBFileManager
//
//  Created by Justin Mathilde on 27/01/2017.
//  Copyright © 2017 JB. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()

    var lstFile:Array<String> = Array()
    var lstFileType:Array<String> = Array()
    
    //let path = Bundle.main.resourcePath!
    //let path = FileManager.default.currentDirectoryPath
    
    var curPath:String = ""
    var dirName:String = ""
    
    var backButton:UIButton? = nil
    var vwPaste:UIView? = nil
    
    @IBOutlet var lblDirName:UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        vwPaste = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 30))
        
        let cancelButton = UIButton.init(type: UIButtonType.custom)
        cancelButton.frame = CGRect(x: 0, y: 0, width: self.view.frame.width/2.0, height: 30)
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.addTarget(self, action: #selector(btnCancelClicked(_:)), for: UIControlEvents.touchUpInside)
        cancelButton.backgroundColor = UIColor.init(red: 249/255.0, green: 56/255.0, blue: 65/255.0, alpha: 1.0)
        
        let pasteButton = UIButton.init(type: UIButtonType.custom)
        pasteButton.frame = CGRect(x: self.view.frame.width/2.0, y: 0, width: self.view.frame.width/2.0, height: 30)
        pasteButton.setTitle("Paste", for: UIControlState.normal)
        pasteButton.addTarget(self, action: #selector(btnPasteClicked(_:)), for: UIControlEvents.touchUpInside)
        pasteButton.backgroundColor = UIColor.init(red: 76/255.0, green: 217/255.0, blue: 100/255.0, alpha: 1.0)
        
        vwPaste?.addSubview(cancelButton)
        vwPaste?.addSubview(pasteButton)

        backButton = UIButton.init(type: UIButtonType.custom)
        backButton?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backButton?.setImage(UIImage.init(named: "back"), for: UIControlState.normal)
        backButton?.addTarget(self, action: #selector(btnBackClicked(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton!)
        
        let addButton = UIButton.init(type: UIButtonType.custom)
        addButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        addButton.setImage(UIImage.init(named: "add"), for: UIControlState.normal)
        addButton.addTarget(self, action: #selector(btnAddClicked(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
        
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let recognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRight))
        recognizer.direction = .right
        self.view.addGestureRecognizer(recognizer)
        
        //loadData()
    }
    
    func swipeRight(recognizer : UISwipeGestureRecognizer) {
        
        if self.navigationItem.leftBarButtonItem != nil {
            
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func loadData() {
        
        if GlobalVariables.sharedManager.moveFileName == "" {
            
            self.tableView.tableHeaderView = nil
            
        } else {
            
            self.tableView.tableHeaderView = vwPaste
        }
        
        if curPath == "" {
            
            curPath = GlobalVariables.sharedManager.rootPath
            dirName = "My Documents"
        }
        
        if GlobalVariables.sharedManager.rootPath == curPath {
            
            self.navigationItem.leftBarButtonItem = nil
            
        } else {
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: self.backButton!)
        }
        
        
        lblDirName.text = dirName
        
        loadFiles()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //loadData()
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
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func btnCancelClicked(_ sender: Any) {
    
        GlobalVariables.sharedManager.moveFromPath    = ""
        GlobalVariables.sharedManager.moveFileName    = ""
        
        self.tableView.tableHeaderView = nil;
    }
    
    func btnPasteClicked(_ sender: Any) {
        
        do {
            
            let moveToPath = curPath + "/" + GlobalVariables.sharedManager.moveFileName
            
            try FileManager.default.moveItem(atPath: GlobalVariables.sharedManager.moveFromPath, toPath: moveToPath)
            
            GlobalVariables.sharedManager.moveFromPath    = ""
            GlobalVariables.sharedManager.moveFileName    = ""
            
            self.tableView.tableHeaderView = nil;
            
            loadFiles()
            
        } catch let error as NSError {
            
            NSLog("Unable to create directory \(error.localizedFailureReason)")
            
            GlobalVariables.sharedManager.moveFromPath    = ""
            GlobalVariables.sharedManager.moveFileName    = ""
            
            self.tableView.tableHeaderView = nil;
            
            showAlertMessage(strMessage: error.localizedFailureReason!)
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
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
        
            let popover = alertController.popoverPresentationController
            popover?.sourceView = view
            popover?.sourceRect = CGRect(x: 32, y: 32, width: 64, height: 64)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showAlert(isFile:Bool){
        
        let alertController = JLAlertViewController.inputAlertController("Please input file name", placeholder: "Name", cancelButtonText: "Cancel", regularButtonText: "Create")
        
        alertController.didDismissBlock = { alertViewController, buttonTapped in
            
            if buttonTapped.rawValue == 1 {
                
                if(self.checkFileName(isFile: isFile, strName: (alertController.getInputText())!)) {
                    
                    self.addFile(isFile: isFile, strName: (alertController.getInputText())!)
                    
                } else {
                    
                    self.showAlertMessage(strMessage: "There is already a file with the same name in this location")
                }
            }
        }
        
        alertController.show()
    }
    
    func showAlertMessage(strMessage:String){
        
        let alertController = JLAlertViewController.alertController("Warning", message: strMessage, cancelButtonText: nil, regularButtonText: "Ok")

        
        alertController.didDismissBlock = { alertViewController, buttonTapped in
            
            print("TAPPED: \(buttonTapped.rawValue)")
            
        }
        
        alertController.show()
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

                let controller = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
//                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.filePath = curPath + "/" + lstFile[indexPath.row]
                controller.fileName = lstFile[indexPath.row]
                
                let navController = segue.destination as! UINavigationController
                //navController.topViewController = controller
                navController.setViewControllers([controller], animated: false)
            }
            
        } else if segue.identifier == "showEdit" {
            
            let controller = storyboard?.instantiateViewController(withIdentifier: "EditViewController") as! EditViewController
            
            let nSelectedIndex = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            
            controller.filePath = curPath + "/" + lstFile[nSelectedIndex!]
            controller.fileName = lstFile[nSelectedIndex!]
            
            let navController = segue.destination as! UINavigationController
            //navController.topViewController = controller
            navController.setViewControllers([controller], animated: false)
        }
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
        
        imgType.image = UIImage.init(named: "file")
        
        if lstFileType[indexPath.row] == "NSFileTypeDirectory" {
            
            imgType.image = UIImage.init(named: "folder")
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
            
            GlobalVariables.sharedManager.moveFromPath   = filePath
            GlobalVariables.sharedManager.moveFileName   = self.lstFile[indexPath.row]
            
            self.tableView.tableHeaderView = self.vwPaste
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        
        move.backgroundColor = UIColor.init(red: 52/255.0, green: 170/255.0, blue: 220/255.0, alpha: 1.0)

        return [delete, move]

    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        
    }

    @IBAction func backFromDetail(segue: UIStoryboardSegue) {
        
        
    }
    
    @IBAction func backFromEdit(segue: UIStoryboardSegue) {
        
        
    }
    
    @IBAction func backFromEmpty(segue: UIStoryboardSegue) {
        
        print("123")
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

