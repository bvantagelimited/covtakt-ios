//
//  NotificationsViewController.swift
//  ezyHelpers
//
//  Created by Do Tri on 6/27/16.
//  Copyright © 2016 Do Tri. All rights reserved.
//

import UIKit


class NotificationsController: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var notifList : [Notif] = []
    var formatter = DateFormatter()
    var pageIndex = 1
    var language = ""
    var totalPageNotifs = 0
    var isDidSelect = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false
        
        let backBtn = UIButton(type: UIButton.ButtonType.custom)
        backBtn.setImage(UIImage(named: "arrow_left"), for: UIControl.State())
        backBtn.addTarget(self, action: #selector(self.back), for: UIControl.Event.touchUpInside)
        backBtn.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        let backBarButtonItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        
        noDataLbl.text = "You don't have any notifications at the moment.".localized()
        
        self.navigationItem.title = "Notifications".localized()
        self.title = "Notifications".localized()
        formatter.dateFormat = "HH:mm - MMM dd, yyyy"
        formatter.locale = Locale(identifier: "en")
        tbView.separatorColor = UIColor(hexString: "e2e2e2")
        tbView.tableFooterView = UIView()  // it's just 1 line, awesome!

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData), name: NSNotification.Name.BecomeActive, object: nil)
        tbView.estimatedRowHeight = 68.0
        tbView.rowHeight = UITableView.automaticDimension
        
//        Analytics.logEvent("OpenNotifications", parameters: nil)
    }
    @objc func reloadData() {
       notifList = []
                 pageIndex = 1
                 totalPageNotifs = 0
                loadData(pageIndex)
    }
    @objc func back() {
        self.navigationController!.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notifList = []
        pageIndex = 1
        totalPageNotifs = 0
        loadData(pageIndex)
    }
    
    func loadData(_ page: Int, limit: Int = 100) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        var data  = Alert.readLocalNotification()
        if(data  != nil && data!.count > 0){
            for item in data!{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let date = dateFormatter.date(from: item["created_at"]!)!

                notifList.insert(Notif(date: date, message: item["message"]!), at: 0)
            }
            
        }
        print(self.notifList.count)
                self.tbView.reloadData()
                 self.tbView.isHidden = self.notifList.count == 0
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            }
//
//            SVProgressHUD.dismiss()
//
//        }) { (e) in
//            self.tbView.pullToRefreshView.stopAnimating()
//            self.tbView.infiniteScrollingView.stopAnimating()
//            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "OpenNotificationDetail" {
//            let destVC = segue.destination as! NotificationDetailViewController
//            destVC.notifObj = sender as? NotificationObj
//        }
    }

}

extension NotificationsController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return notifList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tbView.dequeueReusableCell(withIdentifier: "Cell") as! NotificationCell
        
        if indexPath.row >= notifList.count {
            return cell
        }
        let notif = notifList[indexPath.row]
//        cell.headLabel.text = "notif.header"
        cell.shortLabel.text = notif.message
        cell.time.text = notif.date.timeAgoSinceNow
        
//
//
//        if notif.isSeen {
//            cell.contentView.backgroundColor = UIColor(hexString: "#ffffff")
//        }
//        else {
//            cell.contentView.backgroundColor = UIColor(hexString: "#f6f6f6")
//        }
//
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notif = notifList[indexPath.row]
//
//        NotificationManager.sharedInstance.getNotificationInfo(notif.notifId, success: { (result) in
//                print(result)
//            }) { (e) in
//
//        }
        
//        if notif.notifType == "promo" {
//            Analytics.logEvent("OpenNotifications_Promo", parameters: nil)
//        }
//        else {
//            Analytics.logEvent("OpenNotifications_Comments", parameters: nil)
//        }
//
//        self.performSegue(withIdentifier: "OpenNotificationDetail", sender: notif)
        
    }
}
