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
