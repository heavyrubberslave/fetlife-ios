//
//  MessagesTableViewController.swift
//  FetLife
//
//  Created by Jose Cortinas on 2/11/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit
import SlackTextViewController
import StatefulViewController
import SnapKit
import RealmSwift

class MessagesTableViewController: SLKTextViewController {
    
    // MARK: - Properties
    
    let incomingCellIdentifier = "MessagesTableViewCellIncoming"
    let outgoingCellIdentifier = "MessagesTableViewCellOutgoing"
    
    lazy var loadingView: LoadingView = {
        let lv = LoadingView(frame: self.view.frame)
        
        if self.messages != nil && !self.messages.isEmpty {
            lv.hidden = true
            lv.alpha = 0
        }
        
        return lv
    }()
    
    var conversation: Conversation! {
        didSet {
            self.messages = try! Realm().objects(Message).filter("conversationId == %@", self.conversation.id).sorted("createdAt", ascending: false)
        }
    }
    var messages: Results<Message>!
    var notificationToken: NotificationToken?
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingView)
        
        loadingView.snp_makeConstraints { make in
            if let navigationController = navigationController {
                make.top.equalTo(view).offset(navigationController.navigationBar.frame.height)
            }
            
            make.right.equalTo(view)
            make.bottom.equalTo(view)
            make.left.equalTo(view)
        }
        
        tableView.registerNib(UINib.init(nibName: incomingCellIdentifier, bundle: nil), forCellReuseIdentifier: incomingCellIdentifier)
        tableView.registerNib(UINib.init(nibName: outgoingCellIdentifier, bundle: nil), forCellReuseIdentifier: outgoingCellIdentifier)
        
        textInputbar.backgroundColor = UIColor.backgroundColor()
        textInputbar.layoutMargins = UIEdgeInsetsZero
        textInputbar.autoHideRightButton = true
        textInputbar.tintColor = UIColor.brickColor()
        
        textView.placeholder = "What say you?"
        textView.placeholderColor = UIColor.lightTextColor()
        textView.backgroundColor = UIColor.backgroundColor()
        textView.textColor = UIColor.whiteColor()
        textView.layer.borderWidth = 0.0
        textView.layer.cornerRadius = 2.0
        textView.dynamicTypeEnabled = false // This should stay false until messages support dynamic type.
        
        if let conversation = conversation {
            self.notificationToken = messages.addNotificationBlock({ [unowned self] results, error in
                guard let results = results where !results.isEmpty else { return }
                
                self.tableView.reloadData()
                self.hideLoadingView()
                
                let newMessageIds = results.filter("isNew == true").map { $0.id }
                
                if !newMessageIds.isEmpty {
                    API.sharedInstance.markMessagesAsRead(conversation.id, messageIds: newMessageIds)
                }
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.fetchMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Actions
    
    @IBAction func refreshAction(sender: UIBarButtonItem) {
        dismissKeyboard(true)
        showLoadingView()
        fetchMessages()
    }
    
    // MARK: - SlackTextViewController
    
    func tableViewStyleForCoder(decoder: NSCoder) -> UITableViewStyle {
        return UITableViewStyle.Plain
    }
    
    override func didPressRightButton(sender: AnyObject!) {
        textView.refreshFirstResponder()
        
        if let text = self.textView.text {
            let conversationId = conversation.id
            
            Dispatch.asyncOnUserInitiatedQueue() {
                API.sharedInstance.createAndSendMessage(conversationId, messageBody: text)
            }
        }
        
        super.didPressRightButton(sender)
    }
    
    override func keyForTextCaching() -> String? {
        return NSBundle.mainBundle().bundleIdentifier
    }
    
    // MARK: - TableView Delegate & DataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let messages = messages else { return 0 }
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        // Decide whether a conversation table cell should be incoming (left) or outgoing (right).
        let cellIdent = (message.memberId != conversation.member!.id) ? self.outgoingCellIdentifier : self.incomingCellIdentifier
        
        // Get a cell, and coerce into a base class.
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdent, forIndexPath: indexPath) as! BaseMessagesTableViewCell
        
        // SlackTextViewController inverts tables in order to get the layout to work. This means that our table cells needs to
        // apply the same inversion or be upside down.
        cell.transform = self.tableView.transform // 😬
        
        cell.message = message
        
        // Remove margins from the table cell.
        if cell.respondsToSelector("setPreservesSuperviewLayoutMargins:") {
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
        }
        
        // Force autolayout to apply for the cell before rendering it.
        cell.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let cell = cell as! BaseMessagesTableViewCell
        
        // Round that cell.
        cell.messageContainerView.layer.cornerRadius = 3.0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    // MARK: - Methods
    
    func fetchMessages() {
        if let conversation = conversation, let messages = messages {
            let conversationId = conversation.id
            
            if let lastMessage = messages.first {
                let parameters: Dictionary<String, AnyObject> = [
                    "since": Int(lastMessage.createdAt.timeIntervalSince1970),
                    "since_id": lastMessage.id
                ]
                
                Dispatch.asyncOnUserInitiatedQueue() {
                    API.sharedInstance.loadMessages(conversationId, parameters: parameters) { error in
                        self.hideLoadingView()
                    }
                }
            } else {
                Dispatch.asyncOnUserInitiatedQueue() {
                    API.sharedInstance.loadMessages(conversationId) { error in
                        self.hideLoadingView()
                    }
                }
            }
        }
    }
    
    func showLoadingView() {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.loadingView.alpha = 1
            },
            completion: { finished  in
                self.loadingView.hidden = false
            }
        )
    }
    
    func hideLoadingView() {
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.loadingView.alpha = 0
            },
            completion: { finished in
                self.loadingView.hidden = true
            }
        )
    }
}
