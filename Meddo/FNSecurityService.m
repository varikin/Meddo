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

@interface FNSecurityService ()

- (void) installHelper;
- (void) uninstallHelper;
- (bool) isCurrentVersion;
- (NSInteger) getInstalledHelperVersion;
- (NSInteger) getCurrentHelperVersion;
- (NSInteger) getBundleVersion:(NSURL *)bundleUrl;

@end

@implementation FNSecurityService

+ (FNSecurityService *) sharedInstance {
    static FNSecurityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FNSecurityService alloc] init];
    });
    return sharedInstance;
}

- (void) sendMessage:(NSString *)message {
    [self installHelper];
    
    xpc_connection_t connection = xpc_connection_create_mach_service([kHelper UTF8String], NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
    if (!connection) {
        NSLog(@"Failed to create XPC connection.");
        return;
    }
    
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        
        if (type == XPC_TYPE_ERROR) {
            
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"XPC connection interupted.");
                
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"XPC connection invalid, releasing.");
                xpc_release(connection);
                
            } else {
                NSLog(@"Unexpected XPC connection error.");
            }
            
        } else {
            NSLog(@"Unexpected XPC connection event.");
        }
    });
    
    xpc_connection_resume(connection);
    
    xpc_object_t xpc_message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(xpc_message, "request", [message UTF8String]);
    
    NSLog(@"Sending request: %@", message);
    
    xpc_connection_send_message_with_reply(connection, xpc_message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "reply");
        NSLog(@"Received response: %s.", response);
    });
    
}

- (void) installHelper {
    
    if ([self isCurrentVersion]) {
        return; // Bug out, we have the current version
    }
    
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
		SMJobBless(kSMDomainSystemLaunchd, (CFStringRef)kHelper, authRef, &error);
	} else {
        NSLog(@"Failed to authorize the helper");
	}
    
    if (error != NULL) {
        NSLog(@"Error installing the helper: %@", error);
    } else {
        NSLog(@"Helper has been installed");
    }
}

- (void) uninstallHelper {
    NSLog(@"Uninstalling helper");
    // TODO: Implement
}

/*
 * Returns whether the installed helper is the current version.
 */
- (bool) isCurrentVersion {
    NSInteger installedVersion = [self getInstalledHelperVersion];
    NSInteger currentVersion = [self getCurrentHelperVersion];
    bool isCurrent = installedVersion == currentVersion;
    NSLog(@"Helper is current: %d", isCurrent);
    return isCurrent;
}

/*
 * Returns the version of the installed helper.
 * If the helper is not installed, returns 0 (Version 0)
 */
- (NSInteger) getInstalledHelperVersion {
    NSDictionary *installedHelperData = (__bridge NSDictionary *)SMJobCopyDictionary(kSMDomainSystemLaunchd, (CFStringRef)kHelper);
    NSString *installedHelperPath = [[installedHelperData objectForKey:@"ProgramArguments"] objectAtIndex:0];
    NSURL *installedHelperUrl = [NSURL fileURLWithPath:installedHelperPath];
    NSInteger installedVersion = [self getBundleVersion:installedHelperUrl];

    NSLog(@"Installed helper version: %ld", installedVersion);
    return installedVersion;
}

/*
 * Returns the current version of the helper in the app bundle
 */
- (NSInteger) getCurrentHelperVersion {
    NSURL *currentHelperUrl = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:kHelperLocation];
    NSInteger currentVersion = [self getBundleVersion:currentHelperUrl];
    
    NSLog(@"Current helper version: %ld", currentVersion);
    return currentVersion;
}

- (NSInteger) getBundleVersion:(NSURL *)bundleUrl {
    NSDictionary *plist = (__bridge NSDictionary*)CFBundleCopyInfoDictionaryForURL( (__bridge CFURLRef)bundleUrl);
    NSString *bundleVersion = [plist objectForKey:@"CFBundleVersion"];
    NSInteger version = [bundleVersion integerValue];
    return version;
}




@end
