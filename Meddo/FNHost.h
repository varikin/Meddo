//
//  FNHost.h
//  Meddo
//
//  Created by John Shimek on 9/3/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNHost : NSObject

@property (nonatomic) NSString *_comment;
@property (nonatomic) NSString *_address;
@property (nonatomic) NSMutableArray *_hostnames;

@end
