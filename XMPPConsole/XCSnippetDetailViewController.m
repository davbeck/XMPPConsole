//
//  XCSnippetDetailViewController.m
//  XMPPConsole
//
//  Created by David Beck on 8/6/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetDetailViewController.h"

#import "NSFont+CodeFont.h"


@interface XCSnippetDetailViewController ()

@end

@implementation XCSnippetDetailViewController

- (void)setBodyView:(NSTextView *)bodyView
{
    _bodyView = bodyView;
    
    [_bodyView setFont:[NSFont codeFont]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibNameOrNil == nil) {
        nibNameOrNil = @"XCSnippetDetailViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

@end
