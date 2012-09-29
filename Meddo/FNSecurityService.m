//
//  FNSecurityService.m
//  Meddo
//
//  Created by John Shimek on 9/14/12.
//  Copyright (c) 2012 Fictitious Nonsense. All rights reserved.
//

#import "FNSecurityService.h"
#import <ServiceManagement/ServiceManagement.h>
#import <Security/Authorization.h>

@implementation FNSecurityService

- (void) blessHelper {
    BOOL result = NO;
    
	AuthorizationItem authItem		= { kSMRightBlessPrivilegedHelper, 0, NULL, 0 };
	AuthorizationRights authRights	= { 1, &authItem };
	AuthorizationFlags flags		=	kAuthorizationFlagDefaults				|
                                        kAuthorizationFlagInteractionAllowed	|
                                        kAuthorizationFlagPreAuthorize			|
                                        kAuthorizationFlagExtendRights;
    
	AuthorizationRef authRef = NULL;
    CFErrorRef error = NULL;
	
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, &authRef);
	if (status == errAuthorizationSuccess) {
		result = SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)@"com.fictitiousnonsense.MeddoHelper", authRef, &error);
	} else {
        NSLog(@"Failed to authorize");
	}
    
    if (error != NULL) {
        NSLog(@"Error: %@", error);
    } else {
        NSLog(@"I think it worked");
    }
}

- (void)sendMessage:(NSString *)message {
    NSLog(@"Message to send: %@", message);
}


@end
