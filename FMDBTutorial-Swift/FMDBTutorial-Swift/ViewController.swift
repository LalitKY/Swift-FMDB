//
//  ViewController.swift
//  FMDBTutorial-Swift
//
//  Created by Lalit Kant on 2/7/17.
//  Copyright © 2017 Lalit Kant. All rights reserved.
//

import UIKit

class ViewController: UIViewController  ,UITableViewDelegate ,UITableViewDataSource, UITextFieldDelegate
{
    let db =  FMDBManager.sharedInstance

    @IBOutlet var mainTable: UITableView!
    var dataArray : NSMutableArray = []
    var tField: UITextField!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "FMDBTutorial-Swift"
        
        self.navigationController?.isNavigationBarHidden = false
        let rightButton = UIBarButtonItem(image: UIImage(named: "plus"), style: .plain, target: self, action: #selector(ViewController.add))
        rightButton.tintColor = UIColor.darkGray
        self.navigationItem.leftBarButtonItem  = nil
        self.navigationItem.rightBarButtonItem  = rightButton
        
        self.mainTable.rowHeight = UITableViewAutomaticDimension;
        self.mainTable.estimatedRowHeight = 1000;
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData()
        
        self.navigationController?.navigationBar.isHidden = false
        super.viewWillAppear(true)
    }
    func configurationTextField(textField: UITextField!)
    {
        print("generating the TextField")
        textField.delegate = self
        textField.placeholder = "Enter album name"
        tField = textField
    }
    
    func add()  {
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Please enter title", message: "", preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Save", style: .cancel) { action -> Void in
            print("Save")
            if self.tField.text == ""
            {
                
                return
            }
            self.db.TimeWithTitleSave(title : self.tField.text! )
            self.loadData()
            self.mainTable.reloadData()
            self.dismiss(animated: false, completion: nil)
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Cancel" , style: .default)
        { action -> Void in
            print("Cancel")
            self.dismiss(animated: false, completion: nil)

        }
        actionSheetController.addAction(saveActionButton)
        actionSheetController.addTextField { (textField) -> Void in
            self.tField = textField
            self.tField?.delegate = self //REQUIRED
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    func update(titleId: Int)  {
        //Create the AlertController and add Its action like button in Actionsheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Please enter title to update", message: "", preferredStyle: .alert)
        
        let cancelActionButton: UIAlertAction = UIAlertAction(title: "Update", style: .cancel) { action -> Void in
            print("Save")
            if self.tField.text == ""
            {
                
                return
            }
            self.db.updateTitle(title: self.tField.text!, titleid: titleId)
            self.loadData()
            self.mainTable.reloadData()
            self.dismiss(animated: false, completion: nil)
        }
        actionSheetController.addAction(cancelActionButton)
        
        let saveActionButton: UIAlertAction = UIAlertAction(title: "Cancel" , style: .default)
        { action -> Void in
            print("Cancel")
            self.dismiss(animated: false, completion: nil)

        }
        actionSheetController.addAction(saveActionButton)
        actionSheetController.addTextField { (textField) -> Void in
            self.tField = textField
            self.tField?.delegate = self //REQUIRED
        }
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    
    func loadData()  {
        self.dataArray = db.getTimeWithTitleData()

        self.mainTable.reloadData()
    }
    
    func action()
    {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell   = tableView.dequeueReusableCell(withIdentifier: "ListTableCell", for: indexPath) as! ListTableViewCell
        let tempAlbum = self.dataArray.object(at: indexPath.row) as! ListObject
        cell.selectionStyle = .none
        cell.titleLabel.text = tempAlbum.title
        cell.dateLabel.text = tempAlbum.dateStr
        cell.timeLabel.text = tempAlbum.timeStr
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Want to update cell?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { action in
            // perhaps use action.title here
            self.dismiss(animated: false, completion: nil)

            let tempAlbum = self.dataArray.object(at: indexPath.row) as! ListObject
            self.update(titleId: tempAlbum.primaryId!)
            
        })
        alert.addAction(UIAlertAction(title: "Not now!", style: .default) { action in
            // perhaps use action.title here
        })
        self.present(alert, animated: true, completion: nil)

    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alert = UIAlertController(title: "Want to delete cell?", message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Delete", style: .default) { action in
                // perhaps use action.title here
                  let tempAlbum = self.dataArray.object(at: indexPath.row) as! ListObject
                self.db.deleteTimeWithTitle(titleid: tempAlbum.primaryId!)
                self.loadData()
            })
            alert.addAction(UIAlertAction(title: "Not now!", style: .default) { action in
                // perhaps use action.title here
            })
            self.present(alert, animated: true, completion: nil)

            // handle delete (by removing the data from your array and updating the tableview)
        }
   }
        
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let maxLength = 250
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
        
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

