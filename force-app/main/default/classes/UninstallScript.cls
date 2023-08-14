global class UninstallScript implements UninstallHandler {

    global void onUninstall(UninstallContext context) {
        deleteScheduledJob('Delete Old HUIT Logs');
    }

    private void deleteScheduledJob(String jobNamePrefix) {
        try {
            // Query for the scheduled jobs that start with the given prefix
            List<CronTrigger> jobs = [
                SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                FROM CronTrigger 
                WHERE CronJobDetail.Name LIKE :jobNamePrefix + '%'
            ];
            
            // Abort the jobs if found
            if (!jobs.isEmpty()) {
                for (CronTrigger job : jobs) {
                    System.abortJob(job.Id);
                }
            }
        } catch (QueryException e) {
            // Handle the exception. It's possible the job might not exist.
            System.debug('Error for jobs starting with ' + jobNamePrefix + ': ' + e.getMessage());
        }
    }
}
