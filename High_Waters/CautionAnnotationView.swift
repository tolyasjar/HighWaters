//
//  CautionAnnotationView.swift
//  High_Waters
//
//  Created by Toleen Jaradat on 7/28/16.
//  Copyright © 2016 Toleen Jaradat. All rights reserved.
//

import UIKit
import MapKit

class CautionAnnotationView: MKAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        setupAnnotationView()
    }
    
    private func setupAnnotationView() {
        
        self.frame.size = CGSize(width: 30, height: 30)
        self.centerOffset = CGPoint(x: -5, y: -5)
        
        let imageView = UIImageView(image: UIImage(named: "caution-sign"))
        imageView.frame = self.frame
        self.addSubview(imageView)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
