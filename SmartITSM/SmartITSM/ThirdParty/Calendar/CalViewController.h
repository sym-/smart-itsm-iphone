/*
 * Calendar
 */

#import <UIKit/UIKit.h>
#import "CalPrefix.h"
#import "CalView.h"       // for the CalViewDelegate protocol
#import "CalDataSource.h" // for the CalDataSourceCallbacks protocol

@class CalLogic;

/*
 *    CalViewController
 *    ------------------------
 *
 *  CalViewController automatically creates both the calendar view
 *  and the events table view for you. The only thing you need to provide
 *  is a CalDataSource so that the calendar system knows which days to
 *  mark with a dot and which events to list under the calendar when a certain
 *  date is selected (just like in Apple's calendar app).
 *
 */
@interface CalViewController : UIViewController <CalViewDelegate, CalDataSourceCallbacks>
{
    CalLogic *logic;
    UITableView *tableView;
    id <UITableViewDelegate> __unsafe_unretained delegate;
    id <CalDataSource> __unsafe_unretained dataSource;
}

@property (nonatomic, unsafe_unretained) id<UITableViewDelegate> delegate;
@property (nonatomic, unsafe_unretained) id<CalDataSource> dataSource;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSDate *beginDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, assign) CalSelectionMode selectionMode;
@property (nonatomic, strong) NSDate *minAvailableDate;
@property (nonatomic, strong) NSDate *maxAVailableDate;

- (id)initWithSelectionMode:(CalSelectionMode)selectionMode;
- (id)initWithSelectionMode:(NSCoder *)aDecoder selectionMode:(CalSelectionMode)selectionMode;

- (void)reloadData;                                 // If you change the CalDataSource after the CalViewController has already been displayed to the user, you must call this method in order for the view to reflect the new data.

- (void)showAndSelectDate:(NSDate *)date;           // Updates the state of the calendar to display the specified date's month and selects the tile for that date.

@end
