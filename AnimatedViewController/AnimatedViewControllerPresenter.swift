//
//  AnimatedViewControllerPresenter.swift
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

public enum Side {
    case Left
    case Right
    case Top
    case Bottom
}

public enum AnimationStyle {
    case ExpandFromCenter
    case Slide(dismissOpposite: Bool, side: Side)
}

public enum PresentationStyle {
    case Drawer(side: Side, phoneWantsFullScreen: Bool, screenRatio: Float)
    case FormSheet(horizontalRatio: Float, verticalRatio: Float, animationStyle: AnimationStyle)
}

public class AnimatedViewControllerPresenter: NSObject {
    
    let transitioningDelegate: UIViewControllerTransitioningDelegate
    let presentingViewController: UIViewController
    let presentedViewController: UIViewController
    
    convenience override public init() {
        self.init(presentingViewController: UIViewController(), presentedViewController: UIViewController())
    }
    
    public init(presentingViewController: UIViewController, presentedViewController: UIViewController, style: PresentationStyle = .FormSheet(horizontalRatio: 0.6, verticalRatio: 0.6, animationStyle: .ExpandFromCenter)) {
        self.presentingViewController = presentingViewController
        self.presentedViewController = presentedViewController
        
        self.transitioningDelegate = AnimatedTransitioner(style: style)
        super.init()
    }
    
    public func presentAnimatedController() {
        presentedViewController.transitioningDelegate = transitioningDelegate
        presentingViewController.transitioningDelegate = transitioningDelegate
        presentedViewController.modalPresentationStyle = .Custom
        presentingViewController.presentViewController(presentedViewController, animated: true, completion: nil)
    }
}
