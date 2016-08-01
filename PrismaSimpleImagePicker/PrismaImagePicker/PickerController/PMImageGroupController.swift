//
//  PMImageGroupController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/25.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit
import Photos

class PMImageGroupController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    let topLine: CALayer = CALayer.init()
    var groups: [PMGroupModel] = [PMGroupModel]()
    var photoGroups: [PHAssetCollection]? = [PHAssetCollection]()
    var didSelectGroupAction: ((Int)-> Void)?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init() {
        var nibNameOrNil = String?("PMImageGroupController")
        if NSBundle.mainBundle().pathForResource(nibNameOrNil, ofType: "xib") == nil {
            nibNameOrNil = nil
        }
        self.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        automaticallyAdjustsScrollViewInsets = false

        tableView.registerNib(UINib.init(nibName: "PMImageGroupCell", bundle: nil), forCellReuseIdentifier: "kGroupCellIdfy")
        
        // Top line
        let mainScreen: UIScreen = UIScreen.mainScreen()
        let frame = CGRectMake(0, -1/mainScreen.scale, mainScreen.bounds.size.width, 1/mainScreen.scale)
        topLine.frame = frame
        topLine.backgroundColor = UIColor.whiteColor().CGColor
        topLine.shadowOffset = CGSizeMake(0, frame.size.height)
        topLine.shadowRadius = 1
        topLine.shadowOpacity = 1
        topLine.shadowColor = UIColor.lightGrayColor().CGColor
        
        view.layer.masksToBounds = true
        view.layer.addSublayer(topLine)
        
        // PHAssetCollection to Model
        for collection in photoGroups! {
            let groupModel = PMGroupModel.groupModelFromPHAssetCollection(collection)
            groups.append(groupModel)
        }
    }
    
    override func viewDidLayoutSubviews() {
        topLine.removeFromSuperlayer()
        view.layer.addSublayer(topLine)
    }
    
    
    // MARK: UITableView M
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.size.width/320 * 80
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("kGroupCellIdfy", forIndexPath: indexPath) as! PMImageGroupCell
        
        let groupModel = groups[indexPath.item]
        cell.configGroupCell(groupModel)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let doneAction = didSelectGroupAction {
            doneAction(indexPath.item)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
