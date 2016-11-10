//
//  FaceView.swift
//  FaceView
//
//  Created by Hao WU on 11/2/16.
//  Copyright © 2016 Hao WU. All rights reserved.
//

import UIKit
@IBDesignable
class FaceView: UIView {
    @IBInspectable
    var scale: CGFloat = 0.9 {// this will be fill the contraints only 0.9
        didSet{// didSet is a function that will be executed when this property is set
            setNeedsDisplay()//tell system to redraw
        }
    }
    
    @IBInspectable
    var eyesOpen: Bool = false { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var mouthCurvature: Double = 1.0 { didSet { setNeedsDisplay() } }
    
    @IBInspectable
    var lineWidth: CGFloat = 5.0 { didSet { setNeedsDisplay() } }

    
    @IBInspectable
    var skullRaius: CGFloat{
        return min(bounds.midX, bounds.midY) * scale// This is actually get, bounds is a property, can not access it when on the initialization stage
    }
    
    @IBInspectable
    var eyeBrowTilt: Double = -0.5 { didSet { setNeedsDisplay() } }
    
    public func changeScale (recoginzer: UIPinchGestureRecognizer){ // This will take the one in the UIViewController
        switch recoginzer.state {
        case .changed, .ended:// means changed or ended
            scale*=recoginzer.scale
            recoginzer.scale=1.0
        default:
            break
        }
        
    }

    
    var skullCenter: CGPoint{
        return CGPoint(x: bounds.midX, y:bounds.midY)
    }
    //var skullCenter = CGPoint(x: bounds.midX, y: bounds.midX)
    
    private struct Ratios {
        static let SkullRadiusToEyeOffset: CGFloat = 3
        static let SkullRadiusToEyeRadius: CGFloat = 10
        static let SkullRadiusToMouthWidth: CGFloat = 1
        static let SkullRadiusToMouthHeight: CGFloat = 3
        static let SkullRadiusToMouthOffset: CGFloat = 3
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func getEyeCenter(eye: Eye) -> CGPoint
    {
        let eyeOffset = skullRaius / Ratios.SkullRadiusToEyeOffset
        var eyeCenter = skullCenter
        eyeCenter.y -= eyeOffset
        switch eye {
        case .Left: eyeCenter.x -= eyeOffset
        case .Right: eyeCenter.x += eyeOffset
        }
        return eyeCenter
    }
    
/*    private func pathForEye (eye : Eye) -> UIBezierPath {
        let eyeRadius = skullRaius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye: eye)
        return pathForCircleCenteredAtPoint(midPoint: eyeCenter, withradius: eyeRadius)
    }*/
    
    private func pathForEye(eye: Eye) -> UIBezierPath
    {
        let eyeRadius = skullRaius / Ratios.SkullRadiusToEyeRadius
        let eyeCenter = getEyeCenter(eye: eye)
        if eyesOpen {
            return pathForCircleCenteredAtPoint(midPoint: eyeCenter, withradius: eyeRadius)
        } else {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: eyeCenter.x - eyeRadius, y: eyeCenter.y))
            path.addLine(to: CGPoint(x: eyeCenter.x + eyeRadius, y: eyeCenter.y))
            path.lineWidth = lineWidth
            return path
        }
    }
    
    private func pathForCircleCenteredAtPoint (midPoint: CGPoint, withradius radius: CGFloat) -> UIBezierPath{ //the second radius is the internal name
        let path = UIBezierPath(
            arcCenter: midPoint,
            radius: radius,startAngle: 0.0,
            endAngle: CGFloat(2*M_PI),
            clockwise: false)
        path.lineWidth = 5.0
        return path
        
    }
    
    private func pathForBrow(eye: Eye) -> UIBezierPath
    {
        var tilt = eyeBrowTilt
        switch eye {
        case .Left: tilt *= -1.0
        case .Right: break
        }
        var browCenter = getEyeCenter(eye: eye)
        browCenter.y -= skullRaius / Ratios.SkullRadiusToEyeOffset
        let eyeRadius = skullRaius / Ratios.SkullRadiusToEyeRadius
        let tiltOffset = CGFloat(max(-1, min(tilt, 1))) * eyeRadius / 2
        let browStart = CGPoint(x: browCenter.x - eyeRadius, y: browCenter.y - tiltOffset)
        let browEnd = CGPoint(x: browCenter.x + eyeRadius, y: browCenter.y + tiltOffset)
        let path = UIBezierPath()
        path.move(to: browStart)
        path.addLine(to: browEnd)
        path.lineWidth = lineWidth
        return path
    }
    
    private func pathForMouth() -> UIBezierPath {
        
        let mouthWidth = skullRaius / Ratios.SkullRadiusToMouthWidth
        let mouthHeight = skullRaius / Ratios.SkullRadiusToMouthHeight
        let mouthOffset = skullRaius / Ratios.SkullRadiusToMouthOffset
        let mouthRect = CGRect(x: skullCenter.x - mouthWidth/2, y: skullCenter.y + mouthOffset, width: mouthWidth, height: mouthHeight)
        // mouthRect is a helper rectangle as the referrence of the mouth
        //let mouthCurvature = 1 // 1 for smile
        let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        //let smileOffset = CGFloat(max(-1, min(mouthCurvature, 1))) * mouthRect.height
        let start = CGPoint(x: mouthRect.minX, y: mouthRect.minY)
        let end = CGPoint(x: mouthRect.maxX, y: mouthRect.minY)
        let cp1 = CGPoint(x: mouthRect.minX + mouthRect.width / 3, y: mouthRect.minY + smileOffset) // control point 1
        let cp2 = CGPoint(x: mouthRect.maxX - mouthRect.width / 3, y: mouthRect.minY + smileOffset) // control point 2
        
        let path = UIBezierPath()
        // This the drawing part
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        path.lineWidth = 5.0
        
        return path
    
    }
    
    override func draw(_ rect: CGRect) {
        //let width = bounds.size.width
        //let height = bounds.size.width
        //let skullRaius = min(width, height)/2
        //let skullCenter = CGPoint(x: bounds.midX, y: bounds.midX)
        //let skull = UIBezierPath(arcCenter: skullCenter,radius: skullRaius,startAngle: 0.0, endAngle: CGFloat(2*M_PI),clockwise: false)
        //skull.lineWidth=5.0
        UIColor.blue.set()
        pathForCircleCenteredAtPoint(midPoint: skullCenter, withradius: skullRaius).stroke()
        pathForEye(eye: Eye.Left).stroke()//!!!! This is how to use enum, pass it to a function
        pathForEye(eye: Eye.Right).stroke()
        pathForMouth().stroke()
        pathForBrow(eye: Eye.Left).stroke()
        pathForBrow(eye: Eye.Right).stroke()
        // Drawing code
    }

    
}
