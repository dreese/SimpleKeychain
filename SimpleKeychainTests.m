//
//  SimpleKeychainTests.m
//  Copyright (c) 2013 Daniel Reese <dan@danandcheryl.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "SimpleKeychain.h"
#import <XCTest/XCTest.h>


@interface SimpleKeychainTests : XCTestCase
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
	XCTAssertNotNil([SimpleKeychain sharedInstance]);
}

- (void)testSharedInstanceShouldAlwaysReturnSameObject
{
	XCTAssertEqualObjects([SimpleKeychain sharedInstance], [SimpleKeychain sharedInstance]);
}

- (void)testDefaultServiceNameShouldBeBundleIdentifier
{
	NSString *bid = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	XCTAssertEqualObjects([[SimpleKeychain sharedInstance] serviceName], bid);
}

- (void)testChangingServiceNameShouldBeRememberd
{
	[SimpleKeychain sharedInstance].serviceName = @"danwazhere";
	XCTAssertEqualObjects([[SimpleKeychain sharedInstance] serviceName], @"danwazhere");
}

- (void)testStringFromErrorCodeShouldReturnNilForUnknownCodes
{
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:1], nil);
}

- (void)testStringFromErrorCodeShouldReturnCorrectStrings
{
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecSuccess], @"No error.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecUnimplemented], @"Function or operation not implemented.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecParam], @"One or more parameters passed to the function were not valid.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecAllocate], @"Failed to allocate memory.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecNotAvailable], @"No trust results are available.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecAuthFailed], @"Authorization/Authentication failed.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecDuplicateItem], @"The item already exists.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecItemNotFound], @"The item cannot be found.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecInteractionNotAllowed], @"Interaction with the Security Server is not allowed.");
	XCTAssertEqualObjects([SimpleKeychain stringFromErrorCode:errSecDecode], @"Unable to decode the provided data.");
}

- (void)testGettingValueWithNilKeyShouldThrowAnException
{
	XCTAssertThrows([[SimpleKeychain sharedInstance] stringForKey:nil error:nil]);
}

- (void)testDefaultValueOfMissingItemShouldBeNil
{
	XCTAssertNil([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil]);
}

- (void)testGettingValueOfMissingItemShouldReturnNotFoundError
{
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:&error];
	XCTAssertEqual([error code], errSecItemNotFound);
}

- (void)testSettingValueShouldNotReturnError
{
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:&error];
	XCTAssertNil(error, @"%@", [error localizedDescription]);
}

- (void)testSettingValueShouldSaveValue
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	XCTAssertEqualObjects([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil], @"testvalue");
}

- (void)testGettingSavedValueShouldNotReturnError
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:&error];
	XCTAssertNil(error, @"%@", [error localizedDescription]);
}

- (void)testUpdatingExistingValueShouldReturnNewValue
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	[[SimpleKeychain sharedInstance] setString:@"testvalue1" forKey:@"testkey" error:nil];
	XCTAssertEqualObjects([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil], @"testvalue1");
}

- (void)testResetShouldRemoveEverythingInKeychainItem
{
	[[SimpleKeychain sharedInstance] setString:@"testvalue" forKey:@"testkey" error:nil];
	NSError *error = nil;
	[[SimpleKeychain sharedInstance] removeAllStrings:&error];
	XCTAssertNil(error);
	XCTAssertNil([[SimpleKeychain sharedInstance] stringForKey:@"testkey" error:nil]);
}

@end
