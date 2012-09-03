//
//  FNAppDelegate.m
//  Meddo
//
//  Created by John Shimek on 9/2/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "MeddoAppDelegate.h"

@implementation MeddoAppDelegate

@synthesize _window = window;
@synthesize _statusMenu = statusMenu;
@synthesize _statusItem = statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) awakeFromNib {
    NSStatusBar *systemStatusBar = [NSStatusBar systemStatusBar];
    statusItem = [systemStatusBar statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"Meddo"];
    [statusItem setHighlightMode:YES];
}

@end
