//
//  FNAppDelegate.m
//  Meddo
//
//  Created by John Shimek on 9/2/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//
#import "MeddoAppDelegate.h"
#import "FNHostsService.h"

@implementation MeddoAppDelegate

@synthesize menu;
@synthesize menuController;
@synthesize preferences;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void) awakeFromNib {
    [self setMenuController:[[FNMenuController alloc] initWithMenu:menu]];
}

- (IBAction)openPreferences:(id)sender {
    [preferences makeKeyAndOrderFront:sender];
}


@end
