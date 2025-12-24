#import <Cocoa/Cocoa.h>
#import "CodeInteraction.h"
#import <Accessibility/Accessibility.h>
#import "UIElementUtilities.h"
#import <Suggestions-Swift.h>

@implementation CodeInfo
@synthesize query;
@synthesize insertionPointerLine;
@synthesize frame;
@synthesize isAbbreviation;
@end

@implementation CodeInteraction
- (BOOL)isAllowed:(NSString*)name {
  return [Settings isAllowed:[name lowercaseString]];
}

- (BOOL)getCodeInfo:(CodeInfo*)codeInfo callsign:(NSString*) callsign {
  NSString *app = NSWorkspace.sharedWorkspace.frontmostApplication.localizedName;
  if ([self isAllowed:app]) {
    AXUIElementRef mainElement = AXUIElementCreateApplication(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier);
    AXUIElementRef focusedElement = NULL;
    AXError error = AXUIElementCopyAttributeValue(mainElement, kAXFocusedUIElementAttribute, (CFTypeRef *)&focusedElement);
    
    if (error == kAXErrorSuccess && focusedElement) {
      // 1. Try Range-based approach (Universal)
      BOOL rangeSuccess = NO;
      AXValueRef selectedRangeValue = NULL;
      AXError getSelectedRangeError = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute, (CFTypeRef *)&selectedRangeValue);
      
      if (getSelectedRangeError == kAXErrorSuccess && selectedRangeValue) {
        CFRange selectedRange;
        AXValueGetValue(selectedRangeValue, kAXValueTypeCFRange, &selectedRange);
        
        CFIndex lengthToRead = 100;
        CFIndex location = selectedRange.location;
        CFIndex startLocation = (location > lengthToRead) ? (location - lengthToRead) : 0;
        CFIndex actualLength = location - startLocation;
        
        NSString *textBeforeCursor = nil;
        
        CFRange rangeToRead = CFRangeMake(startLocation, actualLength);
        AXValueRef rangeToReadValue = AXValueCreate(kAXValueTypeCFRange, &rangeToRead);
        CFTypeRef textRef = NULL;
        AXError getTextError = AXUIElementCopyParameterizedAttributeValue(focusedElement, kAXStringForRangeParameterizedAttribute, rangeToReadValue, &textRef);
        if (getTextError == kAXErrorSuccess && textRef) {
          textBeforeCursor = (__bridge NSString *)textRef;
        }
        CFRelease(rangeToReadValue);
        
        if (!textBeforeCursor) {
          NSString *fullText = [UIElementUtilities valueOfAttribute:@"AXValue" ofUIElement:focusedElement];
          if (fullText && [fullText isKindOfClass:[NSString class]]) {
            if (location <= [fullText length]) {
              textBeforeCursor = [fullText substringWithRange:NSMakeRange(startLocation, actualLength)];
            }
          }
        }
        
        if (textBeforeCursor) {
          NSString *doubleCallsign = [callsign stringByAppendingString:callsign];
          
          NSRange rangeOfDouble = [textBeforeCursor rangeOfString:doubleCallsign options:NSBackwardsSearch];
          NSRange rangeOfSingle = [textBeforeCursor rangeOfString:callsign options:NSBackwardsSearch];
          
          NSString *separator = nil;
          NSRange foundRange = NSMakeRange(NSNotFound, 0);
          
          if (rangeOfDouble.location != NSNotFound) {
            codeInfo.isAbbreviation = false;
            separator = doubleCallsign;
            foundRange = rangeOfDouble;
          } else if (rangeOfSingle.location != NSNotFound) {
            codeInfo.isAbbreviation = true;
            separator = callsign;
            foundRange = rangeOfSingle;
          }
          
          if (separator) {
            NSString *potentialQuery = [textBeforeCursor substringFromIndex:NSMaxRange(foundRange)];
            
            NSRange lastNewline = [potentialQuery rangeOfString:@"\n"];
            if (lastNewline.location == NSNotFound) {
              codeInfo.query = potentialQuery;
              
              AXValueRef selectionBoundsValue = NULL;
              AXError getSelectionBoundsError = AXUIElementCopyParameterizedAttributeValue(focusedElement, kAXBoundsForRangeParameterizedAttribute, selectedRangeValue, (CFTypeRef *)&selectionBoundsValue);
              
              if (getSelectionBoundsError == kAXErrorSuccess && selectionBoundsValue) {
                CGRect selectionBounds;
                AXValueGetValue(selectionBoundsValue, kAXValueCGRectType, &selectionBounds);
                codeInfo.frame = NSRectFromCGRect(selectionBounds);
                CFRelease(selectionBoundsValue);
                rangeSuccess = YES;
              }
            }
          }
        }
        if (textRef) CFRelease(textRef);
        CFRelease(selectedRangeValue);
      }
      
      if (rangeSuccess) {
        CFRelease(focusedElement);
        CFRelease(mainElement);
        return true;
      }

      // 2. Fallback: Line-based approach (Legacy support for VS Code / AXTextArea)
      if ([[UIElementUtilities valueOfAttribute:@"AXRole" ofUIElement:focusedElement] isEqual: @"AXTextArea"]) {
        NSString *code = [UIElementUtilities valueOfAttribute:@"AXValue" ofUIElement:focusedElement];
        NSInteger insertionPointerLine = [[UIElementUtilities valueOfAttribute:@"AXInsertionPointLineNumber" ofUIElement:focusedElement] integerValue];
        
        codeInfo.insertionPointerLine = insertionPointerLine;
        NSArray<NSString *> *lines = [code componentsSeparatedByString:@"\n"];
        
        if (0 <= insertionPointerLine && insertionPointerLine < [lines count]) {
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
          if ([seperated count] == 2) {
            codeInfo.query = seperated[1];
            
            // We still need the frame. Try to get it via selected range again.
            AXValueRef selectedRangeValue = NULL;
            AXError getSelectedRangeError = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute, (CFTypeRef *)&selectedRangeValue);
            if (getSelectedRangeError == kAXErrorSuccess) {
              AXValueRef selectionBoundsValue = NULL;
              AXError getSelectionBoundsError = AXUIElementCopyParameterizedAttributeValue(focusedElement, kAXBoundsForRangeParameterizedAttribute, selectedRangeValue, (CFTypeRef *)&selectionBoundsValue);
              CFRelease(selectedRangeValue);
              if (getSelectionBoundsError == kAXErrorSuccess) {
                CGRect selectionBounds;
                AXValueGetValue(selectionBoundsValue, kAXValueCGRectType, &selectionBounds);
                codeInfo.frame = NSRectFromCGRect(selectionBounds);
                CFRelease(selectionBoundsValue);
                
                CFRelease(focusedElement);
                CFRelease(mainElement);
                return true;
              }
            }
          }
        }
      }
      
      CFRelease(focusedElement);
    }
    CFRelease(mainElement);
  }
  
  return false;
};

- (void)useCode:(NSString *)snippet isAbbreviation:(bool)isAbbreviation callsign:(NSString*)callsign {
  NSString *app = NSWorkspace.sharedWorkspace.frontmostApplication.localizedName;

  if ([self isAllowed:app]) {
    AXUIElementRef mainElement = AXUIElementCreateApplication(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier);
    AXUIElementRef focusedElement = NULL;
    AXError error = AXUIElementCopyAttributeValue(mainElement, kAXFocusedUIElementAttribute, (CFTypeRef *)&focusedElement);
    
    if (error == kAXErrorSuccess && focusedElement) {
      AXValueRef selectedRangeValue = NULL;
      AXError getSelectedRangeError = AXUIElementCopyAttributeValue(focusedElement, kAXSelectedTextRangeAttribute, (CFTypeRef *)&selectedRangeValue);
      
      if (getSelectedRangeError == kAXErrorSuccess && selectedRangeValue) {
        CFRange selectedRange;
        AXValueGetValue(selectedRangeValue, kAXValueTypeCFRange, &selectedRange);
        
        CFIndex lengthToRead = 100;
        CFIndex location = selectedRange.location;
        CFIndex startLocation = (location > lengthToRead) ? (location - lengthToRead) : 0;
        CFIndex actualLength = location - startLocation;
        
        NSString *textBeforeCursor = nil;
        
        CFRange rangeToRead = CFRangeMake(startLocation, actualLength);
        AXValueRef rangeToReadValue = AXValueCreate(kAXValueTypeCFRange, &rangeToRead);
        CFTypeRef textRef = NULL;
        AXError getTextError = AXUIElementCopyParameterizedAttributeValue(focusedElement, kAXStringForRangeParameterizedAttribute, rangeToReadValue, &textRef);
        if (getTextError == kAXErrorSuccess && textRef) {
          textBeforeCursor = (__bridge NSString *)textRef;
        }
        CFRelease(rangeToReadValue);
        
        if (!textBeforeCursor) {
          NSString *fullText = [UIElementUtilities valueOfAttribute:@"AXValue" ofUIElement:focusedElement];
          if (fullText && [fullText isKindOfClass:[NSString class]]) {
            if (location <= [fullText length]) {
              textBeforeCursor = [fullText substringWithRange:NSMakeRange(startLocation, actualLength)];
            }
          }
        }
        
        if (textBeforeCursor) {
          NSString *separator = isAbbreviation ? callsign : [callsign stringByAppendingString:callsign];
          NSRange rangeOfSeparator = [textBeforeCursor rangeOfString:separator options:NSBackwardsSearch];
          
          if (rangeOfSeparator.location != NSNotFound) {
            CFIndex separatorAbsLocation = startLocation + rangeOfSeparator.location;
            CFIndex replaceLength = location - separatorAbsLocation;
            
            CFRange replaceRange = CFRangeMake(separatorAbsLocation, replaceLength);
            AXValueRef replaceRangeValue = AXValueCreate(kAXValueTypeCFRange, &replaceRange);
            
            AXUIElementSetAttributeValue(focusedElement, kAXSelectedTextRangeAttribute, replaceRangeValue);
            CFRelease(replaceRangeValue);
            
            AXError setTextError = AXUIElementSetAttributeValue(focusedElement, kAXSelectedTextAttribute, (CFStringRef)snippet);
            
            if (setTextError != kAXErrorSuccess) {
              if ([app isEqual: @"Code"]) {
                [UIElementUtilities setStringValue:snippet forAttribute:kAXValueAttribute ofUIElement:focusedElement];
              }
            }
          }
        }
        if (textRef) CFRelease(textRef);
        CFRelease(selectedRangeValue);
      }
      CFRelease(focusedElement);
    }
    CFRelease(mainElement);
  }
}

@end
