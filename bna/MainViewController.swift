//
//  MainViewController.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import Padlock

class MainViewController: UITableViewController {
    let SegueDetail = "authenticator_detail"
    let SegueRestore = "authenticator_restore"

    @lazy var authenticators: AuthenticatorStorage = {
        return AuthenticatorStorage.sharedStorage()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func addButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Region", message: nil, preferredStyle: .ActionSheet)
        for region in Region.allValues {
            alert.addAction(UIAlertAction(title: region.toRaw(), style: .Default) {
                [weak self] _ in
                MMProgressHUD.show()
                Authenticator.request(region: region) {
                    authenticator, error in
                    println(authenticator)
                    println(error)
                    if let a = authenticator {
                        if self?.authenticators.add(a) {
                            self?.reloadAndScrollToBottom()
                        }
                        MMProgressHUD.dismissWithSuccess("success!")
                    }
                    else {
                        let message = error ? error!.localizedDescription : "unknown error"
                        MMProgressHUD.dismissWithError(message)
                    }
                }
                println(region)
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func editButtonTapped(AnyObject) {
        self.tableView.setEditing(!self.tableView.editing, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == SegueDetail {
            let dest = segue.destinationViewController as DetailViewController
            dest.authenticator = (sender as AuthenticatorCell).authenticator
        }
    }

    func reloadAndScrollToBottom() {
        tableView.reloadData()
        let last = NSIndexPath(forRow: authenticators.count - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(last, atScrollPosition: .Bottom, animated: true)
    }
}

extension MainViewController {
    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return authenticators.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell = tableView.dequeueReusableCellWithIdentifier("AUTHENTICATOR_CELL", forIndexPath: indexPath) as AuthenticatorCell
        cell.authenticator = authenticators[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 88
    }

    override func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        else {
            return .None
        }
    }

    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            let authenticator = (tableView.cellForRowAtIndexPath(indexPath) as AuthenticatorCell).authenticator
            println(authenticator)
        }
    }

    override func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!) {
        authenticators.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    override func tableView(tableView: UITableView!, willDisplayCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        if let cell = cell as? AuthenticatorCell {
            cell.start_timer()
        }
    }

    override func tableView(tableView: UITableView!, didEndDisplayingCell cell: UITableViewCell!, forRowAtIndexPath indexPath: NSIndexPath!)
    {
        if let cell = cell as? AuthenticatorCell {
            cell.stop_timer()
        }
    }
}
