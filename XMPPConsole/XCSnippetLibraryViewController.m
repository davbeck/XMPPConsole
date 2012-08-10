//
//  XCSnippetViewController.m
//  XMPPConsole
//
//  Created by David Beck on 8/5/12.
//  Copyright (c) 2012 DavidBeck. All rights reserved.
//

#import "XCSnippetLibraryViewController.h"

#import "XCSnippetController.h"
#import "XCSnippet.h"
#import "XCSnippetRowView.h"
#import "XCSnippetDetailViewController.h"


#define XCSnippetViewMaximumMovement 3.0


@interface XCSnippetLibraryViewController ()

@end

@implementation XCSnippetLibraryViewController
{
    BOOL _animateChanges;
    BOOL _popoverMoved;
    NSArrayController *_snippetsController;
    NSString *_selectedTag;
}

- (void)setTableView:(NSTableView *)tableView
{
    _tableView = tableView;
    
    [_tableView registerForDraggedTypes:[XCSnippet readableTypesForPasteboard:nil]];
    [_tableView setDraggingSourceOperationMask:NSDragOperationCopy | NSDragOperationGeneric | NSDragOperationMove forLocal:NO];
    
    [_tableView setDoubleAction:@selector(showInfo:)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"arrangedObjects"] && object == _snippetsController) {
        if (_animateChanges) {
            [self.tableView beginUpdates];
            
            switch ([change[NSKeyValueChangeKindKey] unsignedIntegerValue]) {
                case NSKeyValueChangeInsertion: {
                    [self.tableView insertRowsAtIndexes:change[NSKeyValueChangeIndexesKey] withAnimation:NSTableViewAnimationSlideDown | NSTableViewAnimationEffectFade];
                    
                    break;
                } case NSKeyValueChangeRemoval: {
                    [self.tableView removeRowsAtIndexes:change[NSKeyValueChangeIndexesKey] withAnimation:NSTableViewAnimationSlideLeft | NSTableViewAnimationEffectFade];
                    
                    break;
                } default: {
                    [self.tableView reloadData];
                    
                    break;
                }
            }
            
            [self.tableView endUpdates];
        } else {
            [self _updateFilter];
        }
	} else if ([keyPath isEqualToString:@"tags"] && object == [XCSnippetController sharedController]) {
        if (_selectedTag != nil) {
            [self.filterPopUp selectItemAtIndex:[self.filterPopUp indexOfItemWithRepresentedObject:_selectedTag]];
        }
        [self _updateFilter];
    } else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    _searchTerm = searchTerm;
    
    [self _updateFilter];
}

- (void)_updateFilter
{
    NSMutableArray *predicates = [NSMutableArray new];
    
    if (self.searchTerm.length > 0) {
        [predicates addObject:[NSPredicate predicateWithFormat:@"title CONTAINS[dc] %@ OR summary CONTAINS[dc] %@ OR body CONTAINS[dc] %@ OR ANY tags CONTAINS[dc] %@", self.searchTerm, self.searchTerm, self.searchTerm, self.searchTerm]];
    }
    
    switch (self.filterPopUp.selectedTag) {
        case XCSnippetIQTag: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"elementName LIKE[c] 'iq'"]];
            
            break;
        } case XCSnippetMessageTag: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"elementName LIKE[c] 'message'"]];
            
            break;
        } case XCSnippetPresenceTag: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"elementName LIKE[c] 'presence'"]];
            
            break;
        } case XCSnippetOtherTag: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"NOT elementName IN[c] %@", @[ @"iq", @"message", @"presence" ]]];
            
            break;
        } case XCSnippetTagTag: {
            [predicates addObject:[NSPredicate predicateWithFormat:@"ANY tags LIKE[cd] %@", self.filterPopUp.selectedItem.representedObject]];
            
            break;
        } default: {
            
            break;
        }
    }
    
    _snippetsController.filterPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}


#pragma mark - Initialization

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (nibNameOrNil == nil) {
        nibNameOrNil = @"XCSnippetLibraryViewController";
    }
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _animateChanges = YES;
        
        _snippetsController = [[NSArrayController alloc] init];
        [_snippetsController bind:@"content" toObject:[XCSnippetController sharedController] withKeyPath:@"snippets" options:nil];
        [_snippetsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
        
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"tags" options:0 context:NULL];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _animateChanges = YES;
        
        _snippetsController = [[NSArrayController alloc] init];
        [_snippetsController bind:@"content" toObject:[XCSnippetController sharedController] withKeyPath:@"snippets" options:nil];
        [_snippetsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
        
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"tags" options:0 context:NULL];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _animateChanges = YES;
        
        _snippetsController = [[NSArrayController alloc] init];
        [_snippetsController bind:@"content" toObject:[XCSnippetController sharedController] withKeyPath:@"snippets" options:nil];
        [_snippetsController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
        
        [[XCSnippetController sharedController] addObserver:self forKeyPath:@"tags" options:0 context:NULL];
    }
    return self;
}


#pragma mark - Actions

- (IBAction)insertSelectedSnippet:(id)sender
{
    XCSnippet *snippet = [[[self.tableView rowViewAtRow:self.tableView.selectedRow makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    if ([self.defaultDestination respondsToSelector:@selector(insertText:)] && snippet.body != nil) {
        [self.defaultDestination insertText:snippet.body];
    }
}

- (IBAction)showInfo:(id)sender
{
    NSInteger selectedRow = [self.tableView selectedRow];
    
    if (selectedRow != -1) {
        [self.tableView scrollRowToVisible:selectedRow];
        NSView *rowView = [self.tableView rowViewAtRow:selectedRow makeIfNecessary:YES];
        
        self.infoPopover.contentViewController.representedObject = _snippetsController.arrangedObjects[selectedRow];
        [self.infoPopover showRelativeToRect:rowView.bounds ofView:rowView preferredEdge:NSMaxXEdge];
    }
    
    [self.infoPopover.contentViewController.view.window makeFirstResponder:self.infoPopover];
}

- (IBAction)addOrRemoveSnippet:(NSSegmentedControl *)sender
{
    if (sender.selectedSegment == 0) {//add
        [self addSnippet:sender];
    } else if (sender.selectedSegment == 1) {//remove
        [self removeSnippet:sender];
    }
}

- (IBAction)addSnippet:(id)sender
{
    _popoverMoved = YES;
    
    XCSnippet *oldSnippet = self.infoViewController.representedObject;
    if (oldSnippet != nil && oldSnippet.title.length == 0 && oldSnippet.summary.length == 0 && oldSnippet.body.length == 0) {
        return;
    }
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        XCSnippet *snippet = [XCSnippet snippetWithTitle:nil summary:nil body:nil];
        
        _selectedTag = nil;
        [self.filterPopUp selectItemWithTag:XCSnippetAllTag];
        [self _updateFilter];
        [self.tableView reloadData];
        
        NSUInteger newIndex = [XCSnippetController sharedController].countOfSnippets;
        [[XCSnippetController sharedController] insertObject:snippet inSnippetsAtIndex:newIndex];
        
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
    } completionHandler:^{
        [self showInfo:self];
        self.infoViewController.editing = YES;
    }];
}

- (IBAction)removeSnippet:(id)sender
{
    [self.tableView beginUpdates];
    NSIndexSet *indexes = [self.tableView selectedRowIndexes];
    [[[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"] removeObjectsAtIndexes:indexes];
    [self.tableView endUpdates];
}

- (IBAction)tableViewClicked:(id)sender
{
    NSPoint startLocation = [NSEvent mouseLocation];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void){
        NSPoint currentLocation = [NSEvent mouseLocation];
        
        if (!fabs(startLocation.x - currentLocation.x) < XCSnippetViewMaximumMovement && fabs(startLocation.y - currentLocation.y) < XCSnippetViewMaximumMovement) {
            [self showInfo:self];
        }
    });
}

- (IBAction)changeScope:(NSPopUpButton *)sender
{
    _selectedTag = sender.selectedItem.representedObject;
    
    [self _updateFilter];
}


#pragma mark - NSPopoverDelegate

- (BOOL)popoverShouldClose:(NSPopover *)popover
{
    if (_popoverMoved) {
        [popover.contentViewController.view.window makeFirstResponder:popover];
        
        _popoverMoved = NO;
        return NO;
    }
    return YES;
}

- (void)popoverWillClose:(NSNotification *)notification
{
    //make sure the text fields commit their edit
    NSPopover *popover = notification.object;
    [popover.contentViewController.view.window makeFirstResponder:popover];
    
    self.infoViewController.editing = NO;
    
    XCSnippet *snippet = self.infoViewController.representedObject;
    if (snippet.title.length == 0 && snippet.summary.length == 0 && snippet.body.length == 0) {
        self.infoViewController.representedObject = nil;
        [[[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"] removeObject:snippet];
    }
}


#pragma mark - NSTableViewDelegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_snippetsController.arrangedObjects count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return _snippetsController.arrangedObjects[row];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[XCSnippetRowView alloc] init];
}

- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
    if (self.tableView.selectedRow == -1) {
        [self.infoPopover close];
    } else if (self.infoPopover.shown) {
        XCSnippet *snippet = self.infoViewController.representedObject;
        
        if (snippet.title.length == 0 && snippet.summary.length == 0 && snippet.body.length == 0) {
            self.infoViewController.representedObject = nil;
            [[[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"] removeObject:snippet];
        }
        
        [self showInfo:self];
        _popoverMoved = YES;
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if (self.tableView.selectedRow == -1) {
        [self.infoPopover close];
    }
}


#pragma mark - Dragging

- (id <NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    XCSnippet *snippet = [[[tableView rowViewAtRow:row makeIfNecessary:YES] viewAtColumn:0] objectValue];
    
    return snippet;
}

- (void)tableView:(NSTableView *)tableView updateDraggingItemsForDrag:(id<NSDraggingInfo>)draggingInfo
{
    NSTableCellView *snippetCell = [tableView makeViewWithIdentifier:@"Snippet" owner:self];
    NSRect cellFrame = NSMakeRect(0.0, 0.0, [[tableView tableColumns][0] width], tableView.rowHeight);
    
    [draggingInfo enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[ [XCSnippet class] ] searchOptions:nil usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
         XCSnippet *snippet = draggingItem.item;
         
         if (snippet.title != nil || snippet.summary != nil) {
             draggingItem.draggingFrame = cellFrame;
             draggingItem.imageComponentsProvider = ^(void) {
                 snippetCell.objectValue = draggingItem.item;
                 snippetCell.frame = cellFrame;
                 return [snippetCell draggingImageComponents];
             };
         }
     }];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    //this disables the "drop on" behavior
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove];
    
    if (info.draggingSource == tableView) {
        return NSDragOperationMove;
    }
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    __block NSUInteger insertionIndex = row;
    NSMutableArray *snippets = [[XCSnippetController sharedController] mutableArrayValueForKey:@"snippets"];
    
    _animateChanges = NO;
    [tableView beginUpdates];
    
    [info enumerateDraggingItemsWithOptions:0 forView:tableView classes:@[ [XCSnippet class] ] searchOptions:nil usingBlock:
     ^(NSDraggingItem *draggingItem, NSInteger idx, BOOL *stop) {
         XCSnippet *snippet = draggingItem.item;
         
         if (info.draggingSource == tableView) {
             NSUInteger oldIndex = [_snippetsController.arrangedObjects indexOfObject:snippet];
             if (oldIndex < insertionIndex) {
                 insertionIndex--;
             }
             
             [snippets removeObject:snippet];
             [snippets insertObject:snippet atIndex:insertionIndex];
             NSUInteger newIndex = [_snippetsController.arrangedObjects indexOfObject:snippet];
             
             [tableView moveRowAtIndex:oldIndex toIndex:newIndex];
         } else {
             snippet.title = NSLocalizedString(@"My XML Snippet", nil);
             
             [snippets insertObject:snippet atIndex:insertionIndex];
             NSUInteger newIndex = [_snippetsController.arrangedObjects indexOfObject:snippet];
             
             if (newIndex != NSNotFound) {
                 [tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:newIndex] withAnimation:NSTableViewAnimationSlideDown | NSTableViewAnimationEffectFade];
                 
                 [tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:newIndex] byExtendingSelection:NO];
                 [self showInfo:nil];
                 self.infoViewController.editing = YES;
             } else {
                 [tableView reloadData];
             }
         }
         
         insertionIndex++;
     }];
    
    [tableView endUpdates];
    _animateChanges = YES;
    
    return YES;
}

@end
