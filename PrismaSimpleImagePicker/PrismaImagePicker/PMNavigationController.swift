//
//  PMNavigationController.swift
//  PrismaSimpleImagePicker
//
//  Created by Roy lee on 16/7/24.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

import UIKit

let kPushDuration = 0.32

class PushAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var push: Bool = true
    var isInteractive: Bool = false
    
    
    override init() {
        super.init()
    }
    
    convenience init(isPush: Bool) {
        self.init()
        self.push = isPush
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return kPushDuration
    }

    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView = transitionContext.containerView()
        
        containerView?.addSubview(fromViewController!.view)
        containerView?.addSubview(toViewController!.view)
        toViewController?.view.frame = fromViewController!.view.bounds
        
        var fromFrame = fromViewController?.view.frame
        var toFrame = toViewController?.view.frame
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        var animationOption = UIViewAnimationOptions.CurveEaseInOut
        
        if isInteractive {
            animationOption = UIViewAnimationOptions.CurveLinear
        }

        if push {
            toFrame?.origin.x = screenWidth
            toViewController?.view.frame = toFrame!
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: animationOption, animations: {
                fromFrame?.origin.x = -screenWidth
                fromViewController?.view.frame = fromFrame!
                toFrame?.origin.x = 0
                toViewController?.view.frame = toFrame!
                }, completion: { (com: Bool) in
                    let complete = !transitionContext.transitionWasCancelled()
                    if complete {
                        if let nav = fromViewController?.navigationController as? PMNavigationController  {
                            if let completion = nav.completionHandler {
                                completion(isPush: true)
                            }
                        }
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }else {
            toFrame?.origin.x = -screenWidth
            toViewController?.view.frame = toFrame!
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: animationOption, animations: {
                fromFrame?.origin.x = screenWidth
                fromViewController?.view.frame = fromFrame!
                toFrame?.origin.x = 0
                toViewController?.view.frame = toFrame!
                }, completion: { (com: Bool) in
                    let complete = !transitionContext.transitionWasCancelled()
                    if complete {
                        if let nav = toViewController?.navigationController as? PMNavigationController  {
                            if let completion = nav.completionHandler {
                                completion(isPush: false)
                            }
                        }
                    }
                    transitionContext.completeTransition(complete)
            })
        }
        
    }
}



class PMNavigationController: UINavigationController, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer.init()
    var frameOrigin: CGPoint = CGPointZero
    var interactionController: UIPercentDrivenInteractiveTransition?
    var animator: PushAnimator?
    var isInteractive: Bool = false
    var popEdgeInset: CGFloat = 50
    var completionHandler: ((isPush: Bool)->Void)?
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
        
        // Add new pan gesture replace the edge gesture
        panGestureRecognizer.addTarget(self, action: #selector(PMNavigationController.didPan(_:)))
        panGestureRecognizer.delegate = self
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: Change the frame of the default view, under the capture view
    override func viewDidLayoutSubviews() {
        var frame = view.frame
        frame.origin.y = frameOrigin.y
        frame.size.height = UIScreen.mainScreen().bounds.size.height - frame.origin.y
        view.frame = frame
    }
    
    override func pushViewController(viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        if !animated {
            if let completion = completionHandler {
                completion(isPush: true)
            }
        }
    }
    
    override func popViewControllerAnimated(animated: Bool) -> UIViewController? {
        if !animated {
            if let completion = completionHandler {
                completion(isPush: false)
            }
        }
        return super.popViewControllerAnimated(animated)
    }
    
    func pushViewController(viewController: UIViewController, animated: Bool, completion:((isPush: Bool)->Void)?) {
        completionHandler = completion
        self.pushViewController(viewController, animated: animated)
    }
    
    
    func popViewControllerAnimated(animated: Bool, completion:((isPush: Bool)->Void)?) -> UIViewController? {
        completionHandler = completion
        return self.popViewControllerAnimated(animated)
    }
    
    // MARK: Transition animation
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if animator == nil {
            animator = PushAnimator.init(isPush: operation == UINavigationControllerOperation.Push)
        }
        animator?.isInteractive = isInteractive
        animator?.push = operation == UINavigationControllerOperation.Push
        return animator!
    }
    
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func didPan(panGestureRecognizer: UIPanGestureRecognizer) {
        
        if panGestureRecognizer.state == .Began {
            
            isInteractive = true
            animator?.isInteractive = true
            interactionController = UIPercentDrivenInteractiveTransition()
            popViewControllerAnimated(true)
        }else if panGestureRecognizer.state == .Changed {
            
            let translaton = panGestureRecognizer.translationInView(view)
            let percent = translaton.x / CGRectGetWidth(view!.bounds)
            interactionController!.updateInteractiveTransition(percent)
        }else if panGestureRecognizer.state == .Ended {
            
            if panGestureRecognizer.velocityInView(view).x > 100 {
                interactionController!.finishInteractiveTransition()
            }else {
                interactionController!.cancelInteractiveTransition()
            }
            interactionController = nil
            animator?.isInteractive = false
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.locationInView(view)
        if location.y < 64 || location.x > popEdgeInset {
            return false
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
