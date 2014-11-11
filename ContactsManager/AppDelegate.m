//
//  AppDelegate.m
//  ContactsManager
//
//  Created by Zeyue Chen on 2/4/14.
//  Copyright (c) 2014 Zeyue Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "AppDelegate.h"

@implementation AppDelegate
@synthesize logTextView;

/**
 * Initial
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [logTextView setEditable:NO];
}


#pragma mark Start Click Function
/**
 * Click Start Button
 */
- (IBAction) clickStart:(id)sender
{
    ABAddressBook *ab = [ABAddressBook addressBook];
    int changeCountPinyin = 0, changeCountPhoneNumber = 0;
    
    for (ABPerson *person in ab.people) {
        
        // get first and last name
        NSString *first = [person valueForProperty:kABFirstNameProperty];
        NSString *last = [person valueForProperty:kABLastNameProperty];
        if (![self isChinese:first] || ![self isChinese:last]) {
            // not Chinese, continue
            continue;
        }
        
        // check if first and last Pinyin already exists
        BOOL needSet = NO;
        NSString *firstPinyin, *lastPinyin;
        if (last) {
            lastPinyin = [self phonetic:last];
            if (![[person valueForProperty:kABLastNamePhoneticProperty] isEqualToString:lastPinyin]) {
                [person setValue:lastPinyin forProperty:kABLastNamePhoneticProperty];
                needSet = YES;
            }
        }
        if (first) {
            firstPinyin = [self phonetic:first];
            if (![[person valueForProperty:kABFirstNamePhoneticProperty] isEqualToString:firstPinyin]) {
                [person setValue:firstPinyin forProperty:kABFirstNamePhoneticProperty];
                needSet = YES;
            }
        }
        NSString *name = [NSString stringWithFormat:@"%@%@", [self stringFilter:last], [self stringFilter:first]];
        NSString *pinyinName = [NSString stringWithFormat:@"%@%@", [self stringFilter:lastPinyin], [self stringFilter:firstPinyin]];
        
        // not exists or not the same
        if (needSet) {
            changeCountPinyin++;
            NSLog(@"[Pinyin] %@: %@", name, pinyinName);
            [self addLog:[NSString stringWithFormat:@"[Pinyin] %@: %@", name, pinyinName]];
        }
        
        /**
         Label List
         extern NSString * const kABPhoneProperty;          // Generic phone number - kABMultiStringProperty
         extern NSString * const kABPhoneWorkLabel;         // Work phone
         extern NSString * const kABPhoneHomeLabel;         // Home phone
         extern NSString * const kABPhoneiPhoneLabel;       // iPhone
         extern NSString * const kABPhoneMobileLabel;       // Cell phone
         extern NSString * const kABPhoneMainLabel;         // Main phone
         extern NSString * const kABPhoneHomeFAXLabel;      // FAX number
         extern NSString * const kABPhoneWorkFAXLabel;      // FAX number
         extern NSString * const kABPhonePagerLabel;        // Pager number
         */
    }
    NSLog(@"[Count] Pinyin Added: %d, Phone Number Formated: %d", changeCountPinyin, changeCountPhoneNumber);
    [self addLog:[NSString stringWithFormat:@"[Count] Pinyin Added: %d, Phone Number Formated: %d", changeCountPinyin, changeCountPhoneNumber]];
    [ab save];
}


#pragma mark UI
/**
 * UI
 * add one log to the logTextView
 */
- (void) addLog:(NSString *) text
{
    if ([[logTextView string] length] == 0) {
        [logTextView setString:text];
    } else {
        [logTextView setString:[NSString stringWithFormat:@"%@\n%@", [logTextView string], text]];
    }
}

#pragma mark Utils
/**
 * Utils - isChinese
 * check if the string is Chinese
 */
- (BOOL) isChinese: (NSString *) string
{
    if ([string length] == 0) {
        return NO;
    }
    
    unichar chinese = [string characterAtIndex:0];
    if (chinese >= 0x4e00 && chinese <= 0x9fff) {
        return YES;
    } else {
        return NO;
    }
}

/**
 * Utils - purify number
 * remove "+", "-", " ", " " and prefix "86"
 */
- (NSString *) purifyNumber:(NSString *) number
{
    NSString *newNumber = [number stringByReplacingOccurrencesOfString:@"+" withString:@""];
    newNumber = [newNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    newNumber = [newNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    newNumber = [newNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([newNumber hasPrefix:@"86"]) {
        newNumber = [newNumber substringFromIndex:2];
    }
    return newNumber;
}

/**
 * Utils - validate mobile phone number
 */
- (BOOL) validateMobile:(NSString *) mobile
{
    //Starts with prefix: 13， 15，18, contines with 8 digits
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


/**
 * Utils - avoid null
 */
- (NSString *) stringFilter:(NSString *) text
{
    if (text == NULL) {
        return @"";
    } else {
        return text;
    }
}

/**
 * Utils - transform Chinese to pinyin
 */
- (NSString *) phonetic:(NSString *)source
{
    NSMutableString *dest = [source mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)dest,
                      NULL,
                      kCFStringTransformMandarinLatin,
                      NO);
    return dest;
}

@end
