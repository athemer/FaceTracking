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
        upperBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width , height: 75)
        
        return upperBg
    }()
    
    
    var lowerBackground: UIView = {
        
        let lowerBg = UIView()
        lowerBg.backgroundColor = .black
        lowerBg.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 75, width: UIScreen.main.bounds.width , height: 75)
        
        return lowerBg
        
    }()
    
    
    var sensitivityBtn: UIButton = {

        let btn = UIButton()
        btn.backgroundColor = .red
//        btn.setTitle("sensitivity", for: .normal)
        btn.setImage(UIImage(named: "speed")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.tintColor = .white
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
  
}
