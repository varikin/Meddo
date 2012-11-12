//
//  FNMeddoController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNHostsService.h"
#import "FNHost.h"

@interface FNMenuController : NSObject

@property (nonatomic, retain) NSMenu *statusMenu;
@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) NSArray *hosts;

- (id)initWithMenu:(NSMenu *) menu;
- (void)refreshMenu;

@end
