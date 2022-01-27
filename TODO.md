#This file is a note to self on what can be improve in this project.

## TODO:
### Tech debts:
* Create a user friendly UI for creating User.
* Create a user friendly UI for Search page.
* Use Vietnamese for the creating Teacher page.
* Use Vietnamese for the creating Cell page.
* Use Vietnamese for the Admin page.
* Rename ```isAdmin``` column in User table to ```admin``` as per naming convention.
* Rename Cell's ```grade``` attribute to ```family```.
* Split Cell's ```group``` attribute to ```level``` and ```group```.
* Move migration methods in MigrationController to rake tasks.
* Dynamically show or hide buttons based on user permission.
* Create ```deleted``` columns in database tables and use it instead of hard delete.
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

## NoSQL datastructure
Some ideas on how we can structure our database as documents. 
This is unlikely to be use as our current data structure is not complicated.
And implementing NoSQL with denormalization will do more harm than good.
```
    Cell
        year
        grade
        group
        location
        -------------
        Denorm:
            teachers: {
                id
                position
            }
            students: {
                id
                result
            }

    Address
        number
        street
        ward (dict)
        district (dict)
        phone
        area (rename) (dict)
        is_deleted
        --------------
        Denorm:
        father
        mother
        members

    Person
        common: {
            christian_name 
            named_date
            name
            gender (dict)
            birth_date
            birth_place
        }

        phone
        email
        address 
        
        education (dict)
        occupation 
        studying
        married
        passed_away

        sacraments:
            baptism {
                _id 
                date
                location
            }
            communion
            confirmation
            declaration

        sunday_school:
            teaching: {
                cell_id 
                position
            }
            attending:{
                
            }

        note
        is_deleted

    Sacrament
        type (dict)
        date
        location
        officiator
        is_deleted
        --------------
        Denorm:
            recipients
```