//
//  FlightListViewController.m
//  sflightdemo
//
//  Created by René on 24-10-13.
//  Copyright (c) 2013 vanmil.org. All rights reserved.
//

#import "FlightListViewController.h"

#import "FlightViewController.h"
#import "SAPGatewayClient.h"

@interface FlightListViewController ()
@property (nonatomic) UIActivityIndicatorView *loadingView; // A spinner shown when loading flights
@property (nonatomic) NSMutableArray *flights; // The flight list
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation FlightListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init flight list
    [self setFlights:[NSMutableArray array]];
    // Init loading view
    [self initLoadingView];
    // Init date formatter
    [self setDateFormatter:[[NSDateFormatter alloc] init]];
    [[self dateFormatter] setLocale:[NSLocale currentLocale]];
    [[self dateFormatter] setDateStyle:NSDateFormatterMediumStyle];
    [[self dateFormatter] setTimeStyle:NSDateFormatterNoStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // Load the flights every time the view appears
    [self loadFlights];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // Always one section for all flights
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self flights] count]; // One row for each flight
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    // Get the flight for this row
    NSMutableDictionary *flight = [[self flights] objectAtIndex:[indexPath row]];
    // Create details string
    NSString *flightDetails = [NSString stringWithFormat:@"%@ - %@", [flight valueForKey:@"CONNID"], [flight valueForKey:@"CARRID"]];
    // Parse the date
    NSString *fldateString = [flight valueForKey:@"FLDATE"];
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSRange range = NSMakeRange(0, [fldateString length]);
    NSArray *matches = [regex matchesInString:fldateString options:0 range:range];
    NSTextCheckingResult *match = matches[0];
    fldateString = [fldateString substringWithRange:[match range]];
    NSTimeInterval interval = [fldateString doubleValue] / 1000;
    NSDate *fldate = [NSDate dateWithTimeIntervalSince1970:interval];
    
    // Set labels with flight details
    [[cell textLabel] setText:flightDetails];
    [[cell detailTextLabel] setText:[[self dateFormatter] stringFromDate:fldate]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setSelectedRow:[indexPath row]];
    [self performSegueWithIdentifier:@"toFlight" sender:self];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toFlight"]) {
        FlightViewController *destination = [segue destinationViewController];
        [destination setFlight:[[self flights] objectAtIndex:[self selectedRow]]];
    }
}


#pragma mark - Flights

- (void)loadFlights
{
    // Clear existing flight list
    [[self flights] removeAllObjects];
    [[self tableView] reloadData];
    // Load the flights
    [self showLoading];
    SAPGatewayClient *client = [SAPGatewayClient sharedSAPGatewayClient];
    [client listFlightsWithSuccess:^(NSMutableArray *flights) {
        [self hideLoading];
        [self setFlights:flights];
        [[self tableView] reloadData];
    } failure:^(NSError *error) {
        [self hideLoading];
        [[self tableView] reloadData];
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection to SAP Gateway failed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }];
}


#pragma mark - Loading view

- (void)showLoading
{
    [[self loadingView] startAnimating];
}

- (void)hideLoading
{
    [[self loadingView] stopAnimating];
}

- (void)initLoadingView
{
    [self setLoadingView:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge]];
    [[self loadingView] setColor:[UIColor blackColor]];
    [[self loadingView] setCenter:[[self tableView] center]];
    [[self tableView] addSubview:[self loadingView]];
}

@end
