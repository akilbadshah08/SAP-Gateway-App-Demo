//
//  FlightViewController.m
//  sflightdemo
//
//  Created by René on 24-10-13.
//  Copyright (c) 2013 vanmil.org. All rights reserved.
//

#import "FlightViewController.h"

@interface FlightViewController ()
@property (nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation FlightViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Init date formatter
    [self setDateFormatter:[[NSDateFormatter alloc] init]];
    [[self dateFormatter] setLocale:[NSLocale currentLocale]];
    [[self dateFormatter] setDateStyle:NSDateFormatterMediumStyle];
    [[self dateFormatter] setTimeStyle:NSDateFormatterNoStyle];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSString *textLabel = @"";
    NSString *detailTextLabel = @"";
    switch ([indexPath row]) {
        case 0:
        {
            textLabel = @"Airline";
            detailTextLabel = [[self flight] valueForKey:@"CARRID"];
            break;
        }
        case 1:
        {
            textLabel = @"Number";
            detailTextLabel = [[self flight] valueForKey:@"CONNID"];
            break;
        }
        case 2:
        {
            // Parse the date
            NSString *fldateString = [[self flight] valueForKey:@"FLDATE"];
            NSError *error;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)" options:NSRegularExpressionCaseInsensitive error:&error];
            NSRange range = NSMakeRange(0, [fldateString length]);
            NSArray *matches = [regex matchesInString:fldateString options:0 range:range];
            NSTextCheckingResult *match = matches[0];
            fldateString = [fldateString substringWithRange:[match range]];
            NSTimeInterval interval = [fldateString doubleValue] / 1000;
            NSDate *fldate = [NSDate dateWithTimeIntervalSince1970:interval];
            textLabel = @"Flight date";
            detailTextLabel = [[self dateFormatter] stringFromDate:fldate];
            break;
        }
        case 3:
        {
            textLabel = @"Price";
            detailTextLabel = [NSString stringWithFormat:@"%@ %@", [[self flight] valueForKey:@"CURRENCY"], [[self flight] valueForKey:@"PRICE"]];
            break;
        }
        default:
            textLabel = @"";
            detailTextLabel = @"";
            break;
    }
    [[cell textLabel] setText:textLabel];
    [[cell detailTextLabel] setText:detailTextLabel];

    return cell;
}

@end
