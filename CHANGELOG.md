## 0.13.0

### Security Fix
- Updated Rails to 3.2.12

### Enhancements
- Updated to Contour 1.2.0.pre3
  - Use bootstrap-datepicker and bootstrap-timepicker provided by Contour
- Removed references to deprecated `<center>` HTML tag
- ActionMailer can now also be configured to send email through NTLM
  - ActionMailer::Base.smtp_settings now requires an :email field
- Updated to jQuery Sparkline v2.1.1 for jQuery 1.9.1 support
- Domains are now the sole method for adding options to variables
  - Domains allow variables (dropdown, radio, scale, etc) to share common choices

### Bug Fix
- Hitting `p` no longer triggers switching to the global search when focused on a link or a drop down menu
- Fixed a bug that would disable navigation to the project page from the projects splash page on touch devices

## 0.12.3 (February 1, 2013)

### Enhancements
- Shortcut to search box simplified to `p`
- Subject Report `+` buttons no longer show up for Site Users
- Subject Report sheet counts now link directly to the sheet if the subject only has one sheet for the design

### Bug Fix
- Fixed a bug that kept users from registering using an alternate login
- Fixed an incorrect site invitation url from being generated when inviting a user on the site show page
- Fixed `last_entry` and `first_entry` SQL expression that caused some bugs

## 0.12.2 (January 31, 2013)

### Enhancements
- Designs on the subject page are now in the same order as they appear on the subject report
- `Ctrl|Command + Shift + P` will set focus on the search box (changed to just `p` in 0.12.3)

### Bug Fix
- Fixed a bug that occured when nil was passed as a search parameter to the Searchable Concern
- Fixed a bug that was resetting time fields when updating a sheet

## 0.12.1 (January 30, 2013)

### Enhancements
- Updated the variable date picker to use bootstrap-datepicker
- Updated the variable time picker to use bootstrap-timepicker
- Today and current time buttons are now ignored when tabbing
- String variables on reports are now sorted alphabetically
- Projects now sorted alphabetically on the projects splash page
- Export configuration is now saved with the export
- Variables and domains now include 5 options by default, and add 3 additional options when more options are requested
- Scale variables with headers now redisplay the option choice table header row
- Experimental reports now correctly display zeros instead of dashes when the zero represents meaningful data, instead of just an empty set
  - Ex: A variable that scores an integer value from 0 to 10 will now show the zero as a minimum value if captured on sheets
- Subject files collected across sheets are now available on the subject page
- Subject page now links back to the subject report
- Subject report is now paginated and has links to create new sheets for subjects with already existing sheets
- Boxplots on reports now use the same minimum and maximum values to scale correctly with each other
- Navigation quick search added that searches across subjects, projects, designs, and variables
- Subject count added to project page

### Bug Fix
- Fixed the affix navigation on sheet show pages
- Fixed a bug that caused last_entry and first_entry to fail to return a result if the latest (or oldest) sheet was deleted

## 0.12.0 (January 25, 2013)

### Breaking Change
- Database default updated to use PostgreSQL
  - Instructions [MIGRATING_TO_POSTGRESQL](https://github.com/remomueller/slice/blob/master/doc/MIGRATING_TO_POSTGRESQL.md)

### Enhancements
- Subject status is now viewable on sheets
- Added Subject status to Sheet XLS exports
- Design Report columns can now also include integer and numeric variables
- Links can now be added to project and can be used to link to custom project reports
- Project settings have been moved to a separate page accessible from the project show page
- Data exports have been improved
  - Data in XLS format
  - Data in CSV Raw or Labeled format
  - Data in single PDF format
  - Uploaded data files in a ZIP format
  - Data dictionary in XLS format
  - Two or more of the above in one combined ZIP file
- Data dictionaries now additionally include variables included via grid variables
- Subject index now contains filters for valid, pending, and test statuses
- Project and Site invites can now be resent
- New experimental Report Builder added for more flexible reports
- Acceptable Use Policy added

### Bug Fix
- Toggleable filter buttons on the variable index now work correctly
- Sheet totals now properly update on the Subject Report
- Deleted subject's sheets are no longer visible on the project dashboard
- Sheet exports no longer include variables that were removed from a design
- Domains are no longer duplicated in data dictionaries when referenced by multiple variables
- Checkbox labels should no longer arbitrarily break on white space
- Grid rows "Remove" button no longer stays visible after mouseing out of the row, resulting in multiple rows showing a "Remove" button
- Fixed a bug rendering design PDFs that contained variables with choices that included commas in the choice description

### Testing
- Added mail_view gem for easier email templating

## 0.11.9 (January 14, 2013)

### Bug Fix
- Sheet PDF Collation link fixed and now correctly creates a combined PDF

## 0.11.8 (January 10, 2013)

### Bug Fix
- Removed a trailing bracket that was causing certain Design reports to fail creating a PDF

## 0.11.7 (January 10, 2013)

### Enhancements
- Variable row and column selections are now grouped by section on design reports
- Design reports are now rendered using LaTeX
- Users can now also be identified by their Gravatar

### Bug Fix
- HTML now displays correctly in tooltips and popovers
- Toggleable filter buttons fixed on sheet audits page
- Temporarily reverted to CarrierWave 0.7.1 until request.script_name bug is fixed in 0.8.+

## 0.11.6 (January 9, 2013)

### Enhancements
- Updated to Contour 1.1.2 and use Contour pagination theme
- Updated Thin Server to 1.5.0
- Updated CarrierWave to 0.8.0

### Refactoring
- Added app/models/concerns
  - Searchable: Allows models to be searched by name and description
  - Deletable: Allows models to be flagged as deleted and scoped by current
  - Latexable: Allows models to escape strings for LaTeX

### Bug Fix
- Tooltips no longer resize the report tables when hovered over
- Toggleable filter buttons on reports fixed
- Subject Acrostic is no longer cleared when changing the sheet date

## 0.11.5 (January 8, 2013)

### Security Fix
- Updated Rails to 3.2.11

## 0.11.4 (January 3, 2013)

### Security Fix
- Updated Rails to 3.2.10

### Bug Fix
- User activation emails are no longer sent out when a user's status is changed from pending to inactive

## 0.11.3 (December 11, 2012)

### Enhancements
- Subject Report can now be filtered by subject status
- Variables of type radio can now be included in calculated variables
- Prepend and Append fields now only show up for calculated, date, time, integer, numeric, and string variables

### Bug Fix
- Fixed some occurences of web page elements appearing underneath others
- PDFs of designs and sheets now correctly include the header and display name of scale variables if both are specified
- Autocomplete strings fields now initialize properly when additional rows are added to the grid
- Calculated variables with blank formats now correctly return the original number that was to be formatted
- Non-standard clicks (ctrl, alt, etc) now open links in a new tab/window
- Design variable can now only be sorted by clicking the variable name, this resolves a few issues when sorting were unintentionally triggered
- Time variables no longer show "Date soft maximum" as an option
- Time and date variables tooltips and popovers no longer cover the current button if it's enabled
- Fixed a Firefox issue where launching a modal would cause the background to jump back to the top of the page
- Entered data on a sheet that fails a subject or date validation no longer resets the new information on the form

## 0.11.2 (November 30, 2012)

### Enhancements
- Variables now only use the variable name as a place holder in the input field if the variable is in a grid

### Bug Fix
- Surveys now properly load branching logic

## 0.11.1 (November 30, 2012)

### Enhancements
- Variable headers can now include simple formatting, i.e. HTML tags <a>, <b>, <i>

### Bug Fix
- Date and time variables with Show Current Button selected no longer create a JavaScript error when a user clicks the button Today button while entering a sheet
- Color Selectors now display properly when editing variable options inside of a design
- Branching logic should now work properly on sheet show pages and sheet PDFs
- Updating a variable while editing a design no longer removes the branching logic for that variable
- Date pickers now display properly when editing date variables on inside a design

## 0.11.0 (November 21, 2012)

### Enhancements
- **Design Changes**
  - Email templates and subject lines can now reference the user sending the email (full name and email)
    - User's Full Name: `#(user)`
    - User's Email: `#(user).email`
  - Designs are now rendered using LaTeX for cleaner PDFs
  - Design (Data Dictionary) exports are now provided as a single XLS file
  - Variables can now be created inline while creating or editing a design
  - Branching logic for checkboxes has been simplified:
    - See: [FAQ 305: Variable Design Branching Logic](http://remomueller.github.com/slice/faq/300-designs/305-variable-design-branching-logic)
- **Project Changes**
  - Subjects and Sites are now integrated more closely with their projects
- **Subject Changes**
  - Subjects can now be marked as valid, test, or pending
  - Filters for subject status have been added to reports
- **Sheet Changes**
  - Sheet PDF Collation now rendered using LaTeX for cleaner PDFs
  - Sheets now contain a last edited at variable that updates when a user edits the sheet (as opposed to solely viewing the sheet)
  - Printed sheets now hide variables that have been hidden by branching logic
  - Sheet audits now capture value changes triggered by editing a variable's option value in the design
  - Dates on sheets are now expanded to `mm/dd/yyyy` format if entered with a two-digit year
  - Live validations added to when entering a sheet with variables that have hard and soft ranges
  - "Create and Continue" and "Update and Continue" are now options to allow for entering multiple sheets one after another
  - Valid site ranges are now displayed during sheet entry if the site has a code_minimum, and code_maximum set
  - Sheets are now checked for unique valid design, subject, and study date combination as they are being entered to catch errors more quickly
  - Sheet receipt email TO and CC fields can now be specified as semi-colon-delimited in addition to comma-delimited
  - Sheet PDFs sent using sheet receipt emails are now named in the following manner
    - `[subject_code]_[study_date]_[design_name].pdf`
  - Entering a sheet now provides an autocomplete list of valid subject codes
  - Grids with `default_row_number` set will now show the maximum `default_row_number` when going back to edit a sheet that did not use all of the grid rows
- **Surveys and Questionnaires**
  - Questionnaires and surveys can be generated and sent to a list of emails for external users to complete
  - External users are not required to sign up and can access the survey by clicking the survey link in the generated email
  - Subjects can now also have emails to allow project owners to send out questionnaires or surveys
  - Survey creators receive an email when the external user submits the survey
  - Survey emails are part of the sheet's email history
- **Report Changes**
  - Removed internal site ids from design reports
- **Export Changes**
  - Improved display of grid variable tables in PDF for sheets and designs
  - XLS files are now more compatible, and take up less space than the original format used
  - Exports are now run in the background and users are notified when they can access the file
    - Users can access their past exports and view the status of current exports
    - An export groups multiple files together into a single zip file
    - Users are notified by email, and also see status icons in the menu of pending and newly ready data exports
- Ruby version updated to 1.9.3-p327

### Bug Fix
- Site name and units are now correctly escaped when rendering PDF sheet
- Display names are now hidden on PDFs if the associated variable's display name is marked as gone or invisibile
- Variable Edit/Remove buttons are no longer hidden by the variable preview when editing a design
- Text input fields with autocomplete no longer display the browser default autocomplete list which sometimes caused two lists to appear on top of each other
- Editing inline variables on a design now allow the variables options and grid variables to be dragged and sorted
- Double-clicking "Create" no longer attempts to submit a sheet twice as the button is now disabled as the form is being submitted
- Removed inline JavaScript on the project page that caused errors when hovering over the project logo without the entirety of the JavaScript being loaded
- Audits are now ordered correctly on the sheet audit page
- New sheets now properly load branching logic for preselected designs

## 0.10.3 (November 7, 2012)

### Enhancements
- Sheets are now rendered using LaTeX for cleaner PDFs
- Order of project settings for News, Documents, and Contacts options now consistent
- Checkbox responses are now audited more clearly

### Bug Fix
- Fixed some tooltips not appearing when mousing over

## 0.10.2 (November 5, 2012)

### Bug Fix
- Fixed a bug that caused dropdowns to not display correctly

## 0.10.1 (November 5, 2012)

### Enhancements
- Project logo added to printed designs
- Grid responses now display the associated variable's units

### Bug Fix
- Updating values for existing checkbox variables now correctly updates values in associated sheets
- Switching a checkbox variable with existing data to a radio variable no longer causes the data to be lost
  - NOTE: Data collected as a radio variable is maintained separately from data collected while the variable was a checkbox
- Truncated HTML code in news posts no longer changes layout on the project show page
- Fixed a bug that caused Firefox to be inable to create designs that contained file variables
- Project report and subject reports now display correctly on projects with no sites

## 0.10.0 (November 2, 2012)

### Enhancements
- **Project Changes**
  - Slice root directs a user to either a splash page with projects, or the project they are currently on
  - New Project dashboard added
  - Projects can now have Contacts, Documents, and News Posts
  - Designs, Variables, and Sheets are now integrated more closely with their projects
  - Subject vs Design project report added to view the overall status of subjects
  - Project owners are no longer automatically added to the CC field for sheet receipts
    - To add a project owner back to be CC'd, add the email to the project's email field
- **Sheet Changes**
  - Datepickers now retain focus after a date is selected
  - Design navigation now uses a left menu
  - Tabbing when filling in sheets simplified to tab more quickly between relevant data inputs
- **Variable Changes**
  - Grid variables can now specify the default number of rows that are displayed
  - Added calculation popups for calculated variables
  - Simplified conditional design variable logic by removing Show If and Values section
    - NOTE: Branching Logic should be used to conditionally hide variables
  - Add Scale variable type that allows options to be specified by domains
    - Domains are a set of options that can be associated to multiple variables
  - Calculated variables can now be added to grid variables and do the calculation based on the row they are in
- **General Changes**
  - Removed the global librarian role

### Bug Fix
- Changing the subject code after entering data on the sheet no longer clears the newly entered data
- Setting variable option colors now sets the correct option's color when adding new options in quick succession

## 0.9.1 (October 23, 2012)

### Enhancements
- The project has been renamed to Slice
- **Variable Changes**
  - Added easier variable type selection on variables index
  - Simplified interface for adding variables to a grid variable
  - Simplified adding options to variables
  - Grid variable show pages now include links back to the variables included in the grid
- **Sheet Changes**
  - Projects with one design now load that design by default when creating a new sheet
  - Variable popups now only show up if the variable description is set
    - NOTE: The range description has been moved to the tooltip

### Bug Fix
- Users can now correctly create designs on projects with no sites
- Project reports are no longer duplicated on the report index for projects with more than one site
- Copying a grid variable no longer causes an error
- Copying a variable now correctly says "Create Variable" instead of "Update Variable"

## 0.9.0 (October 19, 2012)

### Enhancements
- **Report Changes**
  - Tooltip added to report permalinks that specify to right click and copy link address
  - Design reports can be exported to PDF in portrait or landscape mode
  - Design reports can now be stratified by column by any date variable captured on the design
  - Design reports can specify to remove duplicate subject sheets and only used the first or last entered sheet for a the subject
  - Custom design reports can now be saved
  - Site members can now see Project and Design report that are filtered to their own site
- **Sheet Changes**
  - Sheet show page displays if a sheet receipt email has been sent
  - Sheets and grids can now be exported as an XLS file with a sheets tab and a grids tab
  - Sheet Receipt emails are tracked and email history is viewable from the sheet show page
  - Basic auditing for sheets now enabled
- **Variable Changes**
  - Date and time variables have the option to show a "Get Current Date/Time" button
  - Radio variables can now be cleared using a new clear button at the bottom of the radio button group
  - Variable display names can be set as:
    - Visible: Shows up to the left of the variable input
    - Invisible: Transparent but still takes up space to the left of the variable input
    - Gone: The variable input shifts to the left and takes up the space the display name would have taken up
      - NOTE: 'Gone' best when used with a Variable Header, and with Grid variables
  - Radio and Checkbox Variables can now be aligned vertically (default) or in a row horizontally
  - Radio and Checkbox choices are now displayed as they appear on the form in the variables list
- **General Changes**
  - Design Library and Variable Library menu items simplified to Designs and Variables
  - Printed PDFs have the PDF creation date in the center footer of the PDF

### Bug Fix
- The popup for design email template options displays correctly again
- Project logos and uploaded images now get properly embedded in Sheet receipt emails with attached PDF
- Variable options color choices are no longer reset to white when updating a variable
- Variable option color selection fixed when attempting to change the color of a newly added option

## 0.8.0 (October 5, 2012)

### Enhancements
- **Design Changes**
  - Email subject lines can be customized per design
  - Email templates and subject lines can now reference project and design name
    - Project Name: `#(project)`
    - Design Name: `#(design)`
  - Simple HTML formatting available for email templates
  - Study Date can be renamed to be design-specific (i.e. Visit Date, etc.)
- **Variable Changes**
  - Autocomplete values can be added to string variables
    - User submitted variables can be tracked when editing the variable and can also be added to the existing autocomplete list
  - Display name can be hidden for variables to avoid redundancy with header
  - Extra strings can be prepended and appended to variables
  - Options for radio, dropdown, and checkboxes can now have a color assigned to the option that is reflected on reports
  - Grid variables can specify the size of inputs in the grid for better formatting
- **Reporting Added**
  - Project Reports
    - Show the overall distribution of sheets by design and study date
    - Drill down added to project reports to access design reports
  - Design Reports
    - Row stratification by Site or any dropdown, radio, or string variable on the design
    - Column stratification by Study Date or any dropdown, radio, or string variable on the design
    - Design reports can be downloaded as CSV
  - Reports include permalinks that allow report configurations to be shared
- **Project Changes**
  - Subject Code can be renamed to be project-specific (i.e. Participant ID, etc.)
  - New users can now be added to projects by email
- **Sheet Changes**
  - Detailed sheet information now available as a popup on the show page

### Bug Fix
- Removing rows from a grid that contains a file upload variable, now correctly shifts existing file uploads to their new position
- Date and Time input fields now display properly in grid views
- Editing Grid variables from design page popup fixed
- Reordering sections and variables on a design fixed when attempting to reorder after saving once

## 0.7.0 (September 10, 2012)

### Enhancements
- **Design Changes**
  - Multi-page designs can be created by setting "break before" to true on sections
- **Sheet Changes**
  - Projects and Sites are now sorted alphabetically when creating a sheet
  - Unsaved changes while editing sheets now asks the user if they want leave the page
  - Add last_emailed_at to sheets
  - Sheets on projects with acrostic enabled now display the subject's acrostic on the PDF
  - Subject acrostic added to data exports
- **Variable Changes**
  - Units now available for numeric, integer, and calculated variables
  - Grid variable added that can display a list of variables in a grid format
    - Variables in a grid can also be repeated if more rows are needed in the grid
    - Variable input control sizes can be defined for grid variables

### Bug Fix
- Updating a subject's acrostic when editing a sheet now correctly updates the subject's acrostic

## 0.6.0 (August 10, 2012)

### Enhancements
- **Project Changes**
  - Sheet and subject counts on the project page now link to the corresponding filtered sheet or subject index pages
  - Project logos can be removed by hovering over the logo on the project show page
  - Hovering over a site user now displays who invited the user to the site
- **Sheet Changes**
  - Sheet index allows sorting by design name, subject code, site name, project name, and creator name
  - Sheets index columns reordered
    - Sheet, Subject, Study Date, Site, Project, Creator, Actions
  - Attaching a PDF to sheet receipt emails is now optional
- **Design Changes**
  - Sections and variables can be reordered on the design show page
  - Section and variable counts are now displayed on the design show page
  - Added more options for email templates
    - Site Name: `#(site)`
    - Study Date: `#(date)`
    - Variable: `$(variable)`,             i.e. `$(scorer_id)       => 1: John Smith`
    - Variable Label: `$(variable).label`, i.e. `$(scorer_id).label => John Smith`
    - Variable Value: `$(variable).value`, i.e. `$(scorer_id).value => 1`
  - Design index allows sorting by project name and creator name
  - Design index displays variable count per design
  - Variables and sections can now be added in the middle of a form when editing a design
  - Variables can now be edited while updating a design
  - Variable branching logic is now limited to variables already on the design
  - Advanced branching logic syntax can now be added to variables and sections
  - Data dictionaries in CSV format can now be downloaded by filtering designs
    - Invidual data dictionaries are also available for designs
- **Variable Changes**
  - Calculated variables can now have a specified format
    - Precision, i.e. `%0.02f`, `4.127 => 4.13`
    - Leading Zeros, i.e. `%04d`, `45 => 0045`
  - Numeric and integer max/min hard/soft range information is now displayed in a table under the variable description
  - Missing codes are now displayed distinctly for check boxes and radio button groups
  - Numeric fields have been changed back to text fields to be consistent across browsers
  - Copying variables retains the original project from which they were copied
- **Miscellaneous**
  - Users can specify how many items are displayed on index pages
  - User show page now displays the sites and projects the user can view
- Updated to Rails 3.2.8

### Bug Fix
- Designs no longer lose temporary modifications when changes aren't saved due to validation errors
- Variables no longer lose temporary modifications when changes aren't saved due to validation errors

## 0.5.0 (July 24, 2012)

### Enhancements
- **Project Changes**
  - Project page now shows more information on associated designs and sites
  - Logos can be added to projects and are displayed throughout the application and on PDFs
  - Projects can now enable acrostic codes for subjects
  - Users can be invited to individual project sites by email
- **Sheet Changes**
  - Printable version of designs and sheets have been improved
  - Sheets can now be exported as labeled or unlabeled CSV files
  - Sheets can be exported as a PDF collation
  - Missing codes for numerics are now displayed as a name and value when viewing sheets
- **Design Changes**
  - Designs can no longer be saved with duplicate variables
  - Each design can have its email template customized
- **Variable Changes**
  - Time variables added
  - File upload variables added
- Updated to Rails 3.2.7.rc1
  - Removed deprecated use of update_attribute for Rails 4.0 compatibility

### Bug Fix
- Designs loading time for editing has been improved
- Scroll-spy now works correctly on designs where variables are dynamically shown and hidden

### Testing
- Use ActionDispatch for Integration tests instead of ActionController

## 0.4.1 (July 11, 2012)

### Testing
- Added test to assure that subjects can't be created without being assigned to a site

## 0.4.0 (July 10, 2012)

### Enhancements
- **Variable Changes**
  - Hard Maximums and Hard Minimums added for date variables
  - Soft Ranges can be added to Integer, Numeric, and Date variables
  - Calculated variables are now supported
  - Missing codes can now be added to numerics and integers
  - Dropdown options are now grouped by missing codes
- **Subject and Site Changes**
  - Sites can now specify valid subject code ranges
  - Subjects created within the valid range are automatically validated
- **Email Changes**
  - Default application name is now added to the `from` field for emails
  - Email subjects no longer include the application name
- Sheet PDFs can be downloaded from Sheets Index page
- About page reformatted to include links to github and contact information

### Refactoring
- Index page ordering and sorting now done consistently across project
- Deleting items from lists uses partial page update to keep selected filters in place

## 0.3.1 (June 22, 2012)

### Bug Fix
- Older designs without condition_values set now load properly

## 0.3.0 (June 22, 2012)

### Enhancements
- Reset Filters added to Designs, Variables, Subjects, and Sites Index pages
- Designs and Sheets can now be printed to PDF
- **Sheet Changes**
  - CSV export now requires at least one sheet to be filtered
  - Sheet emails now also include a PDF attachment
- **Design Changes**
  - Designs can now have section headers
  - Design section names and variable headers are now included in the sheet email template
  - Sections and Variables can now be added to the top in the design builder
  - Conditional logic improved to allow cascading of conditional logic
- **Variable Changes**
  - Variable name field now only allows a maximum length of 32 characters
  - Variable show page now displays all designs that include the variable
- **Site Changes**
  - Sites can now have prefixes
  - Entering new subjects will now attempt to guess the site based on the subject code and site prefixes
- **Subject Changes**
  - Subjects can now be marked as validated to allow detection of erroneously added subject codes
  - Entering a subject code will now inform the user subject code is valid, invalid, or new
- **Project Changes**
  - Project page now lists designs and links to project specific designs
  - Project page now links to project specific sheets

## 0.2.1 (June 13, 2012)

### Enhancements
- **Sheet Changes**
  - Sheets are now updated to reflect changes to the associated design
- **Variable Changes**
  - Variables now display Project Name or Global when adding variables to designs
  - Updating existing variable option values now updates sheets accordingly
  - Removing an existing variable option now resets sheets with that option selected
  - Option values can't contain colons, must be unique and can't be blank
  - Variables are filterable by project, variable type, and creator
- **Design Changes**
  - Designs are filterable by project and creator
  - Selecting variables when designing a form now show a preview of the variable
  - Conditional logic added to hide variables on designs based on values in other variables
- **Project Changes**
  - Projects now link to subjects and sites
- **Subject Changes**
  - Subject's page shows sheets entered for that subject
  - Subjects can be filtered by designs that haven't been filled out
  - Subjects can be filtered by site
- Updated to Rails 3.2.6

### Bug Fix
- Librarians can edit/update all global designs/variables (designs/variables not on projects), or designs/variables that they have created themselves
- Librarians can move designs/variables to and from projects
- Subjects and Sites creation are now limited to projects a user can access

## 0.2.0 (June 8, 2012)

### Enhancements
- **Sheet Changes**
  - Sheets are restricted to one per design_id, project_id, subject_id, and study_date
  - Sheet receipts can now be emailed to the associated subject's site
  - Sheets can now be filtered by study date, project, site, design, and creator
  - Sheets track who last updated the sheet
  - Sheet data can be exported en-masse to CSV
- **Project Changes**
  - Projects can have emails to be cc'd on sheet receipts
  - Projects can now have multiple sites, and each subject is assigned to a specific site
  - Projects can now have
    - Librarians who can modify project designs and variables
    - Members who can modify project sheets, subjects, and sites
- **Design and Variable Changes**
  - Variable creating or updating
     - A confirmation box now displays that warns the user that options with blank names will be removed
     - Hard Minimum and Maximum values can be added for Numeric and Integer variables
  - Variables and Designs in Library can now be copied as templates for new variables or new designs
  - Previews now show for Designs and Variables

### Bug Fix
- Variable options now correctly load when editing a variable
- Subjects now correctly linked to their appropriate sheets

## 0.1.0 (May 29, 2012)

### Enhancements
- Added Design and Variable Libraries
  - Designs are used to create templates of forms for subjects
  - Variables are used to define data collected on the forms
- Added Projects, Subjects, and Sheets
  - Projects group together specific a set of subjects
  - Sheets are filled out forms

## 0.0.0 (May 15, 2012)

- Skeleton files to initialize Rails application with testing framework and continuous integration