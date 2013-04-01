//
//  SimpleKeychain.h
//  Copyright (c) 2013 Daniel Reese. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleKeychain : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *serviceName; // Defaults to app bundle identifier.

- (void)setString:(NSString *)value forKey:(NSString *)key error:(NSError **)error;
- (NSString *)stringForKey:(NSString *)key error:(NSError **)error;
- (void)removeStringForKey:(NSString *)key error:(NSError **)error;
- (void)removeAllStrings:(NSError **)error;

@end
