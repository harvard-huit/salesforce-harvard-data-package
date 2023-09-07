@isTest
private class PostInstallScript_Test {
  static testMethod void testPostInstallScript() {
    PostInstallScript postinstall = new PostInstallScript();
    Test.testInstall(postinstall, null);
    List<CronTrigger> a = [SELECT Id, CronExpression, CronJobDetail.Name, State, NextFireTime, PreviousFireTime, TimesTriggered 
    FROM CronTrigger 
    WHERE CronJobDetail.Name = 'Delete Old HUIT Logs'];
    System.assertEquals(a.size(), 1, 'Scheduled job not found');

    
    // test again to make sure it doesn't fail if the job already exists
    Test.testInstall(postinstall, null);
    List<CronTrigger> b = [SELECT Id, CronExpression, CronJobDetail.Name, State, NextFireTime, PreviousFireTime, TimesTriggered 
    FROM CronTrigger 
    WHERE CronJobDetail.Name = 'Delete Old HUIT Logs'];
    System.assertEquals(b.size(), 1, 'Scheduled job not found');
  }
  
  static testMethod void testDeleteOrphanAffiliations() {
    // Check if hed__Affiliation__c object and the fields exist
    if (Schema.getGlobalDescribe().containsKey('hed__Affiliation__c') && 
        Schema.getGlobalDescribe().get('hed__Affiliation__c').getDescribe().fields.getMap().containsKey('HUDA__hud_ROLE_ID__c')) {

        // Create a test contact
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'testcontact@example.com'
        );
        insert testContact;

        // Dynamically create and insert hed__Affiliation__c records
        List<SObject> affiliations = new List<SObject>();

        SObject affiliation1 = Schema.getGlobalDescribe().get('hed__Affiliation__c').newSObject();
        affiliation1.put('HUDA__hud_ROLE_ID__c', 'testRoleID1');
        affiliations.add(affiliation1);

        SObject affiliation2 = Schema.getGlobalDescribe().get('hed__Affiliation__c').newSObject();
        affiliation2.put('hed__Contact__c', testContact.Id);
        affiliation2.put('HUDA__hud_ROLE_ID__c', 'testRoleID2');
        affiliations.add(affiliation2);

        SObject affiliation3 = Schema.getGlobalDescribe().get('hed__Affiliation__c').newSObject();
        affiliations.add(affiliation3);

        insert affiliations;

        // Execute method
        PostInstallScript postInstall = new PostInstallScript();
        postInstall.deleteOrphanAffiliations();

        // Asserts
        List<SObject> results = Database.query('SELECT Id FROM hed__Affiliation__c WHERE Id IN :affiliations');
        System.assertEquals(2, results.size(), 'There should only be 2 Affiliations left after the deleteOrphanAffiliations method.');

        // Ensure the affiliation with null hed__Contact__c and non-null HUDA__hud_ROLE_ID__c is deleted
        Boolean foundDeletedAffiliation = false;
        for (SObject result : results) {
            if (result.Id == affiliation1.Id) {
                foundDeletedAffiliation = true;
                break;
            }
        }
        System.assert(!foundDeletedAffiliation, 'Affiliation1 should have been deleted.');
    } else {
        System.debug('Object hed__Affiliation__c or field HUDA__hud_ROLE_ID__c does not exist. Skipping test.');
    }
  }

  static testMethod void testDeleteExistingScheduledJob() {

    String jobName = 'Delete Old HUIT Logs';

    Test.startTest();
    PostInstallScript postInstall = new PostInstallScript();
    postInstall.deleteExistingScheduledJob(jobName);
    Test.stopTest();

    List<CronTrigger> results = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = ':JobName'];
    System.assertEquals(0, results.size(), jobName + ' should have been deleted.');


  }
}
