//
//  AnimatedPresentationController.swift
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

class AnimatedPresentationController: UIPresentationController {
    var dimmingView: UIView!
    var style: PresentationStyle
    
    init(presentedViewController: UIViewController!, presentingViewController: UIViewController!, style: PresentationStyle) {
        self.style = style
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        self.configureDimmingView()
    }
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = CGFloat(0.0)
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context) -> Void in
                self.dimmingView.alpha = CGFloat(1.0)
                }, completion: nil)
        } else {
            self.dimmingView.alpha = CGFloat(1.0)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context) -> Void in
                self.dimmingView.alpha = CGFloat(0.0)
                }, completion: nil)
        } else {
            self.dimmingView.alpha = CGFloat(0.0)
        }
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        switch style {
        case .Drawer(let side, let phoneWantsFullScreen, let screenRatio):
            let targetWidth = CGFloat(floorf(Float(parentSize.width) * adjustRatio(screenRatio)))
            let targetHeight = CGFloat(floorf(Float(parentSize.height) * adjustRatio(screenRatio)))
            switch side {
            case .Left:
                fallthrough
            case .Right:
                return CGSizeMake(targetWidth, parentSize.height)
            case .Top:
                fallthrough
            case .Bottom:
                return CGSizeMake(parentSize.width, targetHeight)
            }
        case .FormSheet(let horizontalRatio, let verticalRatio, let animationStyle):
            let targetWidth = CGFloat(floorf(Float(parentSize.width) * adjustRatio(horizontalRatio)))
            let targetHeight = CGFloat(floorf(Float(parentSize.height) * adjustRatio(verticalRatio)))
            return CGSizeMake(targetWidth, targetHeight)
        }
    }
    
    func adjustRatio(ratio: Float) -> Float {
        return ratio > 1.0 ? 1.0 : (ratio < 0.1 ? 0.1 : ratio)
    }
    
    override func containerViewWillLayoutSubviews() {
        dimmingView.frame = containerView.bounds
        presentedView().frame = frameOfPresentedViewInContainerView()
    }
    
    override func shouldPresentInFullscreen() -> Bool {
        return true
    }
    
    override func adaptivePresentationStyle() -> UIModalPresentationStyle {
        switch style {
        case .Drawer(let side, let phoneWantsFullScreen, let screenRatio):
            return phoneWantsFullScreen ? .OverFullScreen : .None
        case .FormSheet:
            return .None
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView.bounds
        
        presentedViewFrame.size = sizeForChildContentContainer(presentedViewController, withParentContainerSize: containerBounds.size)
        
        switch style {
        case .Drawer(let side, let phoneWantsFullScreen, let screenRatio):
            switch side {
            case .Left:
                presentedViewFrame.origin.x = 0
            case .Right:
                presentedViewFrame.origin.x = containerBounds.width - presentedViewFrame.width
            case .Top:
                presentedViewFrame.origin.y = 0
            case .Bottom:
                presentedViewFrame.origin.y = containerBounds.height - presentedViewFrame.height
            }
        case .FormSheet:
            presentedViewFrame.origin.x += (containerBounds.width - presentedViewFrame.width) / 2
            presentedViewFrame.origin.y += (containerBounds.height - presentedViewFrame.height) / 2
        }
        
        return presentedViewFrame
    }
    
    func configureDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.alpha = 0
        
        let tapGR = UITapGestureRecognizer(target: self, action: "dimmingViewTapped:")
        dimmingView.addGestureRecognizer(tapGR)
    }
    
    func dimmingViewTapped(gesture: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}
