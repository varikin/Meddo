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
        NSLog(@"Holy shit, I think it worked");
    }
}

- (void)sendMessage:(NSString *)message {
    xpc_connection_t connection = xpc_connection_create_mach_service("com.fictitiousnonsense.MeddoHelper", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    
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
    
    xpc_object_t xpc_msg = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(xpc_msg, "request", [message UTF8String]);
    
    NSLog(@"Sending request: %@", message);
    
    xpc_connection_send_message_with_reply(connection, xpc_msg, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "reply");
        NSLog(@"Received response: %s.", response);
    });

}


@end
