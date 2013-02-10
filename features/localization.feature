Feature: Localization
  In order to understand the service
  As a Swedish user
  I want to use the system in Swedish
  
  Scenario: Change language, change page, change the language again
    Given there is a base price 15
    And I am on the home page
    And I follow "På svenska"
    Then I should be on the Swedish home page
    And I should see "Tävlingar"
    And Finnish locale flag should be visible
    But Swedish locale flag should not be visible
    When I follow "Priser"
    Then I should see "Priser" within ".main_title"
    When I follow "Suomeksi"
    Then I should see "Hinnat" within ".main_title"
    And Swedish locale flag should be visible
    But Finnish locale flag should not be visible
        