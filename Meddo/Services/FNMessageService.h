//
//  FNMessageService.h
//  Meddo
//
//  Created by John Shimek on 10/18/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNMessageService : NSObject

+ (FNMessageService *)sharedInstance;
- (void)sendMessage:(NSString *)message;

@end
