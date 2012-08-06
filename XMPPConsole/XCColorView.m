//
//  XCColorView.m
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCColorView.h"

@implementation XCColorView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [NSColor controlColor];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.backgroundColor = [NSColor controlColor];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor setFill];
    
    [NSBezierPath fillRect:dirtyRect];
}

@end
