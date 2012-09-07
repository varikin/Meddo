//
//  FNHostLine.h
//  Meddo
//
//  Created by John Shimek on 9/6/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNHostLine : NSObject

@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSArray *hostnames;
@property (nonatomic) BOOL enabled;

@end
