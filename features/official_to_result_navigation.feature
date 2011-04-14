Feature: Navigation between official and result sections
  In order to save some clicks
  As an official
  I want to navigate easily and fast between official and result sections

  Scenario: Click races tab in main page
    Given there is a race with attributes:
      | name | Run race |
      | location | Running place |
      | start_date | 2010-08-18 |
    And there is a race with attributes:
      | name | Ski race |
      | location | Skiing place |
      | start_date | 2011-02-11 |
    And there is a race with attributes:
      | name | Third test race |
      | location | Test location |
      | start_date | 2011-01-09 |
      | end_date | 2011-01-10 |
    And I am on the home page
    When I follow "Kilpailut" within "div.menu"
    Then I should be on the races page
    And the "Kilpailut" main menu item should be selected
    And I should see "Hirviurheilu - Kilpailut" within ".main_title"
    And I should see "Run race, 18.08.2010, Running place"
    And I should see "Third test race, 09.01.2011 - 10.01.2011, Test location"
    And I should see "Ski race, 11.02.2011, Skiing place"
    When I follow "Ski race"
    Then I should be on the race page of "Ski race"

  Scenario: Quick navigation from result pages to official summary page
    Given I am an official
    And I have a race "My race"
    And I have logged in
    When I am on the race page
    And I follow "My race" within "div.menu"
    Then I should be on the official race page of "My race"
