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
@synthesize infoHeight;

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    
    if (_editing) {
        [self.infoHeight.animator setConstant:71.0];
    } else {
        [self.infoHeight.animator setConstant:54.0];
    }
}

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
        self.editing = NO;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.editing = NO;
    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.editing = NO;
}

@end
