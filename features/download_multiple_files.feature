Feature: Download multiple files
  In order to get hold of the data I'm interested in
  As a user
  I want to download multiple files from the explore data page

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt |
      | sample3.txt | 30/12/2011 12:34 | georgina@intersect.org.au |                  |                     | samples/sample3.txt |
    And I am on the list data files page

  
  Scenario: Download a selection of files as Zip
    I should see button "Add to Cart"
    When I add "sample1.txt" to the cart
    And I am on the list data files page
    Then I add "sample2.txt" to the cart
    And I click on "Download"
    Then I should receive a zip file matching "samples/zip"
  

  Scenario: Package a selection of files as a BagIt Zip
    I should see button "Add to Cart"
    When I add "sample1.txt" to the cart
    And I am on the list data files page
    Then I add "sample2.txt" to the cart
    And I click on "Package"
    Then I should receive a zip file matching "samples/bagit"
