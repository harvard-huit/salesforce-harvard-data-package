global class PostInstallScript implements InstallHandler {
    global void onInstall(InstallContext context) {

        if(!isJobScheduled('Delete Old HUIT Logs')) {
            Integer desiredRetentionDays = 90; // default of 90 days
            DeleteOldLogsBatch batchJob = new DeleteOldLogsBatch(desiredRetentionDays);
            String cron = '0 0 1 * * ?'; // Every day at 1 AM
            System.schedule('Delete Old HUIT Logs', cron, batchJob);
        }
        
        // List of old HUDA jobs
        List<String> jobNames = new List<String>{
            'HUDJobSelfScheduleNameToUpdateContact',
            'HUDJobSelfNameToUpdateContactForEPPN',
            'HUDJobSelfScheduleNameToUpdateAccount',
            'HUDJobSelfScheduleName',
            'HedJobContactEmailUpdate',
            'HEDJobSelfScheduleAffiliation',
            'HILTJobSelfScheduleConstituent',
            'HUJobSelfContactAccountFieldUpdate',
            'Self Schedule Location Mapping',
            'Self Schedule Phone Mapping',
            'Self Schedule Email Mapping',
            'Self Schedule Address Mapping',
            'Self Schedule Name Mapping'
        };

        // Loop through each job name and attempt to delete it if it's scheduled
        for (String jobName : jobNames) {
            if(isJobScheduled(jobName)) {
                deleteExistingScheduledJob(jobName);
            }
        }

        deleteOrphanAffiliations();


    }

    private void deleteExistingScheduledJob(String jobName) {
        try {
            // Query for the scheduled job
            CronTrigger job = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE :jobName + '%' LIMIT 1
            ];
            
            // Delete the job if found
            if (job != null) {
                System.abortJob(job.Id);
            }
        } catch (QueryException e) {
            // Handle the exception. It's possible the job might not exist, which is okay.
            System.debug('Scheduled job not found or another error occurred: ' + e.getMessage());
        }
    }

    private Boolean isJobScheduled(String jobName) {
        List<CronTrigger> jobs = [
            SELECT Id FROM CronTrigger 
            WHERE CronJobDetail.Name = :jobName + '%' LIMIT 1
        ];
        return !jobs.isEmpty();
    }

    global void deleteOrphanAffiliations() {
        // Check if hed__Affiliation__c object exists at runtime
        if (Schema.getGlobalDescribe().containsKey('hed__Affiliation__c')) {
            
            // Dynamic Describe for hed__Affiliation__c
            Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get('hed__Affiliation__c').getDescribe();
            Map<String, Schema.SObjectField> fieldMap = describeResult.fields.getMap();
    
            // Check if HUDA__hud_ROLE_ID__c field exists in hed__Affiliation__c object
            if (fieldMap.containsKey('HUDA__hud_ROLE_ID__c')) {
                
                // Using dynamic SOQL to prevent compile-time error
                String soql = 'SELECT Id FROM hed__Affiliation__c WHERE hed__Contact__c = null AND HUDA__hud_ROLE_ID__c != null';
                List<SObject> affiliationsToDelete = Database.query(soql);
                    
                // Delete those records
                if (affiliationsToDelete.size() > 0) {
                    delete affiliationsToDelete;
                }
            } else {
                System.debug('Field HUDA__hud_ROLE_ID__c does not exist in hed__Affiliation__c object.');
            }
        } else {
            System.debug('Object hed__Affiliation__c does not exist.');
        }
    }
    

}
