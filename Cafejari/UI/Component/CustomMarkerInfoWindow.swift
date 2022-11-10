//
//  CustomMarkerInfoView.swift
//  Cafejari
//
//  Created by 안용우 on 2022/10/22.
//

import Foundation
import UIKit

class CustomMarkerInfoWindow: UIView {
    
    var txtLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var subtitleLabel: UILabel = {
        let v = UILabel()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    init(frame: CGRect, title: String, subTitle: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        self.addSubview(txtLabel)
        txtLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 6).isActive = true
        txtLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6).isActive = true
        txtLabel.font = UIFont.boldSystemFont(ofSize: 12)
        txtLabel.numberOfLines = 1
        txtLabel.textColor = UIColor.black
        txtLabel.text = title
        
        self.addSubview(subtitleLabel)
        subtitleLabel.topAnchor.constraint(equalTo: txtLabel.bottomAnchor, constant: 2).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
        subtitleLabel.font = UIFont.boldSystemFont(ofSize: 11)
        subtitleLabel.textColor = UIColor.gray
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = subTitle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 200, height: 50)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.masksToBounds = true
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
    }
}
