//
//  XCSnippetRowView.m
//  XMPPConsole
//
//  Created by David Beck on 8/4/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetRowView.h"


#define XCSnippetBackgroundRadius 5.0


@implementation XCSnippetRowView

- (NSBackgroundStyle)interiorBackgroundStyle
{
    return NSBackgroundStyleLight;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:self.bounds];
    
    NSRect selectionRect = NSInsetRect(self.bounds, 1.0, 1.0);
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:XCSnippetBackgroundRadius yRadius:XCSnippetBackgroundRadius];
    
    [[NSColor colorWithCalibratedWhite:0.949 alpha:1.000] setFill];
    
    [selectionPath fill];
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] setFill];
    [NSBezierPath fillRect:self.bounds];
    
    NSRect selectionRect = NSInsetRect(self.bounds, 1.5, 1.5);
    NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:XCSnippetBackgroundRadius yRadius:XCSnippetBackgroundRadius];
    
    if (self.emphasized) {
        [[NSColor colorWithCalibratedRed:0.812 green:0.871 blue:0.933 alpha:1.000] setFill];
        [[NSColor colorWithCalibratedRed:0.173 green:0.365 blue:0.690 alpha:1.000] setStroke];
    } else {
        [[NSColor colorWithCalibratedWhite:0.863 alpha:1.000] setFill];
        [[NSColor colorWithCalibratedWhite:0.373 alpha:1.000] setStroke];
    }
    
    [selectionPath fill];
    [selectionPath stroke];
}

- (void)drawSeparatorInRect:(NSRect)dirtyRect
{
    
}

@end
