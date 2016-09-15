@public
Feature: Explore Groups
  Background:
    Given group "TestGroup" has private project "Enterprise"

  Scenario: I should see group with private and internal projects as user
    Given group "TestGroup" has internal project "Internal"
    When I sign in as a user
    And I visit group "TestGroup" page
    Then I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group issues for internal project as user
    Given group "TestGroup" has internal project "Internal"
    When I sign in as a user
    And I visit group "TestGroup" issues page
    Then I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group merge requests for internal project as user
    Given group "TestGroup" has internal project "Internal"
    When I sign in as a user
    And I visit group "TestGroup" merge requests page
    Then I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group with private, internal and public projects as visitor
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I visit group "TestGroup" page
    Then I should see project "Community" items
    And I should not see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group issues for public project as visitor
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I visit group "TestGroup" issues page
    Then I should see project "Community" items
    And I should not see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group merge requests for public project as visitor
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I visit group "TestGroup" merge requests page
    Then I should see project "Community" items
    And I should not see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group with private, internal and public projects as user
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I sign in as a user
    And I visit group "TestGroup" page
    Then I should see project "Community" items
    And I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group issues for internal and public projects as user
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I sign in as a user
    And I visit group "TestGroup" issues page
    Then I should see project "Community" items
    And I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group merge requests for internal and public projects as user
    Given group "TestGroup" has internal project "Internal"
    Given group "TestGroup" has public project "Community"
    When I sign in as a user
    And I visit group "TestGroup" merge requests page
    Then I should see project "Community" items
    And I should see project "Internal" items
    And I should not see project "Enterprise" items

  Scenario: I should see group with public project in public groups area
    Given group "TestGroup" has public project "Community"
    When I visit the public groups area
    Then I should see group "TestGroup"

  Scenario: I should see group with public project in public groups area as user
    Given group "TestGroup" has public project "Community"
    When I sign in as a user
    And I visit the public groups area
    Then I should see group "TestGroup"

  Scenario: I should see group with internal project in public groups area as user
    Given group "TestGroup" has internal project "Internal"
    When I sign in as a user
    And I visit the public groups area
    Then I should see group "TestGroup"

  Scenario: I visit public area
    Given private group "TestGroup"
    And I sign in as a user
    When I visit the public groups area
    Then I should not see group "TestGroup"

  Scenario: I visit public area as an auditor
    Given private group "TestGroup"
    And I sign in as an auditor
    When I visit the public groups area
    Then I should see group "TestGroup"
