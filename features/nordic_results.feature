Feature: Nordic results
  In order to see how I did in a nordic race
  As a competitor
  I want to see the nordic race results

  Scenario: Show nordic race results
    Given there is a "NORDIC" race "Nordic test race"
    And the race has series "M"
    And the series has a competitor "Pekka" "Pohjola" with nordic results 24, 20, 99, 100
    And the series has a competitor "Pertti" "Pohjonen" with nordic results 25, 21, 90, 92
    And the race has series "N"
    And the series has a competitor "Päivi" "Pohjoinen" with nordic results 21, 25, 100, 96
    And I am on the race page of "Nordic test race"
    When I follow "Tulokset"
    Then I should see a card 1 for "Pohjola Pekka" with total score 375
    And I should see "Trap: 24 Compak: 20 Hirvi: 99 Kauris: 100" in result card 1 detail row 2
    And I should see a card 2 for "Pohjonen Pertti" with total score 366
    And I should see "Trap: 25 Compak: 21 Hirvi: 90 Kauris: 92" in result card 2 detail row 2
    When I follow "Trap"
    Then I should see a card 1 for "Pohjonen Pertti" with total score 25
    And I should see a card 2 for "Pohjola Pekka" with total score 24
    And I should see a card 3 for "Pohjoinen Päivi" with total score 21
    When I choose "Compak" from sub menu
    And I should see a card 1 for "Pohjoinen Päivi" with total score 25
    Then I should see a card 2 for "Pohjonen Pertti" with total score 21
    And I should see a card 3 for "Pohjola Pekka" with total score 20
    When I choose "Hirvi" from sub menu
    And I should see a card 1 for "Pohjoinen Päivi" with total score 100
    Then I should see a card 2 for "Pohjola Pekka" with total score 99
    And I should see a card 3 for "Pohjonen Pertti" with total score 90
    When I choose "Kauris" from sub menu
    And I should see a card 1 for "Pohjola Pekka" with total score 100
    Then I should see a card 2 for "Pohjoinen Päivi" with total score 96
    And I should see a card 3 for "Pohjonen Pertti" with total score 92
