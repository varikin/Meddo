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
- (NSString *)formatName:(FNHost *)host;

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
    for (FNHost *host in self.hosts) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[self formatName:host]
                                                          action:@selector(handleMenuItem:)
                                                   keyEquivalent:@""];
        [menuItem setRepresentedObject:host];
        [menuItem setTarget:self];
        [menuItem setToolTip:[host shortDescription]];
        [menuItem setEnabled:YES];

        [[self statusMenu] addItem:menuItem];
    }
}

- (IBAction) handleMenuItem:(id)sender {
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        FNHost *host = [sender representedObject];
        BOOL enabled = [host status] == HostEnabled;
        [host setEnabled:!enabled];
        [hostsService write:hosts];
        [sender setTitle:[self formatName:host]];
    }
}

- (NSString *) formatName:(FNHost *)host {
    NSString *status;
    switch ([host status]) {
        case HostDisabled:
            status = @"x";
            break;
        case HostEnabled:
            status = @"*";
            break;
        case HostPartial:
            status = @"-";
            break;
        default:
            status = @"?";
            break;
    }
    return [NSString stringWithFormat:@"%@ %@", status, [host name]];
}




@end
