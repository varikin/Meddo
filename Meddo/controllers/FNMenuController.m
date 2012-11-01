//
//  FNMeddoController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNMenuController.h"

@interface FNMenuController()

- (IBAction)handleMenuItem:(id)sender;
- (NSInteger)menuItemState:(FNHost *)host;

@end

@implementation FNMenuController

@synthesize statusMenu;
@synthesize statusItem;
@synthesize hosts;

- (id) initWithMenu:(NSMenu *)menu {
    self = [super init];
    if (self) {
        [self setStatusMenu:menu];
        hostsService = [FNHostsService sharedInstance];
        NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
        statusItem = [systemStatusBar statusItemWithLength:NSSquareStatusItemLength];
        [statusItem setMenu:statusMenu];
        [statusItem setTitle:@"M"];
        [statusItem setHighlightMode:YES];
        [self refreshMenu];
    }
    return self;
}

- (void) refreshMenu {
    [self setHosts:[hostsService read]];
    // Going backwards to insert at position 0
    // Allows preferences to be the last item.
    NSEnumerator *reversedHosts = [self.hosts reverseObjectEnumerator];
    for (FNHost *host in reversedHosts) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[host name]
                                                          action:@selector(handleMenuItem:)
                                                   keyEquivalent:@""];
        [menuItem setRepresentedObject:host];
        [menuItem setTarget:self];
        [menuItem setToolTip:[host shortDescription]];
        [menuItem setEnabled:YES];
        [menuItem setState:[self menuItemState:host]];

        [[self statusMenu] insertItem:menuItem atIndex:0];
    }
}

- (IBAction) handleMenuItem:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        FNHost *host = [sender representedObject];
        BOOL enabled = [host status] == HostEnabled;
        [host setEnabled:!enabled];
        [hostsService write:hosts];
        [sender setState:[self menuItemState:host]];
    }
}

- (NSInteger) menuItemState:(FNHost *)host {
    HostStatus status = [host status];
    if (status == HostDisabled) {
        return NSOffState;
    } else if (status == HostEnabled) {
        return NSOnState;
    } else {
        return NSMixedState;
    }
}

@end
