@isTest
private class UninstallScript_Test {

    @isTest
    static void testUninstallScheduledJobDeletion() {
        // Arrange
        DeleteOldLogsBatch sch = new DeleteOldLogsBatch(30);
        String cron = '0 0 1 * * ?'; // Every day at 1 AM
        System.schedule('Delete Old HUIT Logs', cron, sch);
        
        // Act
        Test.startTest();
        UninstallScript uninstall = new UninstallScript();
        Test.testUninstall(uninstall, false);
        Test.stopTest();
        
        // Assert
        List<CronTrigger> jobsAfterUninstall = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime 
            FROM CronTrigger 
            WHERE CronJobDetail.Name LIKE 'Delete Old HUIT Logs%'
        ];
        
        System.assertEquals(0, jobsAfterUninstall.size(), 'All Scheduled jobs should be deleted');
    }

    @isTest
    static void testUninstallWithNoScheduledJob() {
        // Act
        Test.startTest();
        UninstallScript uninstall = new UninstallScript();
        Test.testUninstall(uninstall, false);
        Test.stopTest();
        
        // Assert : Simply checking that no exception was thrown, 
        // as there are no scheduled jobs to delete in this case
        System.assert(true, 'No exception should be thrown when there are no jobs to delete');
    }
}
