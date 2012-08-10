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

- (void)setEditing:(BOOL)editing
{
    _editing = editing;
    
    if (_editing) {
        self.editingView.hidden = NO;
        
        if (self.view.window == nil) {
            [self.infoHeight setConstant:71.0];
            [self.editingView setAlphaValue:1.0];
            [self.infoView setAlphaValue:0.0];
            self.infoView.hidden = YES;
        } else {
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                [self.infoHeight.animator setConstant:71.0];
                [self.editingView.animator setAlphaValue:1.0];
                [self.infoView.animator setAlphaValue:0.0];
            } completionHandler:^{
                self.infoView.hidden = YES;
            }];
        }
    } else {
        self.infoView.hidden = NO;
        
        if (self.view.window == nil) {
            [self.infoHeight setConstant:54.0];
            [self.editingView setAlphaValue:0.0];
            [self.infoView setAlphaValue:1.0];
            self.editingView.hidden = YES;
        } else {
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
                [self.infoHeight.animator setConstant:54.0];
                [self.editingView.animator setAlphaValue:0.0];
                [self.infoView.animator setAlphaValue:1.0];
            } completionHandler:^{
                self.editingView.hidden = YES;
            }];
        }
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
    
    self.editing = self.editing;
}

@end
