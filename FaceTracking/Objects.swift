//
//  Objects.swift
//  FaceTracking
//
//  Created by 陳冠華 on 2017/5/5.
//  Copyright © 2017年 Pawel Chmiel. All rights reserved.
//

import Foundation
import UIKit



class Objects {
    
    
    let screenWidth = UIScreen.main.bounds.width
    
    var upperBackground: UIView = {
        
        let upperBg = UIView()
        upperBg.backgroundColor = .black

        return upperBg
    }()
    
    
    var lowerBackground: UIView = {
        
        let lowerBg = UIView()
        lowerBg.backgroundColor = .black

        return lowerBg
        
    }()
    
    
    var sensitivityBtn: UIButton = {

        let btn = UIButton()
        btn.backgroundColor = .red
        btn.setImage(UIImage(named: "speed")?.withRenderingMode(.alwaysOriginal), for: .normal)
        btn.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        
        return btn
    }()
    
    
    
    var progressView: UIProgressView = {
        
        let pView = UIProgressView()
        pView.progressViewStyle = .bar
        pView.trackTintColor = .white
        pView.progressTintColor = .red
        pView.frame = CGRect(x: 37.5, y: 60, width: UIScreen.main.bounds.width - 75, height: 1.5)
        pView.progress = 0.0
        
        return pView
    }()
    
    
    var snapIcon: UIButton = {
        let icon = UIButton()
        icon.setImage(UIImage(named: "snapIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        icon.frame = CGRect(x: (UIScreen.main.bounds.width - 50) / 2 , y: 12.5, width: 50, height: 50)
        
        return icon
    }()

    var sensitivityLabel: UILabel = {

        let label = UILabel()

        label.backgroundColor = .red
        label.tintColor = .white
        label.text = "normal"
        label.frame = CGRect(x: 50, y: 10, width: 60, height: 40)

        return label
    }()



    func setLowerBackgroundConstraints() {

        guard let superview = lowerBackground.superview else {
            print ("lower superview does not exist")
            return
        }

        lowerBackground.translatesAutoresizingMaskIntoConstraints = false
        lowerBackground.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 0).isActive = true
        lowerBackground.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 0).isActive = true
        lowerBackground.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0).isActive = true
        lowerBackground.heightAnchor.constraint(equalToConstant: 75).isActive = true

    }


    func setUpperBackgroundConstraints() {

        guard let superview = upperBackground.superview else {
            print ("upper superview does not exist")
            return
        }

        upperBackground.translatesAutoresizingMaskIntoConstraints = false
        upperBackground.leftAnchor.constraint(equalTo: superview.leftAnchor, constant: 0).isActive = true
        upperBackground.rightAnchor.constraint(equalTo: superview.rightAnchor, constant: 0).isActive = true
        upperBackground.topAnchor.constraint(equalTo: superview.topAnchor, constant: 0).isActive = true
        upperBackground.heightAnchor.constraint(equalToConstant: 75).isActive = true

    }
}
