//
//  ValueGraphView.swift
//  Grapher
//
//  Created by Alexey Donov on 30/11/2017.
//  Copyright © 2017 Alexey Donov. All rights reserved.
//

import UIKit

@IBDesignable
class ValueGraphView: UIView {
    
    var values: [Double] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var min: Double? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var max: Double? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var graphColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var showTicks: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable
    var tickRadius: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: UIView
    
    override func draw(_ rect: CGRect) {
        let boundsWidth = bounds.width - tickRadius * 4
        let boundsHeight = bounds.height - tickRadius * 4
        let leftIndent = tickRadius * 2
        let topIndent = tickRadius * 2
        
        let min = self.min ?? values.min() ?? 0
        let max = self.max ?? values.max() ?? 100
        let step = boundsWidth / CGFloat(values.count - 1)
        
        let path = UIBezierPath()
        var ticks: [UIBezierPath] = []
        values.enumerated().forEach { index, value in
            let x = CGFloat(index) * step
            let y = CGFloat(value - min) / CGFloat(max - min) * boundsHeight
            let point = CGPoint(x: leftIndent + x, y: topIndent + boundsHeight - y)
            if index == 0 {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
            ticks.append(UIBezierPath(arcCenter: point, radius: tickRadius, startAngle: 0, endAngle: CGFloat(Double.pi * 2), clockwise: true))
        }
        
        graphColor.setStroke()
        path.stroke()
        
        if showTicks {
            graphColor.setFill()
            ticks.forEach { $0.fill() }
        }
        
        UIColor.lightGray.setStroke()
        let roundRect = UIBezierPath(roundedRect: bounds, cornerRadius: tickRadius * 2)
        roundRect.flatness = 0.1
        roundRect.stroke()
    }
    
    override func prepareForInterfaceBuilder() {
        values = [150, 145, 140, 120, 115, 110, 105, 100, 95, 70, 60, 65, 30, 20, 25, 15, 5]
    }

}
