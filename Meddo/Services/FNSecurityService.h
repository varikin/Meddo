//
//  FNSecurityService.h
//  Meddo
//
//  Created by John Shimek on 9/14/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FNSecurityService : NSObject

+ (FNSecurityService *) sharedInstance;
- (void) ensureHelperInstalled;
- (void) installHelper;
- (void) uninstallHelper;
- (bool) isCurrentVersion;
- (NSInteger) getInstalledHelperVersion;
- (NSInteger) getCurrentHelperVersion;

@end
