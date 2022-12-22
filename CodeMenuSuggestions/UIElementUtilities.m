#import "UIElementUtilities.h"

@implementation UIElementUtilities
+ (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element {
    NSArray *attrNames = nil;
    
    AXUIElementCopyAttributeNames(element, (CFArrayRef *)&attrNames);
    
    return [attrNames autorelease];
}

+ (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element {
    id result = nil;
    NSArray *attributeNames = [UIElementUtilities attributeNamesOfUIElement:element];
    
    if (attributeNames) {
        if ( [attributeNames indexOfObject:(NSString *)attribute] != NSNotFound
                &&
        	AXUIElementCopyAttributeValue(element, (CFStringRef)attribute, (CFTypeRef *)&result) == kAXErrorSuccess
        ) {
            [result autorelease];
        }
    }
    return result;
}

+ (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attributeName ofUIElement:(AXUIElementRef)element {
    CFTypeRef	theCurrentValue 	= NULL;
        
    // First, found out what type of value it is.
    if ( attributeName
        && AXUIElementCopyAttributeValue( element, (CFStringRef)attributeName, &theCurrentValue ) == kAXErrorSuccess
        && theCurrentValue) {
    
        CFTypeRef	valueRef = NULL;

        // Set the value using based on the type
        if (AXValueGetType(theCurrentValue) == kAXValueCGPointType) {		// CGPoint
	    float x, y;
            sscanf( [stringValue UTF8String], "x=%g y=%g", &x, &y );
	    CGPoint point = CGPointMake(x, y);
            valueRef = AXValueCreate( kAXValueCGPointType, (const void *)&point );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCGSizeType) {	// CGSize
	    float w, h;
            sscanf( [stringValue UTF8String], "w=%g h=%g", &w, &h );
            CGSize size = CGSizeMake(w, h);
            valueRef = AXValueCreate( kAXValueCGSizeType, (const void *)&size );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCGRectType) {	// CGRect
	    float x, y, w, h;
            sscanf( [stringValue UTF8String], "x=%g y=%g w=%g h=%g", &x, &y, &w, &h );
	    CGRect rect = CGRectMake(x, y, w, h);
            valueRef = AXValueCreate( kAXValueCGRectType, (const void *)&rect );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
     	else if (AXValueGetType(theCurrentValue) == kAXValueCFRangeType) {	// CFRange
            CFRange range;
            sscanf( [stringValue UTF8String], "pos=%ld len=%ld", &(range.location), &(range.length) );
            valueRef = AXValueCreate( kAXValueCFRangeType, (const void *)&range );
            if (valueRef) {
                AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, valueRef );
                CFRelease( valueRef );
            }
        }
        else if ([(id)theCurrentValue isKindOfClass:[NSString class]]) {	// NSString
            AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, stringValue );
        }
        else if ([(id)theCurrentValue isKindOfClass:[NSValue class]]) {		// NSValue
            AXUIElementSetAttributeValue( element, (CFStringRef)attributeName, [NSNumber numberWithFloat:[stringValue floatValue]] );
        }
    }
}


+ (NSRect) flippedScreenBounds:(NSRect) bounds {
    float screenHeight = NSMaxY([[[NSScreen screens] objectAtIndex:0] frame]);
    bounds.origin.y = screenHeight - NSMaxY(bounds);
    return bounds;
}


+ (NSRect)frameOfUIElement:(AXUIElementRef)element {
    NSRect bounds = NSZeroRect;
    
    id elementPosition = [UIElementUtilities valueOfAttribute:NSAccessibilityPositionAttribute ofUIElement:element];
    id elementSize = [UIElementUtilities valueOfAttribute:NSAccessibilitySizeAttribute ofUIElement:element];
    
    if (elementPosition && elementSize) {
		NSRect topLeftWindowRect;
		AXValueGetValue((AXValueRef)elementPosition, kAXValueCGPointType, &topLeftWindowRect.origin);
		AXValueGetValue((AXValueRef)elementSize, kAXValueCGSizeType, &topLeftWindowRect.size);
		bounds = [self flippedScreenBounds:topLeftWindowRect];
    }
    return bounds;
}

@end
