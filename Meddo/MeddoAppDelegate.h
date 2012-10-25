//
//  FNAppDelegate.h
//  Meddo
//
//  Created by John Shimek on 9/2/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FNMenuController.h"

@interface MeddoAppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, retain) IBOutlet NSMenu *menu;
@property (nonatomic, retain) FNMenuController *menuController;
@property (nonatomic, retain) IBOutlet NSWindow *preferences;

- (IBAction)openPreferences:(id)sender;

@end


