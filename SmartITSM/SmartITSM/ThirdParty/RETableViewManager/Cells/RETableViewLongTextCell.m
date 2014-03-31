//
// RELongTextCell.m
// RETableViewManager
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RETableViewLongTextCell.h"
#import "RETableViewManager.h"

@interface RETableViewLongTextCell ()

@property (strong, readwrite, nonatomic) REPlaceholderTextView *textView;

@end

@implementation RETableViewLongTextCell

+ (BOOL)canFocusWithItem:(RELongTextItem *)item
{
    return item.editable;
}

#pragma mark -
#pragma mark Lifecycle

- (void)cellDidLoad
{
    [super cellDidLoad];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.backgroundColor = [UIColor clearColor];
    
    self.textView = [[REPlaceholderTextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.inputAccessoryView = self.actionBar;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.delegate = self;
    [self.contentView addSubview:self.textView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.textView becomeFirstResponder];
    }
}

- (void)cellWillAppear
{
    [super cellWillAppear];

    UILabel *label = self.textLabel;
    
    CGFloat padding = (REUIKitIsFlatMode() && self.section.style.contentViewMargin <= 0) ? 7 : 2;
    NSDictionary *metrics = @{ @"padding": @(padding) };
    UITextView *textView = self.textView;
    [self.contentView removeConstraints:self.contentView.constraints];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]-2-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(textView, label)]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-padding-[textView]-padding-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(textView, label)]];
    
    self.textView.editable = self.item.editable;
    self.textView.inputAccessoryView = self.textView.editable ?  self.actionBar : nil;
    
    self.textView.text = self.item.value;
    self.textView.placeholder = self.item.placeholder;
    self.textView.placeholderColor = self.item.placeholderColor;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.autocapitalizationType = self.item.autocapitalizationType;
    self.textView.autocorrectionType = self.item.autocorrectionType;
    self.textView.spellCheckingType = self.item.spellCheckingType;
    self.textView.keyboardType = self.item.keyboardType;
    self.textView.keyboardAppearance = self.item.keyboardAppearance;
    self.textView.returnKeyType = self.item.returnKeyType;
    self.textView.enablesReturnKeyAutomatically = self.item.enablesReturnKeyAutomatically;
    self.textView.secureTextEntry = self.item.secureTextEntry;
}

- (UIResponder *)responder
{
    if (!self.item.editable)
        return nil;
    
    return self.textView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
}


#pragma mark -
#pragma mark UITextView delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self updateActionBarNavigationControl];
    [self.parentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowIndex inSection:self.sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    update by dweng
//    if (self.item.onBeginEditing){
    
//      self.item.onBeginEditing(self.item);
   
        self.textView.layer.cornerRadius = 8.0f;
        self.textView.layer.borderWidth= 1.0f;
        self.textView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//    }
 
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if (self.item.onEndEditing){
        self.item.onEndEditing(self.item);
    }else{
        self.textView.layer.borderColor=[[UIColor darkGrayColor] CGColor];
        self.textView.layer.borderWidth= 0.0f;
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.item.onReturn && [text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if (self.item.onReturn)
            self.item.onReturn(self.item);
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    self.item.value = textView.text;
    if (self.item.onChange)
        self.item.onChange(self.item);
}

@end
