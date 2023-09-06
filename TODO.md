#This file is a note to self on what can be improve in this project.

## TODO:
### Tech debts:
* Create a user friendly UI for creating User.
* Use Vietnamese for the creating Cell page.
* Move migration methods in MigrationController to rake tasks.
* Dynamically show or hide buttons based on user permission.
* Upgrade to latest version for Ruby and Rails.
### New features:
* Allow teachers to check students and teachers weekly attendances.
* Allow teachers to write Evaluation for students at the end of the year.
* Allow teachers to give Marks to students throughout the year.
* Create new ```Sacrament``` data model persist sacrament information between people receiving the same sacrament.
* Create new ```Household``` or ```Address``` data model to persist contact information between family members.
* Expand the system to support records of other people and household in the church. (Quản lý giáo dân) 
### Nice to have:
* Support translation for multiple languages.

## Errors and warnings:
Some errors and warnings that need to be fix soon:
* 
    ```
    DEPRECATION WARNING: `redirect_to :back` is deprecated and will be removed from Rails 5.1. Please use `redirect_back(fallback_location: fallback_location)` where `fallback_location` represents the location to use if the request has no HTTP referer information. (called from isAdminOrSelf at /Users/billle/projects/bglamutam/app/controllers/teachers_controller.rb:107)
    ```
