//
//  MainViewController.swift
//  bna
//
//  Created by Rox Dorentus on 14-6-5.
//  Copyright (c) 2014年 rubyist.today. All rights reserved.
//

import UIKit
import Padlock
import MMProgressHUD

class MainViewController: UITableViewController {
    let SegueDetail = "authenticator_detail"
    let SegueRestore = "authenticator_restore"

    let authenticators: AuthenticatorStorage = AuthenticatorStorage.sharedStorage

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    @IBAction func addButtonTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Region", message: nil, preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Restore", style: UIAlertActionStyle.Default) {
            [weak self] _ in
            self!.performSegueWithIdentifier(self!.SegueRestore, sender: sender)
        })
        for region in Region.allValues {
            alert.addAction(UIAlertAction(title: region.rawValue, style: .Default) {
                [weak self] _ in
                MMProgressHUD.show()
                Authenticator.request(region: region) {
                    authenticator, error in
                    if let a = authenticator {
                        if self!.authenticators.add(a) {
                            self!.reloadAndScrollToBottom()
                        }
                        MMProgressHUD.dismissWithSuccess("success!")
                    }
                    else {
                        let message = error?.localizedDescription ?? "unknown error"
                        MMProgressHUD.dismissWithError(message)
                    }
                }
            })
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == SegueDetail {
            let dest = segue.destinationViewController as! DetailViewController
            dest.authenticator = (sender as! AuthenticatorCell).authenticator
        }
    }

    func reloadAndScrollToBottom() {
        tableView.reloadData()
        let last = NSIndexPath(forRow: authenticators.count - 1, inSection: 0)
        tableView.scrollToRowAtIndexPath(last, atScrollPosition: .Bottom, animated: true)
    }

}

extension MainViewController {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authenticators.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AUTHENTICATOR_CELL", forIndexPath: indexPath) as! AuthenticatorCell
        cell.authenticator = authenticators[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 88
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return .Delete
        }
        else {
            return .None
        }
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if let authenticator = (tableView.cellForRowAtIndexPath(indexPath) as! AuthenticatorCell).authenticator {
                if authenticators.del(authenticator) {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }
            }
        }
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        authenticators.move(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = cell as? AuthenticatorCell {
            cell.start_timer()
        }
    }

    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if let cell = cell as? AuthenticatorCell {
            cell.stop_timer()
        }
    }
}
