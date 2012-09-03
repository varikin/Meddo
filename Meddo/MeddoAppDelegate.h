//
//  FNAppDelegate.h
//  Meddo
//
//  Created by John Shimek on 9/2/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MeddoAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *_window;
@property (nonatomic, readonly) IBOutlet NSMenu *_statusMenu;
@property (nonatomic, readonly) NSStatusItem *_statusItem;



@end
