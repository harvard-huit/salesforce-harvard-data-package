@isTest
static void testInstallScript() {
  PostInstallScript postinstall = new PostInstallScript();
    Test.testInstall(postinstall, null);
    List<CronTrigger> a = [SELECT Id, CronExpression, CronJobDetail.Name, State, NextFireTime, PreviousFireTime, TimesTriggered 
    FROM CronTrigger 
    WHERE CronJobDetail.Name = 'Delete Old HUIT Logs'];
    System.assertEquals(a.size(), 1, 'Account not found');
  }