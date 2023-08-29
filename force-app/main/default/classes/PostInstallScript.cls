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
            'Self Schedule HUJobSelfServiceNowUpdate',
            'Self Schedule HUSelfScheduledJobNewContactValid',
            'Self Schedule HUJobSelfServiceNowCleanup',
            'Self Schedule Phone Mapping',
            'Self Schedule Email Mapping',
            'Self Schedule Address Mapping',
            'Self Schedule Name Mapping',
            'Self Schedule HUJobSelfServiceNowUpdateForObjectList'
        };

        // Loop through each job name and attempt to delete it if it's scheduled
        for (String jobName : jobNames) {
            if(isJobScheduled(jobName)) {
                deleteExistingScheduledJob(jobName);
            }
        }


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



    
}
