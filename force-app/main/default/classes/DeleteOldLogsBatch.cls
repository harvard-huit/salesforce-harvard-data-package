global class DeleteOldLogsBatch implements Database.Batchable<sObject>, Schedulable {
    private Integer retentionDays;

    // Constructor to accept retention days
    public DeleteOldLogsBatch(Integer retentionDays) {
        this.retentionDays = retentionDays;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date thresholdDate = Date.today().addDays(-this.retentionDays);
        
        String query;
        if (Test.isRunningTest()) {
            query = 'SELECT Id FROM huit__Log__c WHERE huit__Datetime__c < :thresholdDate';
        } else {
            query = 'SELECT Id FROM huit__Log__c WHERE CreatedDate < :thresholdDate';
        }
        
        return Database.getQueryLocator(query);
    }
    



    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
    }

    // This is for the Schedulable interface
    global void execute(SchedulableContext SC) {
        DeleteOldLogsBatch batchJob = new DeleteOldLogsBatch(this.retentionDays);
        Database.executeBatch(batchJob);
    }
}
