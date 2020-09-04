//
//  BudgetChartView.swift
//  BudgetChartView
//
//  Created by Ali Hasanoğlu on 3.09.2020.
//  Copyright © 2020 Ali Hasanoğlu. All rights reserved.
//

import Foundation
import UIKit

/// Pie slice object
public struct Slice: Equatable {
    var color: UIColor
    var percentage: CGFloat
}

public class BudgetChartView: UIView {

    private typealias PieAngle = (start: CGFloat, end: CGFloat, color: UIColor, percent: CGFloat)
    private var timeOffset: CFTimeInterval = 0.15

    /// Pie slices for feeding pie circle
    public var piesSlices: [Slice] = [] {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// Selected pie slice index for setting line width
    public var selectedIndex: Int = 0 {
        didSet {
            resetLayer()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// Distance between pie slices
    @IBInspectable public var pieSpace: Double = 3.0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// Unselected pie slice line width
    @IBInspectable public var sliceLineWidth: CGFloat = 4.0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    /// Selected pie slice line width
    @IBInspectable public var selectedSliceLineWidth: CGFloat = 8.0 {
        didSet {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    //MARK: Initializers
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard piesSlices.count > 0 else { return  }
        let slices = piesSlices.filter { $0.percentage > 0}
        timeOffset = 0.15
        if slices.count == 1 {
            var angle: PieAngle
            angle.0 = 0
            angle.1 = CGFloat(Double.pi * 2)
            angle.2 = slices[0].color
            angle.3 = slices[0].percentage
            addPieSlice(angle: angle, percent: 0, angleIndex: 0)
        } else {
            let angles = calcualteStartAndEndAngle(items: slices)

            for (index, angle) in angles.enumerated() {
                addPieSlice(angle: angle, percent: angle.percent, angleIndex: index)
            }
        }
    }

    /// Adds pie slice to create pie circle
    private func addPieSlice(angle: PieAngle, percent: CGFloat, angleIndex: Int) {
        var  shapeLayer = CAShapeLayer()
        let center = CGPoint(x: bounds.origin.x + bounds.size.width / 2, y: bounds.origin.y + bounds.size.height / 2)
        let circularPath = UIBezierPath(arcCenter: .zero,
                                        radius: self.frame.width / 2,
                                        startAngle: angle.start,
                                        endAngle: angle.end,
                                        clockwise: true)

        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = angle.color.cgColor
        shapeLayer.lineWidth = angleIndex == selectedIndex ? selectedSliceLineWidth : sliceLineWidth
        shapeLayer.position = center
        shapeLayer.lineCap = .round
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeEnd = 0
        basicAnimation(shapeLayer: &shapeLayer)
        layer.addSublayer(shapeLayer)
    }

    /// Deletes all sublayers of layer
    func resetLayer() {
        for layer in self.layer.sublayers ?? [] {
            layer.removeFromSuperlayer()
        }
    }

    /// Shape layer animation
    private func basicAnimation(shapeLayer: inout CAShapeLayer) {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 0.1
        basicAnimation.beginTime = CACurrentMediaTime() + timeOffset
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "shapeLayerAniamtion")
        timeOffset += 0.1
    }

    /// Determine each slice's start and end angle
    private func calcualteStartAndEndAngle(items: [Slice]) -> [PieAngle] {
        var angle: PieAngle
        var angleToStart: CGFloat = -90.0

        let totalSum = items.reduce(CGFloat(pieSpace)) { return $0 + $1.percentage }
        let spacing = CGFloat(pieSpace) / CGFloat(totalSum)
        var angleList: [PieAngle] = []

        for item in items {
            let endAngle = (item.percentage / totalSum * 2 * CGFloat.pi)  + angleToStart

            angle.0 = angleToStart + spacing

            if item == items.last {
                angle.1 = endAngle + (spacing * 2)
            } else {
                angle.1 = endAngle - spacing
            }

            angle.2 = item.color
            angle.3 = item.percentage
            angleList.append(angle)
            angleToStart = endAngle + spacing
        }
        return angleList
    }
}
