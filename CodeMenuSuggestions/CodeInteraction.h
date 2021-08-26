//
//  CodeInteraction.h
//  CMCompletionFeatureExperimental
//
//  Created by Wiktor Wójcik on 20/08/2021.
//

#ifndef CodeInteraction_h
#define CodeInteraction_h

#import <Foundation/Foundation.h>
#import "UIElementUtilities.h"
#import <Accessibility/Accessibility.h>

@interface CodeInfo : NSObject { }
@property (nonatomic, nonnull) NSString *query;
@property (nonatomic) NSInteger insertionPointerLine;
@end

@interface CodeInteraction : NSObject { }
@property (nonatomic) NSMutableArray *allowlist;
- (BOOL)getCodeInfo:(CodeInfo*)codeInfo;
- (void)useCode:(NSString *)snippet;
@end

#endif /* FocusedElementInfo_h */
