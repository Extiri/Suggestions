//
//  CodeInteraction.m
//  CMCompletionFeatureExperimental
//
//  Created by Wiktor Wójcik on 20/08/2021.
//

// Thank you Neha Gupta very much!
// I was unable to understand Accesibility API and you helped me a lot!
// https://macdevelopers.wordpress.com/2014/02/05/how-to-get-selected-text-and-its-coordinates-from-any-system-wide-application-using-accessibility-api/comment-page-1/

#import <Cocoa/Cocoa.h>
#import "CodeInteraction.h"
#import <Accessibility/Accessibility.h>
#import "UIElementUtilities.h"
#import <CodeMenuSuggestions-Swift.h>

@implementation CodeInfo
NSString *query;
NSInteger *insertionPointerLine;
NSRect frame;
@end

@implementation CodeInteraction
- (BOOL)isAllowed:(NSString*)name {
	return [Settings isAllowed:[name lowercaseString]];
}

- (BOOL)getCodeInfo:(CodeInfo*)codeInfo {
	NSString *app = NSWorkspace.sharedWorkspace.frontmostApplication.localizedName;
	if ([self isAllowed:app]) {
		AXUIElementRef mainElement = AXUIElementCreateApplication(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier);
		AXUIElementRef codeArea = NULL;
		AXError error = AXUIElementCopyAttributeValue(mainElement, kAXFocusedUIElementAttribute, (CFTypeRef *)&codeArea);
		
		if (error == kAXErrorSuccess) {
			if ([[UIElementUtilities valueOfAttribute:@"AXRole" ofUIElement:codeArea]  isEqual: @"AXTextArea"]) {
				NSString *code = [UIElementUtilities valueOfAttribute:@"AXValue" ofUIElement:codeArea];
				NSInteger insertionPointerLine = [[UIElementUtilities valueOfAttribute:@"AXInsertionPointLineNumber" ofUIElement:codeArea] integerValue];
				
				codeInfo.insertionPointerLine = insertionPointerLine;
				NSArray<NSString *> *lines = [code componentsSeparatedByString:@"\n"];
				
				if (!(0 <= insertionPointerLine && insertionPointerLine < [lines count])) {
					codeInfo.query = @" ";
					return false;
				}
				
				NSString *line = lines[insertionPointerLine];
				NSArray<NSString *> *seperated = [line componentsSeparatedByString:@"§§"];
				
				AXValueRef selectedRangeValue = NULL;
				AXError getSelectedRangeError = AXUIElementCopyAttributeValue(codeArea, kAXSelectedTextRangeAttribute, (CFTypeRef *)&selectedRangeValue);
				if (getSelectedRangeError == kAXErrorSuccess) {
					CFRange selectedRange;
					AXValueGetValue(selectedRangeValue, kAXValueCFRangeType, &selectedRange);
					AXValueRef selectionBoundsValue = NULL;
					AXError getSelectionBoundsError = AXUIElementCopyParameterizedAttributeValue(codeArea, kAXBoundsForRangeParameterizedAttribute, selectedRangeValue, (CFTypeRef *)&selectionBoundsValue);
					CFRelease(selectedRangeValue);
					if (getSelectionBoundsError == kAXErrorSuccess) {
						CGRect selectionBounds;
						AXValueGetValue(selectionBoundsValue, kAXValueCGRectType, &selectionBounds);
						codeInfo.frame = NSRectFromCGRect(selectionBounds);
					} else {
						return false;
					}
					if (selectionBoundsValue != NULL) CFRelease(selectionBoundsValue);
				} else {
					return false;
				}
				
				if ([seperated count] == 2) {
					codeInfo.query = seperated[1];
					return true;
				} else {
					codeInfo.query = @" ";
					return false;
				}
			}
		}
	}
	
	return false;
};

- (void)useCode:(NSString *)snippet withFrame:(NSRect)frame {
	NSString *app = NSWorkspace.sharedWorkspace.frontmostApplication.localizedName;
	if ([self isAllowed:app]) {
		AXUIElementRef mainElement = AXUIElementCreateApplication(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier);
		AXUIElementRef codeArea = NULL;
		AXError error = AXUIElementCopyAttributeValue(mainElement, kAXFocusedUIElementAttribute, (CFTypeRef *)&codeArea);
		
		if (error == kAXErrorSuccess) {
			if ([[UIElementUtilities valueOfAttribute:@"AXRole" ofUIElement:codeArea]  isEqual: @"AXTextArea"]) {
				NSString *code = [UIElementUtilities valueOfAttribute:@"AXValue" ofUIElement:codeArea];
				NSInteger insertionPointerLine = [[UIElementUtilities valueOfAttribute:@"AXInsertionPointLineNumber" ofUIElement:codeArea] integerValue];
				NSMutableArray<NSString *> *lines = (NSMutableArray<NSString *>*)[code componentsSeparatedByString:@"\n"];
				NSString *line = lines[insertionPointerLine];
				NSMutableArray<NSString *> *newLineSeperated = (NSMutableArray<NSString *>*)[line componentsSeparatedByString:@"§§"];
				newLineSeperated[1] = snippet;
				lines[insertionPointerLine] = [newLineSeperated componentsJoinedByString:@""];
				NSString *newCode = [lines componentsJoinedByString:@"\n"];
				[UIElementUtilities setStringValue:newCode forAttribute:@"AXValue" ofUIElement:codeArea];
			}
		}
	}
}

@end

