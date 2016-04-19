//
//  ErrorView.swift
//  FetLife
//
//  Created by Jose Cortinas on 3/2/16.
//  Copyright © 2016 BitLove Inc. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    
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
    
    lazy var coneImage: UIImageView = {
        return UIImageView(image: UIImage(named: "Cone")!)
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = "Houston, we have a problem!"
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
        stackView.addArrangedSubview(coneImage)
        stackView.addArrangedSubview(textLabel)
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
}