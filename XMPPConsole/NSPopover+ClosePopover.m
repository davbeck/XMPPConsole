//
//  NSPopover+ClosePopover.m
//  XMPPConsole
//
//  Created by David Beck on 8/9/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "NSPopover+ClosePopover.h"

@implementation NSPopover (ClosePopover)

- (IBAction)closePopover:(id)sender
{
    [self performClose:sender];
}

@end
