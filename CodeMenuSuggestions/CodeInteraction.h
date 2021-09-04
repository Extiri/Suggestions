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
@property (nonatomic) NSRect frame;
@end

@interface CodeInteraction : NSObject { }
@property (nonatomic) NSMutableArray * _Nonnull allowlist;
- (BOOL)getCodeInfo:(CodeInfo*_Nonnull)codeInfo;
- (void)useCode:(NSString *_Nonnull)snippet withFrame:(NSRect)frame;
@end

#endif /* FocusedElementInfo_h */
