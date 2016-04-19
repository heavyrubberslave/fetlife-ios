//
//  NoConversationsView.swift
//  FetLife
//
//  Created by Jose Cortinas on 3/2/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit

class NoConversationsView: UIView {
    
    // MARK: - Properties
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .Vertical
        stack.distribution = .FillProportionally
        stack.alignment = .Center
        stack.spacing = 26.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    lazy var vaderImage: UIImageView = {
        return UIImageView(image: UIImage(named: "Vader")!)
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Luke, you sadly haven't received any messages yet."
        label.textColor = UIColor.brownishGreyColor()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .Center
        return label
    }()
    
    lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFontOfSize(17.0)
        button.setTitle("Refresh", forState: .Normal)
        button.setTitleColor(UIColor.brickColor(), forState: .Normal)
        button.addTarget(self, action: "tryRefresh", forControlEvents: .TouchUpInside)
        return button
    }()
    
    var refreshAction: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        stackView.addArrangedSubview(vaderImage)
        stackView.addArrangedSubview(textLabel)
        stackView.addArrangedSubview(refreshButton)
        
        addSubview(stackView)
        
        backgroundColor = UIColor.backgroundColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp_makeConstraints { make in
            make.centerX.equalTo(snp_centerX)
            make.topMargin.equalTo(70.0)
        }
        
        textLabel.snp_makeConstraints { make in
            make.width.lessThanOrEqualTo(248.0)
        }
    }
    
    // MARK: - Actions
    
    func tryRefresh() {
        refreshAction?()
    }
}