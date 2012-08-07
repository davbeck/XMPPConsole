//
//  XCViewControllerHost.m
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCViewControllerHost.h"

@implementation XCViewControllerHost
{
    NSArray *_contentRestraints;
}

- (void)setContentViewController:(NSViewController *)contentViewController
{
    if (_contentViewController != nil) {
        [self removeConstraints:_contentRestraints];
        _contentRestraints = nil;
        [_contentViewController.view removeFromSuperview];
    }
    
    if (_contentViewController != contentViewController) {
        _contentViewController = contentViewController;
    }
    
    //only show if we are being shown
    if (self.window != nil) {
        [self _addContentView];
    }
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow
{
    [self _addContentView];
}

- (void)_addContentView
{
    if (_contentViewController.view != nil && ![_contentViewController.view isDescendantOf:self]) {
        _contentViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_contentViewController.view];
        
        _contentRestraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[content]|" options:0 metrics:nil views:@{ @"content" : _contentViewController.view }];
        _contentRestraints = [_contentRestraints arrayByAddingObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[content]|" options:0 metrics:nil views:@{ @"content" : _contentViewController.view }]];
        
        [self addConstraints:_contentRestraints];
    }
}

@end
