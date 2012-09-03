//
//  FNHostsController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kHostFile = @"/private/etc/hosts"

@interface FNHostsService : NSObject

- (id) init;

- (NSArray *) getHosts;

- (void) write:(NSArray *)hosts;

@end
