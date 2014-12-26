//
//  AnimatedTransitioner.swift
//  Copyright (c) 2014 Todd Kramer.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit

class AnimatedTransitioner: NSObject, UIViewControllerTransitioningDelegate {
    
    let style: PresentationStyle
    
    init(style: PresentationStyle) {
        self.style = style
        super.init()
    }
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return AnimatedPresentationController(presentedViewController: presented, presentingViewController: presenting, style: style)
    }
    
    func animatedTransitionController() -> ControllerAnimatedTransitioning {
        let animationController = ControllerAnimatedTransitioning()
        return animationController
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: ControllerAnimatedTransitioning = animatedTransitionController()
        animationController.isPresentation = true
        animationController.style = style
        
        return animationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animationController: ControllerAnimatedTransitioning = animatedTransitionController()
        animationController.isPresentation = false
        animationController.style = style
        
        return animationController
    }
}

class ControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var isPresentation = true
    var style: PresentationStyle = .Drawer(side: .Right, phoneWantsFullScreen: false, screenRatio: 0.5)
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        if isPresentation {
            containerView.addSubview(toVC!.view)
        }
        
        let animatingVC = isPresentation ? toVC! : fromVC!
        switch style {
        case .Drawer(let side, let phoneWantsFullScreen, let screenRatio):
            let presentedFrame = transitionContext.finalFrameForViewController(animatingVC)
            
            var dismissedFrame = presentedFrame
            
            switch side {
            case .Left:
                dismissedFrame.origin.x -= dismissedFrame.width
            case .Right:
                dismissedFrame.origin.x += dismissedFrame.width
            case .Top:
                dismissedFrame.origin.y -= dismissedFrame.height
            case .Bottom:
                dismissedFrame.origin.y += dismissedFrame.height
            }
            let initialFrame = isPresentation ? dismissedFrame : presentedFrame
            let finalFrame = isPresentation ? presentedFrame : dismissedFrame
            
            animatingVC.view.frame = initialFrame
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: .AllowUserInteraction | .BeginFromCurrentState, animations: { () -> Void in
                animatingVC.view.frame = finalFrame
                }) { (finished) -> Void in
                    if !self.isPresentation {
                        fromVC!.view.removeFromSuperview()
                    }
                    transitionContext.completeTransition(true)
            }
        case .FormSheet(let horizontalRatio, let verticalRatio, let animationStyle):
            switch animationStyle {
            case .ExpandFromCenter:
                animatingVC.view.frame = transitionContext.finalFrameForViewController(animatingVC)
                let presentationTransform = CGAffineTransformIdentity
                let dismissalTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(CGFloat(8 * M_PI)))
                
                animatingVC.view.transform = isPresentation ? dismissalTransform : presentationTransform
                
                UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: .AllowUserInteraction | .BeginFromCurrentState, animations: { () -> Void in
                    animatingVC.view.transform = self.isPresentation ? presentationTransform : dismissalTransform
                    }) { (finished) -> Void in
                        if !self.isPresentation {
                            fromVC!.view.removeFromSuperview()
                        }
                        transitionContext.completeTransition(true)
                }
            case .Slide(let dismissOpposite, let side):
                let presentedFrame = transitionContext.finalFrameForViewController(animatingVC)
                
                var dismissedFrame = presentedFrame
                var oppositeFrame = presentedFrame
                
                var addedWidth = CGFloat(0)
                var addedHeight = CGFloat(0)
                switch side {
                case .Left:
                    addedWidth = -(dismissedFrame.width / CGFloat(adjustRatio(horizontalRatio)))
                case .Right:
                    addedWidth = dismissedFrame.width / CGFloat(adjustRatio(horizontalRatio))
                case .Top:
                    addedHeight = -(dismissedFrame.height / CGFloat(adjustRatio(verticalRatio)))
                case .Bottom:
                    addedHeight = dismissedFrame.height / CGFloat(adjustRatio(verticalRatio))
                }
                dismissedFrame.origin.x += addedWidth
                dismissedFrame.origin.y += addedHeight
                
                oppositeFrame.origin.x -= addedWidth
                oppositeFrame.origin.y -= addedHeight
                
                let initialFrame = isPresentation ? dismissedFrame : presentedFrame
                let finalFrame = isPresentation ? presentedFrame : (dismissOpposite ? oppositeFrame : dismissedFrame)
                
                animatingVC.view.frame = initialFrame
                
                UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 300, initialSpringVelocity: 5, options: .AllowUserInteraction | .BeginFromCurrentState, animations: { () -> Void in
                    animatingVC.view.frame = finalFrame
                    }) { (finished) -> Void in
                        if !self.isPresentation {
                            fromVC!.view.removeFromSuperview()
                        }
                        transitionContext.completeTransition(true)
                }
            }
        }
    }

    func adjustRatio(ratio: Float) -> Float {
        return ratio > 1.0 ? 1.0 : (ratio < 0.1 ? 0.1 : ratio)
    }
}
