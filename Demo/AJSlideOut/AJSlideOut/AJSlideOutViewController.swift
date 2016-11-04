//
//  ContainerViewController.swift
//  AJSlideOut
//
//  Created by Asif Junaid on 11/4/16.
//  Copyright © 2016 Asif Junaid. All rights reserved.
//

import Foundation

import UIKit


/*
 Delgates to be implemented by center class of the "Slide out"
 */
@objc
protocol AJSlideOutViewDelegate {
    @objc optional func toggleLeftPanel()
    @objc optional func collapseSidePanels()
 }

var delegate : AJSlideOutViewDelegate?

/*
 States a slider can be in
 */
enum SlideOutState {
    case LeftPanelCollapsed
    case LeftPanelExpanded
}
struct AJSlideOutConstants {
    static let mainController = ["storyboardName":"Main","viewcontrollerID":"CenterScreenVC"]
    static let leftController = ["storyboardName":"Main","viewcontrollerID":"ScreenLeftVC"]

    
}
class AJSlideOutViewController: UIViewController{
    
    var centerViewController: CenterViewController?
    var leftViewController: LeftViewController?
    
    var centerNavigationController: UINavigationController!
    var leftNavigationController : UINavigationController!
    var navBar: UINavigationBar = UINavigationBar()
    
    var currentState: SlideOutState = .LeftPanelCollapsed {
        didSet {
            let shouldShowShadow = currentState != .LeftPanelCollapsed
            showShadowForCenterViewController(shouldShowShadow: shouldShowShadow)
        }
    }
    
    
    //The width of the center panel that should be visible
    let centerPanelExpandedOffset : CGFloat = 60
    //MARK: Lifecycle functions
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initCenterViewController()
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    /*
     wrap the centerViewController in a navigation controller, so we can push views to it
     and display bar button items in the navigation bar
     */
    func initCenterViewController(){
        
        centerViewController = UIStoryboard(name: AJSlideOutConstants.mainController["storyboardName"]!, bundle: nil).instantiateViewController(withIdentifier: AJSlideOutConstants.mainController["viewcontrollerID"]!) as? CenterViewController
        delegate = self
        centerNavigationController = UINavigationController(rootViewController: centerViewController!)
        //        centerNavigationController.navigationBar.barTintColor = Constant.blueDIFCColor
        centerNavigationController.navigationBar.frame.origin.y = -44
        view.addSubview(centerNavigationController.view)
        
        _ = centerNavigationController.navigationBar.sizeThatFits(CGSize.init(width: self.view.frame.width, height: 100))
        
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMove(toParentViewController: self)
        
    }
    
    func addGestures(){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(AJSlideOutViewController.handlePanGesture(recognizer:)))
        centerNavigationController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     Setting shadow for center view controller in case its collapsed, for a better UI experince
     */
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8//change it to give shadow effect
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
    
}
//MARK: Handling sliding transition function
extension AJSlideOutViewController : AJSlideOutViewDelegate{
    /*
     Add the left side menu screen
     */
    func addLeftPanelViewController() {
        if (leftViewController == nil && leftNavigationController == nil) {
            leftViewController = UIStoryboard(name: AJSlideOutConstants.leftController["storyboardName"]!, bundle: nil).instantiateViewController(withIdentifier: AJSlideOutConstants.leftController["viewcontrollerID"]!) as? LeftViewController
            addChildSidePanelController(sidePanelController: leftViewController!)
        }
    }
    /*
     Move the side view in front of center screen
     */
    func addChildSidePanelController(sidePanelController: LeftViewController) {
        
        leftNavigationController = UINavigationController(rootViewController: sidePanelController)
        view.insertSubview(leftNavigationController.view, at: 0)
        addChildViewController(leftNavigationController)
        leftNavigationController.didMove(toParentViewController: self)
        
        
    }
    
    
    /*
     toggle the side menu screen
     */
    
    func toggleLeftPanel() {
        let notAlreadyExpanded = (currentState != .LeftPanelExpanded)
        if notAlreadyExpanded {
            addLeftPanelViewController()
        }
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    /*
     Collapse side panels
     */
    func collapseSidePanels() {
        switch (currentState) {
        case .LeftPanelExpanded:
            toggleLeftPanel()
        default:
            break
        }
    }
    /*
     @shouldExpand detrmines whether we should animate left side view to the center or remove it entirely
     */
    func animateLeftPanel(shouldExpand: Bool) {
        
        if (shouldExpand) {
            currentState = .LeftPanelExpanded
            if UIDevice.current.userInterfaceIdiom == .pad{
                
                animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            }else{
                
                animateCenterPanelXPosition(targetPosition: centerNavigationController.view.frame.width - centerPanelExpandedOffset)
            }
            
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.currentState = .LeftPanelCollapsed
                
                for _ in self.leftNavigationController.viewControllers{
                    self.leftNavigationController.popViewController(animated: false)
                    
                }
                self.leftViewController = nil
            }
        }
    }
    /*
     @targetPosition determines the X postion to animate till
     */
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
}

//MARK: UIGestureRecognizerDelegate functions

extension AJSlideOutViewController : UIGestureRecognizerDelegate{
    /*
     Handle all the gestures by user
     */
    func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        
        let gestureIsDraggingFromLeftToRight = (recognizer.velocity(in: view).x > 0)
        print("point : \(recognizer.view!.center.x)")
        switch(recognizer.state) {
        case .began:
            //If user is dragging from left to right we add the side view
            if (currentState == .LeftPanelCollapsed) {
                if (gestureIsDraggingFromLeftToRight) {
                    addLeftPanelViewController()
                }
                showShadowForCenterViewController(shouldShowShadow: true)
            }
        case .changed:
            //Only if Left side menu is initialized that we start tracking the changes
            if (leftViewController != nil) {
                recognizer.view!.center.x = recognizer.view!.center.x + recognizer.translation(in: view).x
                recognizer.setTranslation(CGPoint.zero, in: view)
            }
            
        case .ended:
            //if the user has dragged for more than half way, we would take over and animate it till the end
            if (leftViewController != nil) {
                // animate the side panel open or closed based on whether the view has moved more or less than halfway
                let hasMovedGreaterThanHalfway = recognizer.view!.center.x > (view.bounds.size.width)
                animateLeftPanel(shouldExpand: hasMovedGreaterThanHalfway)
            }
            
        default:
            break
        }
    }
    
}


