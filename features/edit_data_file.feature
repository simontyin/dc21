Feature: View the list of data files
  In order to edit what I need
  As a user
  I want to edit the details of data files

  Background:
      Given I am logged in as "georgina@intersect.org.au"
      And I have data files
        | filename     | created_at       | uploaded_by               | start_time        | end_time            | interval | experiment         | file_processing_description | file_processing_status | format |
        | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au |                   |                     |          | My Nice Experiment | Description of my file      | RAW                    |        |
        | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 15:23:00 | 30/11/2011 12:00:00 | 300      | Other              |                             | UNKNOWN                | TOA5   |

  Scenario: Navigate from list and view edit data file page
    When I am on the list data files page
    And I edit data file "sample.txt"
    Then I should see "sample.txt"
    And I should see "sean@intersect.org.au"
    And I should see "2010-06-01 5:23:00"
    And I should see "2011-11-30 1:00:00"
    When I follow "Cancel"
    Then I should be on the list data files page

  Scenario: Editing the data file
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I fill in "Name" with "edtspl.txt"
    And I fill in "Description" with "edited description"
    And I press "Update"
    Then I should see "edtspl.txt"
    And I should see "edited description"

  Scenario: Cancel edit data file
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I fill in "Name" with "edited sample.txt"
    And I fill in "Description" with "edited description"
    Then I follow "Cancel"
    Then I should not see "edited sample.txt"
    And I should not see "edited description"
    And I should see "sample.txt"

  Scenario: Validation errors - name
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I fill in "Name" with ""
    And I press "Update"
    Then I should see "Filename can't be blank"

  Scenario: Validation errors - file type
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I select "" from the select box for ""
    And I press "Update"
    Then I should see "Filename can't be blank"

  Scenario: Validation errors - experiment

  Scenario: Validation errors - end time before than start time