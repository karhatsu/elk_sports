Feature: Pricing
  In order to see how much the service costs
  As a (potential) customer
  I want to see the prices of the service

  Scenario: Show prices
    Given there is a base price 15
    And there is a price "3" for min competitors 1
    And there is a price "2.50" for min competitors 50
    And there is a price "1" for min competitors 100
    And I am on the home page
    When I follow "Hinnat"
    Then I should be on the prices page
    And the "Hinnat" main menu item should be selected
    And I should see "Hinnat" within ".main_title"
    And I should see "Perushinta: 15.00 euroa"
    And I should see "1-49 kilpailijaa: 3.00 euroa / kilpailija"
    And I should see "50-99 kilpailijaa: 2.50 euroa / kilpailija"
    And I should see "100- kilpailijaa: 1.00 euro / kilpailija"
    And I should see "Kaikki hinnat sisältävät 23 % arvonlisäveroa."
