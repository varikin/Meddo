//
//  FNHostsController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <arpa/inet.h>
#import "FNHost.h"
#import "FNHostLine.h"

#define kHostFile @"/private/etc/hosts"


/*
 * Service to handle reading and writing to the /etc/hosts file.
 * Note that writing to the file does require administrator access 
 * which is prompted for when writing.
 */
@interface FNHostsService : NSObject

/*
 * Returns the Hosts Serivce singleton
 */
+ (FNHostsService *) sharedInstance;

/*
 * Writes an array of FNHosts to /etc/hosts
 * Since /etc/hosts/ is owned by root, prompts the user for administrator access via authopen
 */
- (void) write:(NSArray *)hosts;

/* 
 * Reads the /etc/hosts file into memory
 */
- (NSArray *) read;

@end
