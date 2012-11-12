//
//  FNAppDelegate.m
//  Meddo
//
//  Created by John Shimek on 9/2/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//
#import "MeddoAppDelegate.h"

@implementation MeddoAppDelegate

@synthesize menu;
@synthesize menuController;
@synthesize preferences;


#pragma mark Lifecycle

- (void)awakeFromNib {
    [self setMenuController:[[FNMenuController alloc] initWithMenu:menu]];
}

- (IBAction)openPreferences:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [preferences makeKeyAndOrderFront:sender];
}

- (IBAction)quit:(id)sender {
    [NSApp terminate:sender];
}

@end

