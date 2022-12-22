#import <Cocoa/Cocoa.h>

@interface UIElementUtilities : NSObject {}

+ (NSArray *)attributeNamesOfUIElement:(AXUIElementRef)element;
+ (id)valueOfAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;
+ (void)setStringValue:(NSString *)stringValue forAttribute:(NSString *)attribute ofUIElement:(AXUIElementRef)element;
+ (NSRect)frameOfUIElement:(AXUIElementRef)element;

@end
