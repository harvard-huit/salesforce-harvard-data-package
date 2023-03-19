# Salesforce DX Project: Harvard Data

This app is the staging package / app for data integration with Harvard Central systems, such as the Person Data Service (PDS).


## Development Help

This uses the Salesforce DX development paradigm. We will be using the `sfdx` command line interface: [https://developer.salesforce.com/tools/sfdxcli]


### Create a scratch org

You can either do development in a scratch org or in a sandbox. In order to create a scratch org, you need to have enabled a dev hub in a paid Salesforce Org. 

Under settings, search for `dev hub` in the filter. If it's not there, it's probably because you're trying to do it from a sandbox -- you can't make a sandbox into a dev hub. Once there, just click the enable. (Ignore the warning that says you can't undo it, I'm sure that won't have any consequences.)

Log in to the dev hub with:
```
sfdx auth:web:login -d -a DevHub
```
That will open your browser. Just log in to the org that you enabled the dev hub on. 


Then you can actually create the scratch org using the scratch definition in this repository.
```
sfdx force:org:create -s -f config/project-scratch-def.json -a HarvardDataScratch
```
This can take a few minutes. Be patient.


## More Help

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
