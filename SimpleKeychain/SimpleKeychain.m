//
//  SimpleKeychain.m
//  Copyright (c) 2013 Daniel Reese. All rights reserved.
//
//  See the following pages for background information:
//  http://developer.apple.com/library/ios/#samplecode/GenericKeychain/
//  https://gist.github.com/dhoerl/1170641
//  http://stackoverflow.com/questions/4891562/ios-keychain-services-only-specific-values-allowed-for-ksecattrgeneric-key
//  http://stackoverflow.com/questions/3558252/ios-keychain-security
//  http://software-security.sans.org/blog/2011/01/05/using-keychain-to-store-passwords-ios-iphone-ipad/
//  http://www.raywenderlich.com/6603/basic-security-in-ios-5-tutorial-part-2
//  http://maniacdev.com/2011/08/open-source-ios-keychain-wrapper-for-easily-securing-user-data-for-your-app/
//  http://useyourloaf.com/blog/2010/03/29/simple-iphone-keychain-access.html
//  http://useyourloaf.com/blog/2010/04/03/keychain-group-access.html
//  http://useyourloaf.com/blog/2010/04/28/keychain-duplicate-item-when-adding-password.html
//

#import "SimpleKeychain.h"

#import <Security/Security.h>


// This property is used only for unit testing.
@interface SimpleKeychain ()
@property (nonatomic, strong) NSBundle *bundle;
@end


@implementation SimpleKeychain

+ (instancetype)sharedInstance
{
	static SimpleKeychain *sharedInstance;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		sharedInstance = [[SimpleKeychain alloc] init];
	});
	return sharedInstance;
}

- (NSString *)serviceName
{
	if (!_serviceName) {
		_serviceName = [self.bundle bundleIdentifier];
	}
	return _serviceName;
}

- (void)setString:(NSString *)value forKey:(NSString *)key error:(NSError **)error
{
	NSParameterAssert(key != nil);
	NSParameterAssert(value != nil);
	
	// Get parameters.
	NSMutableDictionary *query = [self dictionaryForKey:key];
	
	// Try to lookup an existing entry.
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
	if (status == errSecSuccess) {
		// Update the existing entry.
		NSDictionary *attributesToUpdate = @{(__bridge id)kSecValueData: [value dataUsingEncoding:NSUTF8StringEncoding]};
		status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
	}
	else if (status == errSecItemNotFound) {
		// Remove request to return data.
		[query removeObjectForKey:(__bridge id)kSecReturnData];
		
		// Add new entry.
		[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
		status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
	}
	
	// Handle errors.
	if (error && status != errSecSuccess) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [SimpleKeychain stringFromErrorCode:status]};
		*error = [NSError errorWithDomain:@"SimpleKeychain" code:status userInfo:userInfo];
	}
}

- (NSString *)stringForKey:(NSString *)key error:(NSError **)error
{
	NSParameterAssert(key != nil);
	
	// Get parameters.
	NSMutableDictionary *query = [self dictionaryForKey:key];
	
	// Retrieve data from keychain item.
	CFTypeRef dataFromKeychain = nil;
	OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &dataFromKeychain);
	
	// If found, convert data to string.
	NSString *result = nil;
	if (status == errSecSuccess) {
		result = [[NSString alloc] initWithData:(__bridge NSData *)dataFromKeychain encoding:NSUTF8StringEncoding];
	}
	
	// Handle errors.
	if (error && status != errSecSuccess) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [SimpleKeychain stringFromErrorCode:status]};
		*error = [NSError errorWithDomain:@"SimpleKeychain" code:status userInfo:userInfo];
	}
	
	return result;
}

- (void)removeStringForKey:(NSString *)key error:(NSError **)error
{
	NSParameterAssert(key != nil);
	
	// Get parameters.
	NSMutableDictionary *query = [self dictionaryForKey:key];
	
	// Delete keychain item.
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	
	// Handle errors.
	if (error && status != errSecSuccess) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [SimpleKeychain stringFromErrorCode:status]};
		*error = [NSError errorWithDomain:@"SimpleKeychain" code:status userInfo:userInfo];
	}
}

- (void)removeAllStrings:(NSError **)error
{
	// Get parameters. Do not include key so that items in the keychain will be deleted.
	NSMutableDictionary *query = [self dictionaryForKey:nil];
	
	// Delete keychain item.
	OSStatus status = SecItemDelete((__bridge CFDictionaryRef)query);
	
	// Handle errors.
	if (error && status != errSecSuccess) {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [SimpleKeychain stringFromErrorCode:status]};
		*error = [NSError errorWithDomain:@"SimpleKeychain" code:status userInfo:userInfo];
	}
}

#pragma mark - Helper Methods

+ (NSString *)stringFromErrorCode:(OSStatus)code
{
	switch (code) {
		case errSecSuccess:               return @"No error."; break;
		case errSecUnimplemented:         return @"Function or operation not implemented."; break;
		case errSecParam:                 return @"One or more parameters passed to the function were not valid."; break;
		case errSecAllocate:              return @"Failed to allocate memory."; break;
		case errSecNotAvailable:          return @"No trust results are available."; break;
		case errSecAuthFailed:            return @"Authorization/Authentication failed."; break;
		case errSecDuplicateItem:         return @"The item already exists."; break;
		case errSecItemNotFound:          return @"The item cannot be found."; break;
		case errSecInteractionNotAllowed: return @"Interaction with the Security Server is not allowed."; break;
		case errSecDecode:                return @"Unable to decode the provided data."; break;
		default:                          return nil; break;
	}
}

- (NSMutableDictionary *)dictionaryForKey:(NSString *)key
{
	NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
	
	// The type of object being stored.
	[query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	
	// The service and account are used to uniquely identifier a keychain item.
	[query setObject:self.serviceName forKey:(__bridge id)kSecAttrService];
	if (key) {
		[query setObject:key forKey:(__bridge id)kSecAttrAccount];
	}
	
	// Used when searching to request the keychain item be returned.
	[query setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	
	// Used when adding to request the keychain item be accessible only when the user is logged in.
	[query setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
	
	return query;
}

#pragma mark - Unit Testing

- (NSBundle *)bundle
{
	// Unit tests should set this property before using the object.
	if (!_bundle) {
		_bundle = [NSBundle mainBundle];
	}
	return _bundle;
}

@end
