@isTest
private class DeleteOldLogsBatch_Test {
    
    @testSetup
    static void setupTestData() {
        // Create a list of log records
        List<huit__Log__c> logs = new List<huit__Log__c>();
        
        // Create 5 logs that are older than 30 days
        for (Integer i = 0; i < 5; i++) {
            logs.add(new huit__Log__c(
                huit__Datetime__c = System.now().addDays(-31)
                // ... set other necessary fields
            ));
        }
        
        // Create 5 logs that are newer than 30 days
        for (Integer i = 0; i < 5; i++) {
            logs.add(new huit__Log__c(
                huit__Datetime__c = System.now().addDays(-29)
                // ... set other necessary fields
            ));
        }
        
        // Insert the logs
        insert logs;
    }

    @isTest
    static void testBatchJob() {
        // Define the retention period as 30 days
        Integer retentionDays = 30;
        
        // Execute the batch job
        Test.startTest();
        DeleteOldLogsBatch batchJob = new DeleteOldLogsBatch(retentionDays);
        ID batchProcessId = Database.executeBatch(batchJob);
        Test.stopTest();
        
        // Query the remaining logs in the database
        List<huit__Log__c> remainingLogs = [SELECT Id FROM huit__Log__c];
        
        // Assert that the batch job deleted logs older than 30 days, leaving 5 logs that are newer
        System.assertEquals(5, remainingLogs.size(), 'The batch job did not delete the expected number of logs.');
    }

    @isTest
    static void testSchedulableJob() {
        // Define the retention period as 30 days
        Integer retentionDays = 30;
        
        // Schedule the batch job to run
        Test.startTest();
        String cron = '0 0 1 * * ?'; // Every day at 1 AM
        DeleteOldLogsBatch schedulableJob = new DeleteOldLogsBatch(retentionDays);
        System.schedule('DeleteOldLogsScheduledTest', cron, schedulableJob);
        Test.stopTest();
        
        // Query for the scheduled job
        List<CronTrigger> scheduledJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'DeleteOldLogsScheduledTest'];
        
        // Assert that the job has been scheduled
        System.assertEquals(1, scheduledJobs.size(), 'The batch job was not scheduled as expected.');
    }
}
