/*
 * Calendar
 */

#import <Foundation/Foundation.h>

/*
 *    CalLogic
 *    ------------------
 *
 *    Private interface
 *
 *  As a client of the Cal system you should not need to use this class directly
 *  (it is managed by the internal Cal subsystem).
 *
 *  The CalLogic represents the current state of the displayed calendar month
 *  and provides the logic for switching between months and determining which days
 *  are in a month as well as which days are in partial weeks adjacent to the selected
 *  month.
 *
 */
@interface CalLogic : NSObject
{
    NSDate *baseDate;
    NSDate *fromDate;
    NSDate *toDate;
    NSArray *daysInSelectedMonth;
    NSArray *daysInFinalWeekOfPreviousMonth;
    NSArray *daysInFirstWeekOfFollowingMonth;
    NSDateFormatter *monthAndYearFormatter;
}

@property (nonatomic, strong) NSDate *baseDate;    // The first day of the currently selected month
@property (nonatomic, strong, readonly) NSDate *fromDate;  // The date corresponding to the tile in the upper-left corner of the currently selected month
@property (nonatomic, strong, readonly) NSDate *toDate;    // The date corresponding to the tile in the bottom-right corner of the currently selected month
@property (nonatomic, strong, readonly) NSArray *daysInSelectedMonth;             // array of NSDate
@property (nonatomic, strong, readonly) NSArray *daysInFinalWeekOfPreviousMonth;  // array of NSDate
@property (nonatomic, strong, readonly) NSArray *daysInFirstWeekOfFollowingMonth; // array of NSDate
@property (copy, nonatomic, readonly) NSString *selectedMonthNameAndYear; // localized (e.g. "September 2010" for USA locale)

- (id)initForDate:(NSDate *)date; // designated initializer.

- (void)retreatToPreviousMonth;
- (void)advanceToFollowingMonth;
- (void)moveToMonthForDate:(NSDate *)date;

@end
