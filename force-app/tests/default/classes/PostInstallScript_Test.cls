@isTest
private class PostInstallScript_Test {
  static testMethod void testPostInstallScript() {
    PostInstallScript postinstall = new PostInstallScript();
    Test.testInstall(postinstall, null);
    List<CronTrigger> a = [SELECT Id, CronExpression, CronJobDetail.Name, State, NextFireTime, PreviousFireTime, TimesTriggered 
    FROM CronTrigger 
    WHERE CronJobDetail.Name = 'Delete Old HUIT Logs'];
    System.assertEquals(a.size(), 1, 'Scheduled job not found');
  }
  
  static testMethod void testDeleteOrphanAffiliations() {
    // Create a test contact
    Contact testContact = new Contact(
        FirstName = 'Test',
        LastName = 'Contact',
        Email = 'testcontact@example.com' 
    );
    insert testContact;

    // Test data setup for hed__Affiliation__c

    // 1. Record with null hed__Contact__c and non-null HUDA__hud_ROLE_ID__c
    hed__Affiliation__c affiliation1 = new hed__Affiliation__c();
    affiliation1.HUDA__hud_ROLE_ID__c = 'testRoleID1';

    // 2. Record with valid hed__Contact__c and non-null HUDA__hud_ROLE_ID__c
    hed__Affiliation__c affiliation2 = new hed__Affiliation__c();
    affiliation2.hed__Contact__c = testContact.Id;
    affiliation2.HUDA__hud_ROLE_ID__c = 'testRoleID2';

    // 3. Record with null hed__Contact__c and null HUDA__hud_ROLE_ID__c
    hed__Affiliation__c affiliation3 = new hed__Affiliation__c();

    insert new List<hed__Affiliation__c>{affiliation1, affiliation2, affiliation3};

    // Execute method
    PostInstallScript postInstall = new PostInstallScript();
    postInstall.deleteInvalidAffiliations();

    // Asserts
    hed__Affiliation__c result1 = [SELECT Id FROM hed__Affiliation__c WHERE Id = :affiliation1.Id LIMIT 1];
    System.assert(result1 == null, 'Affiliation1 should have been deleted.');

    hed__Affiliation__c result2 = [SELECT Id FROM hed__Affiliation__c WHERE Id = :affiliation2.Id LIMIT 1];
    System.assertNotEquals(null, result2, 'Affiliation2 should not be deleted.');

    hed__Affiliation__c result3 = [SELECT Id FROM hed__Affiliation__c WHERE Id = :affiliation3.Id LIMIT 1];
    System.assertNotEquals(null, result3, 'Affiliation3 should not be deleted.');
  }
}
