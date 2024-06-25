#import <Cocoa/Cocoa.h>
#import "CodeInteraction.h"
#import <Accessibility/Accessibility.h>
#import "UIElementUtilities.h"
#import <Suggestions-Swift.h>

@implementation CodeInfo
NSString *query;
NSInteger *insertionPointerLine;
NSRect frame;
bool isAbbreviation;
@end

@implementation CodeInteraction
- (BOOL)isAllowed:(NSString*)name {
  return [Settings isAllowed:[name lowercaseString]];
}

- (BOOL)getCodeInfo:(CodeInfo*)codeInfo callsign:(NSString*) callsign {
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
        
        NSString *separator = NULL;
        
        if ([line containsString: [callsign stringByAppendingString:callsign]]) {
          codeInfo.isAbbreviation = false;
          separator = [callsign stringByAppendingString:callsign];
        } else {
          codeInfo.isAbbreviation = true;
          separator = callsign;
        }
        
        NSArray<NSString *> *seperated = [line componentsSeparatedByString:separator];
        
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

- (void)useCode:(NSString *)snippet isAbbreviation:(bool)isAbbreviation callsign:(NSString*)callsign {
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
        
        NSString *separator = NULL;
        
        if (!isAbbreviation) {
          separator = [callsign stringByAppendingString:callsign];
        } else {
          separator = callsign;
        }
      
        NSArray<NSString *> *newLineSeperated = (NSArray<NSString *>*)[line componentsSeparatedByString:separator];
        
        AXValueRef textValue = NULL;
        AXUIElementCopyAttributeValue(codeArea, kAXSelectedTextRangeAttribute , (CFTypeRef *)&textValue);
        
        CFRange range;
        range.location = 0;
        range.length = 0;
        
        AXValueGetValue(textValue, kAXValueTypeCFRange, &range);

        if ([app isEqual: @"Code"]) {
          range.location -= newLineSeperated[1].length;
          range.length += newLineSeperated[1].length;

          AXValueRef newValue = AXValueCreate(kAXValueTypeCFRange, &range);
          AXUIElementSetAttributeValue(codeArea, kAXSelectedTextRangeAttribute, newValue);
          
          [UIElementUtilities setStringValue:snippet forAttribute:kAXValueAttribute ofUIElement:codeArea];
        } else {
          range.location -= newLineSeperated[1].length + 2;
          range.length += newLineSeperated[1].length + 2;
          
          AXValueRef newValue = AXValueCreate(kAXValueTypeCFRange, &range);
          AXUIElementSetAttributeValue(codeArea, kAXSelectedTextRangeAttribute, newValue);
          
          [UIElementUtilities setStringValue:snippet forAttribute:kAXSelectedTextAttribute ofUIElement:codeArea];
        }
      }
    }
  }
}

@end
