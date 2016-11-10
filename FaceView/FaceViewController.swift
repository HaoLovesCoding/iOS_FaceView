//
//  ViewController.swift
//  FaceView
//
//  Created by Hao WU on 11/2/16.
//  Copyright © 2016 Hao WU. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController{
    var expression = FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smirk){
        didSet{// when initialize the expression, didSet will not be called
            updateUI()
        }
    } // This Facial Expression is an abstraction, it did not know how to draw the pictures on the view
    
    @IBOutlet weak var faceView: FaceView! {// This is actually a pointer to the faceView
        didSet{// The pointer will be wired to the view when MVC is created, so didSet will be called and UI will be updated
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target:faceView, action: #selector(FaceView.changeScale(recoginzer:))
            ))
            /*let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(target: faceView, action: #selector(FaceViewController.increaseHappiness))
            happierSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            updateUI()*/
            
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.increaseHappiness)
            )
            happierSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self, action: #selector(FaceViewController.decreaseHappiness)
            )
            sadderSwipeGestureRecognizer.direction = .down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            updateUI() // View connected for first time, update it from Model
        }
    }
    
    public func increaseHappiness(){
        print ("swiping up")
        expression.mouth = expression.mouth.happierMouth() // it would return another happier mouth
        print(mouthCurvatures[expression.mouth])
    }
    
    public func decreaseHappiness(){
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    @IBAction func toggleEyes(recognizer: UITapGestureRecognizer) {
        if recognizer.state == .ended {
            switch expression.eyes {
            case .Open:
                expression.eyes = .Closed
            case .Closed:
                expression.eyes = .Open
            default:
                break;
            }
        }
    }
    
    
    private var mouthCurvatures = [FacialExpression.Mouth.Frown:-1.0,.Grin:0.5,.Smile:1.0,.Smirk:-0.5,.Neutral:0.0 ]
    // This is a dictionary to map FacialExpression to how we would draw it
    private var eyeBrowTilts = [FacialExpression.EyeBrows.Relaxed:0.5,.Furrowed:-0.5,.Normal:0.0]
    
    private func updateUI(){
        switch expression.eyes {
        case .Open:
            faceView.eyesOpen = true
        case .Closed:
            faceView.eyesOpen = false
        default:
            faceView.eyesOpen = false
        }
        faceView.mouthCurvature = mouthCurvatures[expression.mouth] ?? 0.0 //  dictionary looking up is a default, it get an optional, ?? will give 0.0 when the default is nil
        
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
}


