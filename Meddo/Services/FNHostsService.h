//
//  FNHostsController.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Service to handle reading and writing to the /etc/hosts file.
 * Note that writing to the file does require administrator access 
 * which is prompted for when writing.
 */
@interface FNHostsService : NSObject

/*
 * Returns the Hosts Serivce singleton
 */
+ (FNHostsService *)sharedInstance;

/*
 * Register a listener for when the hosts file is updated.
 * The block will be called when the host file is updated.
 */
-(void)registerListener:(void (^)(NSArray *))listener;

/*
 * Update the hosts file with the given list.
 */
-(void)update:(NSArray *)hosts;

@end
