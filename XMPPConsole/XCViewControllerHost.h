//
//  XCViewControllerHost.h
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XCViewControllerHost : NSView

@property (nonatomic, strong) IBOutlet NSViewController *contentViewController;

@end
