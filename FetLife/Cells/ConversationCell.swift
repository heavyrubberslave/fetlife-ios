//
//  ConversationCell.swift
//  FetLife
//
//  Created by Jose Cortinas on 2/2/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit
import AlamofireImage

class ConversationCell: UITableViewCell {
    
    // MARK: - Properties
    
    @IBOutlet weak var authorAvatarImage: UIImageView!
    @IBOutlet weak var authorNicknameLabel: UILabel!
    @IBOutlet weak var authorMetaLabel: UILabel!
    @IBOutlet weak var messageTimestampLabel: UILabel!
    @IBOutlet weak var messageSummaryLabel: UILabel!
    @IBOutlet weak var unreadMarkerView: UIView!
    
    var avatarImageFilter: AspectScaledToFillSizeWithRoundedCornersFilter?
    
    var conversation: Conversation? = nil {
        didSet {
            if let conversation = self.conversation where !conversation.invalidated {
                if let member = conversation.member {
                    self.authorAvatarImage.af_setImageWithURL(NSURL(string: member.avatarURL)!, filter: avatarImageFilter)
                    self.authorNicknameLabel.text = member.nickname
                    self.authorMetaLabel.text = member.metaLine
                }
                
                self.messageTimestampLabel.text = conversation.timeAgo()
                self.messageSummaryLabel.text = conversation.summary()
                self.unreadMarkerView.hidden = !conversation.hasNewMessages
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectedCellBackground = UIView()
        selectedCellBackground.backgroundColor = UIColor.blackColor()
        
        self.selectedBackgroundView = selectedCellBackground
        
        self.unreadMarkerView.backgroundColor = UIColor.unreadMarkerColor()
        
        self.avatarImageFilter = AspectScaledToFillSizeWithRoundedCornersFilter(size: authorAvatarImage.frame.size, radius: 3.0)
        self.authorAvatarImage.layer.cornerRadius = 3.0
        self.authorAvatarImage.layer.borderWidth = 0.5
        self.authorAvatarImage.layer.borderColor = UIColor.borderColor().CGColor
    }
}
