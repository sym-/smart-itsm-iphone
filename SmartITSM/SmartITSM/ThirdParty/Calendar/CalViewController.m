/*
 * Calendar
 */

#import "CalViewController.h"
#import "CalLogic.h"
#import "CalDataSource.h"
#import "CalPrivate.h"

#define PROFILER 0
#if PROFILER
#include <mach/mach_time.h>
#include <time.h>
#include <math.h>
void mach_absolute_difference(uint64_t end, uint64_t start, struct timespec *tp)
{
    uint64_t difference = end - start;
    static mach_timebase_info_data_t info = {0,0};
    
    if (info.denom == 0)
        mach_timebase_info(&info);
    
    uint64_t elapsednano = difference * (info.numer / info.denom);
    tp->tv_sec = elapsednano * 1e-9;
    tp->tv_nsec = elapsednano - (tp->tv_sec * 1e9);
}
#endif

NSString *const CalDataSourceChangedNotification = @"CalDataSourceChangedNotification";

@interface CalViewController ()

- (CalView*)calendarView;

@end

@implementation CalViewController

@synthesize dataSource, delegate;

- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    self.calendarView.gridView.beginDate = _selectedDate;
    [self showAndSelectDate:_selectedDate];
}

- (void)setBeginDate:(NSDate *)beginDate
{
    _beginDate = beginDate;
    self.calendarView.gridView.beginDate = _beginDate;
    [self showAndSelectDate:_beginDate];
}

- (void)setEndDate:(NSDate *)endDate
{
    _endDate = endDate;
    self.calendarView.gridView.endDate = _endDate;
    [(CalView *)self.view redrawEntireMonth];
}

- (void)setMinAvailableDate:(NSDate *)minAvailableDate
{
    _minAvailableDate = minAvailableDate;
    ((CalView *)self.view).gridView.minAvailableDate = minAvailableDate;
    [(CalView *)self.view redrawEntireMonth];
}

- (void)setMaxAVailableDate:(NSDate *)maxAVailableDate
{
    _maxAVailableDate = maxAVailableDate;
    ((CalView *)self.view).gridView.maxAVailableDate = maxAVailableDate;
    [(CalView *)self.view redrawEntireMonth];
}

- (id)initWithSelectionMode:(CalSelectionMode)selectionMode
{
    if ((self = [super init]))
    {
        logic = [[CalLogic alloc] initForDate:[NSDate date]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChangeOccurred) name:UIApplicationSignificantTimeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:CalDataSourceChangedNotification object:nil];
        self.selectionMode = selectionMode;
        
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }

    return self;
}

- (id)initWithSelectionMode:(NSCoder *)aDecoder selectionMode:(CalSelectionMode)selectionMode;
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        logic = [[CalLogic alloc] initForDate:[NSDate date]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(significantTimeChangeOccurred) name:UIApplicationSignificantTimeChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:CalDataSourceChangedNotification object:nil];
        self.selectionMode = selectionMode;

        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
    }

    return self;
}

- (CalView*)calendarView { return (CalView*)self.view; }

- (void)setDataSource:(id<CalDataSource>)aDataSource
{
    if (dataSource != aDataSource)
    {
        dataSource = aDataSource;
        tableView.dataSource = dataSource;
    }
}

- (void)setDelegate:(id<UITableViewDelegate>)aDelegate
{
    if (delegate != aDelegate)
    {
        delegate = aDelegate;
        tableView.delegate = delegate;
    }
}

- (void)clearTable
{
    [dataSource removeAllItems];
    [tableView reloadData];
}

- (void)reloadData
{
    [dataSource presentingDatesFrom:logic.fromDate to:logic.toDate delegate:self];
}

- (void)significantTimeChangeOccurred
{
    [[self calendarView] jumpToSelectedMonth];
    [self reloadData];
}

// -----------------------------------------
#pragma mark CalViewDelegate protocol

- (void)didSelectDate:(NSDate *)date
{
    _selectedDate = date;
    NSDate *from = [date dateByMovingToBeginningOfDay];
    NSDate *to = [date dateByMovingToEndOfDay];
    [self clearTable];
    [dataSource loadItemsFromDate:from toDate:to];
    [tableView reloadData];
    [tableView flashScrollIndicators];
}

- (void)didSelectBeginDate:(NSDate *)beginDate endDate:(NSDate *)endDate
{
    _beginDate = beginDate;
    _endDate = endDate;
    [self clearTable];
    [dataSource loadItemsFromDate:beginDate toDate:endDate];
    [tableView reloadData];
    [tableView flashScrollIndicators];
}

- (void)showPreviousMonth
{
    [self clearTable];
    [logic retreatToPreviousMonth];
    [[self calendarView] slideDown];
    [self reloadData];
}

- (void)showFollowingMonth
{
    [self clearTable];
    [logic advanceToFollowingMonth];
    [[self calendarView] slideUp];
    [self reloadData];
}

// -----------------------------------------
#pragma mark CalDataSourceCallbacks protocol

- (void)loadedDataSource:(id<CalDataSource>)theDataSource;
{
    NSArray *markedDates = [theDataSource markedDatesFrom:logic.fromDate to:logic.toDate];
    NSMutableArray *dates = [markedDates mutableCopy];
    for (int i=0; i<[dates count]; i++)
        [dates replaceObjectAtIndex:i withObject:[dates objectAtIndex:i]];
    
    [[self calendarView] markTilesForDates:dates];
}

// ---------------------------------------
#pragma mark -

- (void)showAndSelectDate:(NSDate *)date
{
    if ([[self calendarView] isSliding])
        return;

    [logic moveToMonthForDate:date];

#if PROFILER
    uint64_t start, end;
    struct timespec tp;
    start = mach_absolute_time();
#endif
    
    [[self calendarView] jumpToSelectedMonth];
    
#if PROFILER
    end = mach_absolute_time();
    mach_absolute_difference(end, start, &tp);
    printf("[[self calendarView] jumpToSelectedMonth]: %.1f ms\n", tp.tv_nsec / 1e6);
#endif
    
    [self reloadData];
}

// -----------------------------------------------------------------------------------
#pragma mark UIViewController

- (void)loadView
{
    [super loadView];

    if (!self.title)
        self.title = @"Calendar";
    CalView *calView = [[CalView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] delegate:self logic:logic];
    calView.gridView.selectionMode = self.selectionMode;
    self.view = calView;
    tableView = calView.tableView;
    tableView.dataSource = dataSource;
    tableView.delegate = delegate;
    [self reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    tableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [tableView reloadData];

    // FIXME edgesForExtendedLayout = UIRectEdgeNone; 导致上下黑条，通过取消透明解决
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.translucent = NO;

    /** 以下代码设置默认样式不再使用
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])
    {
        self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
        self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    }
    else
    {
        self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    }
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : kLightGrayColor, NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:20]};
    */
    // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [tableView flashScrollIndicators];
}

#pragma mark -

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationSignificantTimeChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CalDataSourceChangedNotification object:nil];
}

@end