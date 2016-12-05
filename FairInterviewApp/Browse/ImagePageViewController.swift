//
//  ImagePageViewController.swift
//  FairInterviewApp
//
//  Created by Mike Wang on 11/27/16.
//  Copyright © 2016 Mike Wang. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

class ImagePageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]? {
        didSet {
            setup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
    }
    
    func setup() {
        if let initialViewController = orderedViewControllers?.first {
            scrollToViewController(viewController: initialViewController)
        }
    }
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = orderedViewControllers?.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = orderedViewControllers?[newIndex]
            scrollToViewController(viewController: nextViewController!, direction: direction)
        }
    }
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
        })
    }
}

// MARK: UIPageViewControllerDataSource

extension ImagePageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            return orderedViewControllers?.last
        }
        
        guard orderedViewControllers?.count ?? 0 > previousIndex else {
            return nil
        }
        
        return orderedViewControllers?[previousIndex]
    }
    
    func pageViewController(_ viewControllerBeforepageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers?.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers?.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers?.first
        }
        
        guard orderedViewControllersCount ?? 0 > nextIndex else {
            return nil
        }
        
        return orderedViewControllers![nextIndex]
    }
    
}
