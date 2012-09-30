Feature: Save results by result place
  So that results can be calculated
  As an official
  I want to save results for different result places
  
  @javascript
  Scenario: Save estimates, shots, and arrival time
    Given I am an official
    And I have a race "Result race"
    And the race has a series "M" with first number 10 and start time "12:00"
    And the series has a competitor "Mikko" "Mallikas"
    And the race has correct estimates with attributes:
      | min_number | 10  |
      | max_number | 10  |
      | distance1  | 99  |
      | distance2  | 150 |
    And the start list has been generated for the series
    And I have logged in
    And I am on the official race page of "Result race"
    When I follow "Arviot"
    Then the "Toimitsijan sivut" main menu item should be selected
    And the "Arviot" sub menu item should be selected
    And I should see "Result race" within ".main_title"
    When I fill in "100" for "competitor_estimate1"
    And I fill in "149" for "competitor_estimate2"
    And I press "Tallenna"
    Then I should see "Tallennettu"
    When I follow "Ammunta"
    Then the "Toimitsijan sivut" main menu item should be selected
    And the "Ammunta" sub menu item should be selected
    And I should see "Result race" within ".main_title"
    When I fill in "99" for "competitor_shots_total_input"
    And I press "Tallenna"
    Then I should see "Tallennettu"
    When I follow "Ajat"
    Then the "Toimitsijan sivut" main menu item should be selected
    And the "Ajat" sub menu item should be selected
    And I should see "Result race" within ".main_title"
    When I fill in "12" for "competitor_arrival_time_4i"
    And I fill in "25" for "competitor_arrival_time_5i"
    And I fill in "41" for "competitor_arrival_time_6i"
    And I press "Tallenna"
    Then I should see "Tallennettu"
    When the race is finished
    And I go to the results page of the series
    Then I should see "300 (25:41)"
    And I should see "296 (+1m/-1m)"
    And I should see "594 (99)"
    
  @javascript
  Scenario: Prevent concurrent changes for same competitor's same estimate results
    Given I am an official
    And I have a race "Result race"
    And the race has a series "M" with first number 10 and start time "12:00"
    And the series has a competitor "Mikko" "Mallikas"
    And the start list has been generated for the series
    And I have logged in
    And I am on the official race page of "Result race"
    And I follow "Arviot"
    Given someone else saves estimates 100 and 150 for the competitor
    When I fill in "101" for "competitor_estimate1"
    And I fill in "151" for "competitor_estimate2"
    And I press "Tallenna"
    Then I should not see "Tallennettu"
    But I should see "Virhe"
    And I should see "Tälle kilpailijalle on syötetty samanaikaisesti toinen tulos. Lataa sivu uudestaan ja yritä tallentamista sen jälkeen."
    