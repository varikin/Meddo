//
//  FNHostsController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FNHost.h"

#define kHostFile @"/private/etc/hosts"


/*
 * Service to handle reading and writing to the /etc/hosts file.
 * Note that writing to the file does require administrator access 
 * which is prompted for when writing.
 */
@interface FNHostsService : NSObject


@property (retain) NSMutableArray *_hosts;

/*
 * Returns the Hosts Serivce singleton
 */
+ (FNHostsService *) sharedInstance;


/*
 * Writes the current hosts to /etc/hosts
 * Since /etc/hosts/ is owned by root, prompts the user for administrator access via authopen
 */
- (void) write;

/* 
 * Reads the /etc/hosts file into memory
 */
- (void) read;

@end
