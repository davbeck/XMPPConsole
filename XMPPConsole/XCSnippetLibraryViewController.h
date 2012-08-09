//
//  XCSnippetViewController.h
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XCSnippetDetailViewController;


#define XCSnippetAllTag 1
#define XCSnippetIQTag 2
#define XCSnippetMessageTag 3
#define XCSnippetPresenceTag 4
#define XCSnippetOtherTag 5
#define XCSnippetTagTag 6


@interface XCSnippetLibraryViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *defaultDestination;
@property (weak) IBOutlet NSPopover *infoPopover;
@property (unsafe_unretained) IBOutlet XCSnippetDetailViewController *infoViewController;
@property (nonatomic, weak) IBOutlet NSPopUpButton *filterPopUp;

@property (strong, readonly) NSArray *filteredSnippets;

- (IBAction)insertSelectedSnippet:(id)sender;
- (IBAction)addSnippet:(id)sender;
- (IBAction)showInfo:(id)sender;
- (IBAction)addOrRemoveSnippet:(NSSegmentedControl *)sender;
- (IBAction)removeSnippet:(id)sender;
- (IBAction)tableViewClicked:(id)sender;
- (IBAction)changeScope:(NSPopUpButton *)sender;

@end
