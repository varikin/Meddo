//
//  FNMeddoController.m
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNMenuController.h"

@implementation FNMenuController

@synthesize statusMenu;
@synthesize statusItem;
@synthesize hosts;

- (id) initWithMenu:(NSMenu *)menu {
    self = [super init];
    if (self) {
        [self setStatusMenu:menu];
        
        NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
        statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
        [statusItem setMenu:statusMenu];
        [statusItem setTitle:@"Meddo"];
        [statusItem setHighlightMode:YES];
        [self refreshMenu];
    }
    return self;
}

- (void) refreshMenu {
    [self setHosts:[[FNHostsService sharedInstance] read]];
    for (FNHost *host in self.hosts) {
        NSString *title = [[host comments] objectAtIndex:0];
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:title action:NULL keyEquivalent:@""];
        [[self statusMenu] addItem:menuItem];
    }
}



@end
