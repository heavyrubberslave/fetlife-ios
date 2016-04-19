//
//  LoadingView.swift
//  FetLife
//
//  Created by Jose Cortinas on 3/2/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
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
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle:  UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.startAnimating()
        return indicator
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading…"
        label.textColor = UIColor.brownishGreyColor()
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .Center
        return label
    }()
    
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
        stackView.addArrangedSubview(activityIndicatorView)
        stackView.addArrangedSubview(textLabel)
        
        addSubview(stackView)
        
        backgroundColor = UIColor.backgroundColor()
        translatesAutoresizingMaskIntoConstraints = false
        
        stackView.snp_makeConstraints { make in
            make.centerX.equalTo(snp_centerX)
            make.topMargin.equalTo(97.0)
        }
        
        activityIndicatorView.snp_makeConstraints { make in
            make.size.equalTo(37.0)
        }
        
        textLabel.snp_makeConstraints { make in
            make.width.lessThanOrEqualTo(248.0)
        }
    }
}