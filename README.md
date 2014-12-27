# AnimatedViewController

Custom presentation controller implementation for presenting animated action sheets, sidebars / drawers, and form sheets.

## Features
- written in Swift
- supports all size classes and rotation
- two form sheet styles (expand from center, animate from top, bottom, left, right)
- left and right sidebars / drawers
- action sheet (bottom drawer)

## Requirements
Since AnimatedViewController uses UIPresentationController and is a dynamic framework, **iOS 8 is required**

## Installation
To install AnimatedViewController:
  1. Download, clone, or submodule AnimatedViewController.
  2. Drag the **AnimatedViewController.xcodeproj** file into your project under the **Products** folder
  3. In your target's **Build Phases** settings, add **AnimatedViewController** to the **Target Dependencies** build phase.
  4. Add the **AnimatedViewController.framework** product to the **Link Binary With Libraries** build phase.
  5. If there is no **Copy Files** build phase, add one.
  6. Add **AnimatedViewController.framework** to the **Copy Files** build phase and set the destination to **Frameworks**

## Usage
In the view controller you will be presenting from, import AnimatedViewController and add a variable for the presenter object.

``` swift
import UIKit
import AnimatedViewController

class ViewController: UIViewController {
    var presenter = AnimatedViewControllerPresenter()

}
```

Next, get the view controller you are going to present and initialize the presenter object with a presentingViewController (self), presentedViewController, and a presentation style.

PresentationStyle is an enum with two types, **Drawer** and **FormSheet**, each with their own associated values.

For the **Drawer** type, you can set the **side**, **phoneWantsFullScreen**, and **screenRatio** associated values.
- **side** is another enum with four options (Left, Right, Top, Bottom)
- **phoneWantsFullScreen** sets the adaptive presentation style to full screen for phones when set to **true** and uses the **screenRatio** to determine the size when set to **false**
- **screenRatio** sets the portion of the screen that will be covered by the drawer or action sheet and **must be a float value between 0.1 and 1**

To present a custom action sheet that covers 3/4 of the screen::

``` swift
func presentActionSheet() {
    let actionSheet = storyboard?.instantiateViewControllerWithIdentifier
      ("com.example.actionsheet") as UIViewController
    presenter = AnimatedViewControllerPresenter(presentingViewController: self, 
      presentedViewController: actionSheet, style: .Drawer(side: .Bottom, 
      phoneWantsFullScreen: false, screenRatio: 0.75))
    presenter.presentAnimatedController()
}
```

For the **FormSheet** type, you can set the **horizontalRatio**, **verticalRatio**, and **animationStyle** associated values.
- **horizontalRatio** sets the portion of the screen width the form sheet will use
- **verticalRatio** sets the portion of the screen height the form sheet will use
- **animationStyle** is an enum with two options, **ExpandFromCenter** and **Slide**

To present a custom form sheet that expands from the center of the screen and covers 3/5 of the width and height:

``` swift
func presentExpandingFormSheet() {
    let formSheet = storyboard?.instantiateViewControllerWithIdentifier
      ("com.example.expandformsheet") as UIViewController
    presenter = AnimatedViewControllerPresenter(presentingViewController: self,
      presentedViewController: formSheet, style: .FormSheet(horizontalRatio: 0.6, 
      verticalRatio: 0.6, animationStyle: .ExpandFromCenter))
    presenter.presentAnimatedController()
}
```

The Slide animation style has its own associated values, **dismissOpposite** and **side**
- **dismissOpposite** will dismiss the form sheet in the opposite direction from which it was presented when set to **true** and will dismiss the form sheet back to its original side when set to **false**
- **side** is the same enum from above which lets you set the side from which the form sheet will be presented (Left, Right, Top, Bottom)

To present a custom form sheet that slides from left and dismisses to the right and covers 3/5 of the width and height:

``` swift
func presentLeftToRightFormSheet() {
    let formSheet = storyboard?.instantiateViewControllerWithIdentifier
      ("com.example.leftformsheet") as UIViewController
    presenter = AnimatedViewControllerPresenter(presentingViewController: self,
      presentedViewController: formSheet, style: .FormSheet(horizontalRatio: 0.6, 
      verticalRatio: 0.6, animationStyle: .Slide(dismissOpposite: true, side: .Left)))
    presenter.presentAnimatedController()
}
```

## Author
- [Todd Kramer](http://www.tekramer.com)

## License
AnimatedViewController is available under the MIT license. See the [full license here.](./LICENSE.txt)
