/*
 * Calendar
 */

#import <CoreText/CoreText.h>
#import "CalPrefix.h"
#import "CalTileView.h"
#import "CalPrivate.h"

extern const CGSize kTileSize;

@implementation CalTileView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
        origin = frame.origin;
        [self setIsAccessibilityElement:YES];
        [self setAccessibilityTraits:UIAccessibilityTraitButton];
        [self resetState];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat fontSize = 17;
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:fontSize];
    UIColor *textColor = nil;

    // 'CGContextSelectFont' is deprecated: first deprecated in iOS 7.0
    //CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);
    
    if (self.isDisable)
    {
        textColor = kGrayColor;
    }
    else if (self.belongsToAdjacentMonth)
    {
        [RGBCOLOR(240, 240, 240) setFill];
        CGContextFillRect(ctx, CGRectMake(0.f, 1.f, kTileSize.width, kTileSize.height));
        textColor = kGrayColor;
    }
    else
    {
        textColor = kDarkGrayColor;
    }

    if (self.isMarked)
    {
        UIImage *markerImage = [UIImage imageNamed:@"Calendar.bundle/cal_marker.png"];
        [markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];
    }
    
    if (self.state == CalTileStateHighlighted || self.state == CalTileStateSelected)
    {
        UIImage *image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_selected.png"];
        if (self.isToday)
        {
            image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_selected_today.png"];
        }
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        frame.origin.x = (kTileSize.width - frame.size.width) / 2;
        frame.origin.y = (kTileSize.height - frame.size.height) / 2;
        [image drawInRect:frame];
        textColor = [UIColor whiteColor];
    }
    else if (self.state == CalTileStateLeftEnd)
    {
        UIImage *image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_range_left.png"];
        if (self.isToday)
        {
            image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_range_left_today.png"];
        }
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        frame.origin.x = (kTileSize.width - frame.size.width) / 2;
        frame.origin.y = (kTileSize.height - frame.size.height) / 2;
        [image drawInRect:frame];
        textColor = [UIColor whiteColor];
    }
    else if (self.state == CalTileStateRightEnd)
    {
        UIImage *image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_range_right.png"];
        if (self.isToday)
        {
            image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_range_right_today.png"];
        }
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        frame.origin.x = (kTileSize.width - frame.size.width) / 2;
        frame.origin.y = (kTileSize.height - frame.size.height) / 2;
        [image drawInRect:frame];
        textColor = [UIColor whiteColor];
    }
    else if (self.state == CalTileStateInRange)
    {
        UIImage *image = [UIImage imageNamed:@"Calendar.bundle/cal_tile_range.png"];
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height);
        frame.origin.y = (kTileSize.height - frame.size.height) / 2;
        textColor = kGrayColor;
        [image drawInRect:frame];
    }

    NSUInteger n = [self.date day];
    NSString *dayText = [NSString stringWithFormat:@"%lu", (unsigned long)n];
    if (self.isToday)
        dayText = NSLocalizedString(@"Today", @"");
    // 'sizeWithFont:' is deprecated: first deprecated in iOS 7.0 - Use -sizeWithAttributes:
    //CGSize textSize = [dayText sizeWithFont:font];
    CGSize textSize = [dayText sizeWithAttributes:@{NSFontAttributeName:font}];
    CGFloat textX, textY;
    textX = roundf(0.5f * (kTileSize.width - textSize.width));
    textY = roundf(0.5f * (kTileSize.height - textSize.height));
    [textColor setFill];
    // 'drawAtPoint:withFont:' is deprecated: first deprecated in iOS 7.0 - Use -drawAtPoint:withAttributes:
    //[dayText drawAtPoint:CGPointMake(textX, textY) withFont:font];
    [dayText drawAtPoint:CGPointMake(textX, textY) withAttributes:@{NSFontAttributeName:font}];
}

- (void)resetState
{
    // realign to the grid
    CGRect frame = self.frame;
    frame.origin = origin;
    frame.size = kTileSize;
    self.frame = frame;
    
    self.date = nil;
    _type = CalTileTypeRegular;
    self.state = CalTileStateNone;
}

- (void)setDate:(NSDate *)aDate
{
    if (_date == aDate)
        return;
    
    _date = aDate;
    
    [self setNeedsDisplay];
}

- (void)setState:(CalTileState)state
{
    if (_state != state)
    {
        _state = state;
        [self setNeedsDisplay];
    }
}

- (void)setType:(CalTileType)tileType
{
    if (_type != tileType)
    {
        _type = tileType;
        [self setNeedsDisplay];
    }
}

- (BOOL)isToday { return self.type & CalTileTypeToday; }
- (BOOL)isFirst { return self.type & CalTileTypeFirst; }
- (BOOL)isLast { return self.type & CalTileTypeLast; }
- (BOOL)isDisable { return self.type & CalTileTypeDisable; }
- (BOOL)isMarked { return self.type & CalTileTypeMarked; }

- (BOOL)belongsToAdjacentMonth { return self.type & CalTileTypeAdjacent; }

@end
