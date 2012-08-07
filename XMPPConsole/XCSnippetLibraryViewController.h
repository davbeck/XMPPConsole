//
//  XCSnippetViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XCSnippetDetailViewController;


@interface XCSnippetLibraryViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *defaultDestination;
@property (weak) IBOutlet NSPopover *infoPopover;
@property (unsafe_unretained) IBOutlet XCSnippetDetailViewController *infoViewController;

- (IBAction)insertSelectedSnippet:(id)sender;
- (IBAction)addSnippet:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)addOrRemoveSnippet:(NSSegmentedControl *)sender;
- (IBAction)removeSnippet:(id)sender;
- (IBAction)tableViewClicked:(id)sender;

@end
