//
//  ListTableViewCell.swift
//  FMDBTutorial-Swift
//
//  Created by Lalit Kant on 2/7/17.
//  Copyright © 2017 Lalit Kant. All rights reserved.
//

import UIKit

enum MyError: Error {
    case FoundNil(String)
}

@objc class FMDBManager: NSObject {
    var  dbQueue: FMDatabaseQueue!
    var db : FMDatabase!
    //MARK: Shared Instance
    
    static let sharedInstance = FMDBManager()
 
    let DATABASE_FILE_NAME = "FMDBTutorial.sqlite"
    
    // MARK: - FMDB
    
    
    @objc func createDatabaseIfNeeded()
    {
        // Start of Database copy from Bundle to App Document Directory
        let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let destinationSqliteURL = documentsPath.appendingPathComponent(DATABASE_FILE_NAME)
        
        db = FMDatabase(path: destinationSqliteURL?.path)
        
        // Let's open the database
        if !(db?.open())! {
            print("Unable to open database")
            return
        }
        // Let's run some SQL from the FMDB documents to make sure
        if !(db?.executeUpdate("create table TimeWithTitle (titleid integer primary key,  title text, titledate text, titletime text)", withArgumentsIn: nil))! {
            print("create table failed: \(db?.lastErrorMessage())")
        }
        
        
        db?.close()
        
        self.dbQueue = FMDatabaseQueue.init(path: destinationSqliteURL?.path as String!)
    }
    
   
    
    
    // MARK: - Time With Title Table Logic methods starts
    
    @objc func TimeWithTitleSave(title : String )
    {
        var lastRow : Int = 0
        
        self.dbQueue.inDatabase { (db) in
            
            let date = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            let dateString = dateFormatter.string(from: date as Date)
            dateFormatter.dateFormat = "hh:mm a"
            let timeString = dateFormatter.string(from: date as Date)

            if !(db?.executeUpdate("insert into TimeWithTitle (title, titledate, titletime) values (?, ?, ?)", withArgumentsIn: [title, dateString, timeString] ))! {
                    print("save failed: \(db?.lastErrorMessage())")
                }
            let rs =  db?.executeQuery("select titleid FROM TimeWithTitle", withArgumentsIn: nil)
            lastRow = (Int)((rs?.int(forColumn: "titleid"))!)
            print(lastRow)
        }
    }
    
    @objc func updateTitle(title :String, titleid : Int)
    {
        self.dbQueue.inDatabase { (db) in
            if !(db?.executeUpdate("update TimeWithTitle set title=? where titleid=?", withArgumentsIn: [title,titleid] ))! {
                print("deleteTempAlbum failed: \(db?.lastErrorMessage())")
            }
        }
    }
    
    @objc func deleteTimeWithTitle(titleid :Int )
    {
        self.dbQueue.inDatabase { (db) in
            
            let delStr = String.init(format: "delete from TimeWithTitle where titleid=%i", titleid)
            
            if !(db?.executeStatements(delStr))!
            {
                print("delete failed: \(db?.lastErrorMessage())")
            }
        }
    }
    @objc func getTimeWithTitleData() -> NSMutableArray
    {
        let arrayVal = NSMutableArray.init()
        self.dbQueue.inDatabase { (db) in
            
            let rs =  db?.executeQuery("select * from TimeWithTitle", withArgumentsIn: nil)
            
            while (rs?.next())! {
                
                let listObj = ListObject()
                listObj.title = (rs?.string(forColumn: "title"))
                listObj.dateStr = (rs?.string(forColumn: "titledate"))
                listObj.timeStr = (rs?.string(forColumn: "titletime"))
                listObj.primaryId = (Int)((rs?.int(forColumn: "titleid"))!)
                
                arrayVal.add(listObj)
            }
        }
        return arrayVal
    }
    
    
    
}


