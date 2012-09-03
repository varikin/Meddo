//
//  FNHost.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNHost : NSObject

@property (nonatomic, retain) NSString *_comment;
@property (nonatomic, retain) NSString *_address;
@property (nonatomic, retain) NSMutableArray *_hostnames;
@property (nonatomic) BOOL _enabled;

@end
