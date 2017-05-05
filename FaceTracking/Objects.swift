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
        lowerBg.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 150, width: UIScreen.main.bounds.width , height: 75)
        
        return lowerBg
        
    }()
    
    
    var sensitivityBtn: UIButton = {

        let btn = UIButton()
        btn.backgroundColor = .red
//        btn.setTitle("sensitivity", for: .normal)
        btn.setImage(UIImage(named: "speed")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        btn.tintColor = .white
        btn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        
        return btn
    }()
    
    
    
    var progressView: UIProgressView = {
        
        let pView = UIProgressView()
        pView.progressViewStyle = .bar
        pView.trackTintColor = .red
        pView.progressTintColor = .white
        pView.frame = CGRect(x: 37.5, y: 60, width: 300, height: 10)
        
        return pView
    }()
    
    
    
    
    
}
