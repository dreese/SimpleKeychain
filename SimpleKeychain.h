//
//  SimpleKeychain.h
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

#import <Foundation/Foundation.h>


@interface SimpleKeychain : NSObject

/**
 The service name used to store and retrieve in the system keychain. The default value is the app bundle identifier.
 */
@property (nonatomic, strong) NSString *serviceName;

/**
 Returns the singleton SimpleKeychain instance.
 
 @return The singleton SimpleKeychain instance.
 */
+ (instancetype)sharedInstance;

/**
 Stores the value for the given key. Optionally returns any error that occurs.
 
 @param value The string value to store.
 @param key The string key of the value to be stored.
 @param error An optional output parameter to capture any error that might occur.
 @return NO if an error occurred, YES otherwise.
 */
- (BOOL)setString:(NSString *)value forKey:(NSString *)key error:(NSError **)error;

/**
 Returns the value stored for the given key. Optionally returns any error that occurs.
 
 @param key The string key of the stored value.
 @param error An optional output parameter to capture any error that might occur.
 @return The string value stored for the given key, or nil if an error occurred.
 */
- (NSString *)stringForKey:(NSString *)key error:(NSError **)error;

/**
 Deletes the value for the given key. Optionally returns any error that occurs.
 
 @param key The string key of the stored value.
 @param error An optional output parameter to capture any error that might occur.
 @return NO if an error occurred, YES otherwise.
 */
- (BOOL)removeStringForKey:(NSString *)key error:(NSError **)error;

/**
 Deletes all values in the keychain for the current service name. Optionally returns any error that occurs.
 
 @param error An optional output parameter to capture any error that might occur.
 @return NO if an error occurred, YES otherwise.
 */
- (BOOL)removeAllStrings:(NSError **)error;

@end
