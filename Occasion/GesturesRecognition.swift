//
//  GesturesRecognition.swift
//  Occasion
//
//  Created by Emin Emini on 10.4.20.
//  Copyright © 2020 Emin Emini. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let eventDismiss = Notification.Name("eventDismiss")
}

class DismissAnimator : NSObject {
}

extension DismissAnimator: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else {
                return
        }
        
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        let screenBounds = UIScreen.main.bounds
        let bottomLeftCorner = CGPoint(x: 0, y: screenBounds.height)
        let finalFrame = CGRect(origin: bottomLeftCorner, size: screenBounds.size)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fromVC.view.frame = finalFrame
        },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        )
    }
}

class Interactor: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}


enum PanAngleComparator {
    case lessThan
    case greaterThan
}

func limitPanAngle(_ gestureRecognizer: UIPanGestureRecognizer, degreesOfFreedom: CGFloat = 45.0, comparator: PanAngleComparator = .lessThan) -> Bool {
    let velocity: CGPoint = gestureRecognizer.velocity(in: gestureRecognizer.view)
    let degree: CGFloat = atan(velocity.y / velocity.x) * 180 / CGFloat.pi

    switch comparator {
    case .lessThan:
        return abs(degree) < degreesOfFreedom
    case .greaterThan:
        return abs(degree) > degreesOfFreedom
    }
}

func rubberBandDistance(_ offset: CGFloat, dimension: CGFloat, constant: CGFloat = 0.55) -> CGFloat {
    let result = (constant * abs(offset) * dimension) / (dimension + constant * abs(offset))

    return offset < 0.0 ? -result : result
}
