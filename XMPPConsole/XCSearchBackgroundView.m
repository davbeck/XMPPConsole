//
//  XCSearchBackgroundView.m
//  XMPPConsole
//
//  Created by David Beck on 8/9/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSearchBackgroundView.h"

@implementation XCSearchBackgroundView

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *backgroundImage = [NSImage imageNamed:@"SearchBackground"];
    [backgroundImage drawInRect:self.bounds fromRect:NSMakeRect(0.0, 0.0, backgroundImage.size.width, backgroundImage.size.height) operation:NSCompositeSourceOver fraction:1.0];
}

@end
