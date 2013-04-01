//
//  SimpleKeychainTests.m
//  Copyright (c) 2013 Daniel Reese. All rights reserved.
//

#import "SimpleKeychain.h"
#import <SenTestingKit/SenTestingKit.h>


@interface SimpleKeychainTests : SenTestCase
@end


@interface SimpleKeychain (UnitTests)
@property (nonatomic, strong) NSBundle *bundle;
+ (NSString *)stringFromErrorCode:(OSStatus)code;
@end


@implementation SimpleKeychainTests

- (void)setUp
{
    [super setUp];
    [SimpleKeychain sharedInstance].bundle = [NSBundle bundleForClass:[self class]];
	[SimpleKeychain sharedInstance].serviceName = nil;
	[[SimpleKeychain sharedInstance] removeAllStrings:nil];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

#pragma mark - Tests

- (void)testSharedInstanceShouldNotBeNil
{
	STAssertNotNil([SimpleKeychain sharedInstance], nil);
}

- (void)testSharedInstanceShouldAlwaysReturnSameObject
{
	STAssertEqualObjects([SimpleKeychain sharedInstance], [SimpleKeychain sharedInstance], nil);
}

- (void)testDefaultServiceNameShouldBeBundleIdentifier
{
	NSString *bid = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	STAssertEqualObjects([[SimpleKeychain sharedInstance] serviceName], bid, nil);
}

- (void)testChangingServiceNameShouldBeRememberd
{
	[SimpleKeychain sharedInstance].serviceName = @"danwazhere";
	STAssertEqualObjects([[SimpleKeychain sharedInstance] serviceName], @"danwazhere", nil);
}

- (void)testStringFromErrorCodeShouldReturnNilForUnknownCodes
{
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:1], nil, nil);
}

- (void)testStringFromErrorCodeShouldReturnCorrectStrings
{
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecSuccess], @"No error.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecUnimplemented], @"Function or operation not implemented.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecParam], @"One or more parameters passed to the function were not valid.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecAllocate], @"Failed to allocate memory.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecNotAvailable], @"No trust results are available.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecAuthFailed], @"Authorization/Authentication failed.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecDuplicateItem], @"The item already exists.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecItemNotFound], @"The item cannot be found.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecInteractionNotAllowed], @"Interaction with the Security Server is not allowed.", nil);
	STAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecDecode], @"Unable to decode the provided data.", nil);
}

- (void)testGettingValueWithNilKeyShouldThrowAnException
{
	STAssertThrows([[SimpleKeychain sharedInstance] stringForKey:nil error:nil], nil);
}

- (void)testDefaultValueOfMissingItemShouldBeNil
{
	STAssertNil([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil], nil);
}

- (void)testGettingValueOfMissingItemShouldReturnNotFoundError
{
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:&error];
	STAssertEquals([error code], errSecItemNotFound, nil);
}

- (void)testSettingValueShouldNotReturnError
{
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:&error];
	STAssertNil(error, [error localizedDescription]);
}

- (void)testSettingValueShouldSaveValue
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	STAssertEqualObjects([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil], @"testvalue", nil);
}

- (void)testGettingSavedValueShouldNotReturnError
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:&error];
	STAssertNil(error, [error localizedDescription]);
}

- (void)testResetShouldRemoveEverythingInKeychainItem
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] removeAllStrings:&error];
	STAssertNil(error, nil);
	STAssertNil([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil], nil);
}

@end
