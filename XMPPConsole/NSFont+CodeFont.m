//
//  NSFont+CodeFont.m
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "NSFont+CodeFont.h"

@implementation NSFont (CodeFont)

+ (NSFont *)codeFont
{
    return [NSFont fontWithName:@"Menlo" size:14.0];
}

@end
