# Salesforce DX Project: Harvard University Data (HUD)

This is a Salesforce Second Generation Package. It is meant to be a package to help pattern how University data is stored in various Salesforce instances around the University.

This repository should get you set up with being able to deploy the HUD package. This package does NOT deliver data. It relies on data to be pushed from the [HUIT/salesforce-person-updates](https://github.huit.harvard.edu/HUIT/salesforce-person-updates) project.

<details>
<summary>Old HUDA and EDA Information</summary>

Please see [this project](https://github.huit.harvard.edu/HUIT/salesforce-huda-package) for more information on HUDA and EDA, the precursor packages to this.

</details>

## Installation Instructions

Installation is currently done through linking to a versioned package (details on the below). The current installation url should be found in the most recent [release](https://github.huit.harvard.edu/HUIT/salesforce-harvard-data-package/releases). 

### What is Installed

#### Log Object

`huit__Log__c` ("HUIT Log") is a new object. This will be populated with logs coming from the python component ([HUIT/salesforce-person-updates](https://github.huit.harvard.edu/HUIT/salesforce-person-updates)) of this service. 

#### Contact Additions

 - `Contact.huit__Pronouns__c` ("HUIT Pronouns") is a free-form text field populated with the newly available pronouns available through the PDS.
 - `Contact.huit__Updated__c` ("HUIT Updated") is a `checkbox`/`boolean` field populated with `true` when the Contact is available through the currenlt instance's person visibility. 

#### Post Install Apex

This is mainly to start the cleanup action for `huit__Log__c`. Logs older than 30 days are removed. This can be stopped in Scheduled Jobs, however, if there isn't a cleanup, this will fill up "forever". 

The post install will also removed old HUDA Scheduled Jobs. 

<details>

<summary>
HUDA Scheduled Jobs List
</summary>

 - `HUDJobSelfScheduleNameToUpdateAccount`
 - `HedJobContactEmailUpdate`
 - `HILTJobSelfScheduleConstituent`
 - `HUJobSelfContactAccountFieldUpdate`
 - `Self Schedule Location Mapping`
 - `Self Schedule HUJobSelfServiceNowUpdate`
 - `Self Schedule HUSelfScheduledJobNewContactValid`
 - `Self Schedule HUJobSelfServiceNowCleanup`
 - `Self Schedule Phone Mapping`
 - `Self Schedule Email Mapping`
 - `Self Schedule Address Mapping`
 - `Self Schedule Name Mapping`

</details>

#### Uninstall Apex

This is just a cleanup for the Log cleanup Scheduled Job. 

## Namespace: `huit`

The Namespace Org is a Developer Org that controls the use of the `huit` namespace, which is a prefix added to all custom components (objects, classes, fields, etc) contained in the package. 

This cannot be (easily) transferred to other orgs and only one namespace can be assigned to each org.

This also cannot also act as a Dev Hub for package management and development. It is impossible to assign a namespace and enable Dev Hub settings on the same org. Both are needed for development.

<details>
<summary>Note on Namespace and Package case</summary>

There is no defined best practice for case on either namespace or package, however the choices were made based on what the general population seems to be using. For Namespaces, Salesforce documentation (and the majority of existing namespaces) go with lowercase and for Packages, documentation tends to go with CamelCase. Since "HUD" is an acronym, it made sense to make it all caps. 

</details>

### Namespace Details

 - Host: `harvarduniversity68-dev-ed.develop.my.salesforce.com`
 - User: `huit_namespace@harvard.edu`

## Dev Hub Details

 - Host: `https://harvarduniverstiy-dev-ed.develop.my.salesforce.com`
 - User: `hud_package@harvard.edu`

## Development Setup Steps

NOTE: This is a "second generation package", which generally means development and deployment are done through the sfdc-cli, available [here](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm).

NOTE: You can see what orgs your sfdx environment is currently using with `sf org:list`. That will show your dev hub and any sandboxes or scratch orgs. 

### 1. Create a Dev Hub from a Developer org
- a. sign up for a developer org, these are free and unaffiliated with your other orgs
- b. turn on Dev Hub under settings -> Development -> Dev Hub
- c. wait like 20 minutes

### 2. Register the Namespace

This is only needed if the project uses a namespace -- the HUDA project does use the HUDA namespace. 
- a. log in to the Dev Hub Developer Org
- b. navigate to the Namespace Registry (this will only show if the Dev Hub is enabled and you've waited long enough)
- c. Link Namespace and log in to a registry holder, in this case it would be the `hudapackage1@harvard.edu` (or another linked account) user and accept

### 3. Create a scratch org
a. designate a dev hub
```
sfdx org:login:web -d -a DevHub
```
The dev hub should be a Developer Org. It can't be a sandbox. 

Note: you can use `sfdx org:list` to see what you currently have available. You should see a `(D)` next to the Dev Hub you've logged in to.

b. create a new local project (or use an existing one (like this project) and skip this)
```
sfdx force:project:create -n "name of project"
```

c. create scratch org
```
sf org create scratch -f config/project-scratch-def.json -a HarvardDataScratch
```

Note: this can take 2-10 minutes

If you want to switch your default target org:
```
sf config set target-org=HarvardDataScratch
```

#### Generate or display a password (optional)
This may be needed to log into a scratch org, but is not strictly necessay. (`sf org:open` should also be usable for this)
```
sf force:user:password:generate --target-org HarvardDataScratch
```

You can also get the password if it exists with:
```
sf org:display -target-org <username or alias of scratch org>
```

### 4. Install HUD from your local to your scratch org:
```
sf project:deploy:start --sourcepath . --targetusername <org username or alias>
```
This will move all of the meta data and create the objects/classes over as though it was installed. 

This is the way things get compiled, you'll get the compile errors from doing this and be able to debug (if there are any). 

You can check what packages are installed in the org with this command:
```
sf package:installed:list --target-org HarvardDataScratch
```

You may need to delete the existing hud due to conflicts. This is best done through the Salesforce interface, settings -> installed packages, but you can use:
```
sf package:uninstall --target-org HarvardDataScratch --package <package id>
```

#### Error with installing packages: `resource not found`

"Enable Unlocked Packages and Second-Generation Managed Packages" is an option under "enable dev hub" and must be selected for any package management to work from `sfdx`. An `sfdx` package is considered a 2nd gen managed package.

<details>
<summary>Create an unlocked package</summary>

You can also create an "unlocked" package. These are useful as they allow people to meddle with them a little more freely. Deployed versions allow you to view and change the Apex code. They are not namespaced and this is mostly just a way to do debugging in development. 

```
sf package create --name HUD --description "HUD Unlocked" --package-type Unlocked --path force-app --target-dev-hub DevHub
```

That package can then be seen by doing a `sf package:list` command and it can be deployed with:
```
sf package install --package 0Ho... --target-org HarvardDataScratch
```
</details>

## Deployment Instructions

<details>
<summary>Create an *Unversioned* Managed package</summary>

This is generally unnecessay (moving forward). 

A managed package created this way (without versioning it) will create a reference to a package that won't be available through Salesforce. This package cannot be installed, but is needed as a base package for further versioned packages. This was needed the first time the package was created.

```
sf package create --name HUD --description "HUD Managed" --path force-app --package-type Managed --target-dev-hub DevHub
```

</details>

### Create an Unlocked Package

This can be useful in development/testing phases as Versioned Managed packages have a daily build limit. These are specifically useful for testing post install or uninstall scripts.

```
sf package create --name HUDX --description "HUD Unlocked" --path force-app --package-type Unlocked --target-dev-hub DevHub
```

This will produce an 0Ho id. Install the package:
```
sf package install --package 0Ho... --target-org Connector --target-dev-hub DevHub --wait 10 
```


### Get the current package id

This command will query what's on your (default) Dev Hub. You can use it to make sure the ancestors in your `packageAliases` match up to what's on the Dev Hub. They don't have to all match up, just the ones referenced in the packages/ancestors.
```
sf package list
```
and
```
sf package version list
```

### Ancestors

When making a new version to this package, ancestors should be used if at all possible. 

<details>
<summary>Ancestors Details</summary>

Using `ancestorVersion` and setting it to "HIGHEST" is the preferrable way to declare a new version. However, if that does not work, you can use `ancestorId` and set it to the alias listed in `packageAliases` (or the direct `04t` id, but aliasing is preferred). 

```
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true,
      "package": "hud",
      "versionName": "v1.0.0",
      "versionNumber": "1.0.0.NEXT",
      "ancestorVersion": "HIGHEST"
    }
  ],
  "name": "HUD",
  "namespace": "huit",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "58.0",
  "packageAliases": {
    "hud": "0Ho...",
    "hud@1.0": "04t..."
    "hud@2.0": "04t..."
  }
}
```


</details>

### Creating a (Beta) Versioned Package:
A versioned package will push the package to a salesforce cloud location that can be retrieved by consumers with a link.

```
sf package version create --path force-app --installation-key test1234 --wait 10 --target-dev-hub DevHub
```
```
sf package version create --path force-app --installation-key-bypass --wait 10 --target-dev-hub DevHub
```

This can take up to 10 minutes.

NOTE: the installation key is a password added to the package so not anyone can install it. We don't generally need to use it.

This can then be installed using the link that is given to you, something like: 
```
https://test.salesforce.com/packaging/installPackage.apexp?p0=04t...
```

#### Promote a Beta Version

By default, creating a version results in a Beta (unreleased) version. Beta versions are not upgradable and must be deleted from the Salesforce instance in order to be changed. (Never install a Beta version in a production org.)

In order to create a release version, after testing is done on the Beta version, use this command:
```
sf package version promote --package 04t...
```

#### Testing

In order to promote, the test coverage needs to be at least 75%. 

In order to test, the best way is to:
 - Create a scratch org: `sf org create scratch -f config/project-scratch-def.json -a HarvardDataScratch`
 - Push source code to the scratch org: `sf project deploy start`
   - (this will tell you if there's any errors)
 - Run tests: `sf apex run tests --synchronous --code-coverage`
   - (this will tell you the total code coverage)

Only after the coverage reaches 75% will the `sf package version promote` command work.


### Updating the Package Description 

```
sf package update --description "Harvard University Data Package. Central IT (HUIT) delivered data." --package HUD
```

## Dependencies

We're not using any dependencies currently, but if we need to add some in the future, this section exists. Dependencies can be used to add fields to other packages.

They can also be used to extend this package if the Dev Hub is somehow lost, although ancestors should be used when making changes to this/any package. 

<details>
<summary>Dependency Info</summary>

If you don't have the package id, you can get the package id from an org:
```
sf package:installed:list --target-org DevHub
```

Then add the `04t` package id to the aliases in the project config, an example would be how the old HUDA looked: 

```
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true,
      "package": "hud",
      "versionName": "v2.0",
      "versionNumber": "2.0.NEXT",
      "dependencies": [
        {
          "package": "EDA"
        }
      ]    
    }
  ],
  "name": "HUD",
  "namespace": "huit",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "57.0",
  "packageAliases": {
    "EDA": "04t...",
    "hud": "0Ho...",
    "hud@2.0": "04t..."
  }
}
```
The two parts that are important are:
 - the dependencies, with the package "name"
 - the package Aliases, that define the exact version id of the package


</details>


## More Help

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
