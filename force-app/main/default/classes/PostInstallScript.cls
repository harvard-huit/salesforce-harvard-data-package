global class PostInstallScript implements InstallHandler {
    global void onInstall(InstallContext context) {
        
        try {
            System.debug('Scheduling Delete Old HUIT Logs batch job');
            Integer desiredRetentionDays = 7; // default of 7 days
            DeleteOldLogsBatch batchJob = new DeleteOldLogsBatch(desiredRetentionDays);
            String cron = '0 0 1 * * ?'; // Every day at 1 AM
            System.schedule('Delete Old HUIT Logs', cron, batchJob);
            System.debug('Scheduled Delete Old HUIT Logs batch job');
        } catch (Exception e) {
            System.debug('Unable to schedule Delete Old HUIT Logs batch job: ' + e.getMessage());
        }
        
        // List of old HUDA jobs
        List<String> jobNames = new List<String>{
            'HUDJobSelfScheduleNameToUpdateContact',
            'HUDJobSelfNameToUpdateContactForEPPN',
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
            deleteExistingScheduledJob(jobName);
        }

    }

    public void deleteExistingScheduledJob(String jobName) {
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
        } catch (Exception e) {
            System.debug('Error with deleting scheduled job: ' + e.getMessage());
        }
    }    

}
