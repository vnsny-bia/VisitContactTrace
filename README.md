
<img src="./inst/www/VNSNY_Horiz_Blue.png" width="300" align="right"/>


# VisitContactTrace 

This application is designed to conduct contact tracing on healthcare encounter data with a specific focus on providers of community-based healthcare delivery services.  In a community based healthcare system, patients are typically considered to be homebound and do not interact with each other.  The VisitContactTrace application provides advanced querying capabilities of a patient-clinician visit data set to allow the user to explore how infectious diseases may spread if appropriate precautions are not in place.  This application **does not suggest causality** , rather, a method to explore how infectious diseases may spread exponentially if no precautions are not put into place in a community-based healthcare setting.

This application allows the user to query their visit data from one of two different sources of origin if the case of origin is a patient/member or a healthcare provider (Nurse, Therapist, Social Worker, Home Health Aide, etc.).  The application assumes that the user knows who their indexed person is and presents levels of exposure in primary, secondary and tertiary contacts from the origin. 
<img src="./inst/www/VNSNYCT-hexsticker.png" width="150" align="right"/>


This application was designed and created by the Data Science team at the [Visiting Nurse Service of New York](https://www.vnsny.org/) during the COVID-19 pandemic to support contact tracing efforts to support operations across multiple community based health care organizations within the parent company.  This application may serve value to smaller agencies providing community-based healthcare in the applicaiton of contact tracing for any infectious disease.

To learn more about VNSNY COVID-19 response please visit [here](https://www.vnsny.org/coronavirus-covid-19/vnsnys-covid-19-response/). 

# Data 

The VisitContactTrace Application was built to support a common data structure often used in community-based healthcare settings for functions such as billing or documentation in the clinical record. The image below shows a snippet of an example dataset where _n_ clinicians have delivered visits to _p_ patients during February - May 2020. It is important to note that in this type of data, patients are never observed to encounter each other and the same is not observed for staff encountering each other. In community-based healthcare settings it is possible the staff can encounter each ether, but this type of dataset is not typically available as a part of the clinical record.

In this simulated example, Patient 4 was first visited by [Anna Caroline Maxwell](https://en.wikipedia.org/wiki/Anna_Maxwell) on February, 27, 2020, then [Lillian Wald](https://en.wikipedia.org/wiki/Lillian_Wald) continued the case visiting every 2-6 days from February, 29, 2020 to March, 31, 2020.

<img src="./inst/www/visithc.png" width="400" align="center"/>


## Data Specifiations

Please note that the contact tracing will not be accurate if there are any data integrity and completeness issues.  

The **VisitContactTrace** application requires a minimum set of fields in a data set meeting the following requirements:

| Column Name | Format | Required | Description |
| --------------- | --------------- | --------------- |----------------------------------------------------------------------------|
| PATIENT_ID | Character | FALSE | Unique identifier of patient.  If absent, Patient Name is used as the key|
| PATIENT_NAME | Character | TRUE | First and Last Name of patient* |
| VISIT_DATE | DATE | TRUE | The Date for Which the Patient encounter a Clincian |
| STAFF_ID | Character | FALSE | Unique ID for clinician.  If absent, Patient Name is used as the key |
| STAFF_NAME | Character | TRUE | First and Last Name of clinician*|
| PATIENT_STATUS | Character | FALSE | Patient Status for the patient, e.g. an indication of the presencen of an infectious disease
| STAFF_STATUS | Character | FALSE | Clinician Status for the patient, e.g. an indication of the presencen of an infectious disease

\* We antcipate that many users will have patient/clinician name in two columns (first & last).  Those users should consider concatenating those fields together prior to this step.

The order of columns does not matter.  PATIENT_NAME, STAFF_NAME, and VISIT_DATE are required fields where the name must be spelled exactly the same as specified here.  PATIENT_ID and STAFF_ID are highly recommended from a data source that treats these as a unique key that identifies a patient or staff.  When provided, these id's serve as the mechanism in which the algorithm conducts contact tracing.  This application relies on the integrity of these keys.  If either of these are not available, the application will assume that PATIENT_NAME and STAFF_NAME are the keys that unique identify a patient and staff, respectively.  Additional caution is warranted to address inconsistent spellings of the names contained in PATIENT_NAME and STAFF_NAME.


### Renaming

If the data uploaded does not have the names spelled as documented here. The GUI for uploading data will raise an error to the user when they try to submit, it also allows the user to rename fields to the correct spelling.  

Things to consider:

* Preprocessing of data should be carefully considered prior
  * Consider dropping records that don't represent a face-to-face encounter (e.g. filter out telephonic or telemedicine visits)
  * Do not inadvertenly exclude any face-to-face records that may be critical to the contact tracing

# VisitContactTrace R package

VisitContactTrace is an R package that requires the installation of the R software. For more information about R, please see the [R Project for Statistical Computing]( https://www.r-project.org/). For unexperienced R users please jump to [Help Getting Started with R](#helpR) for some additional assistance.  The R commands below should be typed/copy and pasted into the R Console.

The Visit Contact Trace application has been built for users to  **upload data manually.**  This application assumes the end user is extracting data from a standard report from the agency's electronic medical record application.  It should be saved as an *.xlsx or *.csv file and uploaded to the VisitContactTracing application.  More sophisticated users can addapt the source code to read datasets created from an ETL tool automatically.  


## VisitContactTrace R package installation

Copy and paste this line into the R Console to install the development version of **VisitContactTrace** from GitHub. Note that the code is case-sensitive, so it is important to preserve the upper and lower case letters:

```r
install.packages("VisitContactTrace", repos = "https://github.com/vnsny-bia/VisitContactTrace")
```


## Load the VisitContactTrace R package

Copy and paste this line (case-sensitive!) into the R Console to load the **VisitContactTrace** R package:

```r
library(VisitContactTrace)
```


## Run Application Locally

Type this command (case-sensitive) into the R Console to start the application:

```r
VisitContactTrace()
```


# Using the Applicaton

## GUI Interface for Importing Data

This should be the welcome screen that is displayed as soon as the application opens.  Click on "upload file" and browse to the dataset that you wish to import into the Visit Contact Tracing Application.  

<img src="./inst/www/ct-welcome.PNG" width="400" align="center"/>

The "Review Data" button provides a preview of the data import and the ability to rename columns to the data specifications. If column names and formats are correct, the "Submit Data" button will import the data into the application.  If not, the user will be notified of an error.

<img src="./inst/www/ct-preview.PNG" width="600" align="center"/>


## Other Usefull R Functions/Objects


There is a simulated Home Healthcare Visits dataset loaded with the R package for experimentation and instructional purposes.

```r
# head(visitshc, 10)
```

Given a visit based patient-staff encounter file, this function returns the primary, secondary, tertiary contacts (Rushabh can you expand here with the example)  

```r
getContacts(x,y,dt)
```

# Help Getting Started with R <a name="helpR"></a>

## Installation

VisitContactTrace is an R package that requires the installation of the R software.  To learn more, please visit the [R Project for Statistical Computing]( https://www.r-project.org/). 

If the R installation is successful a shortcut should have been created for easy access.  Click on that shortcut to open the R application.

## Open the R GUI application ###

### Windows environemnt 

In organizations that require administrative rights to install software, it is possible to install R in the users documents on a Windows OS without administrative rights.  You can find the **Rgui** executable in the tree which it was installed. Below are some examples of how this may look, click on RGui.exe to launch an R session.  If you will be using this application often, you may consider creating a shortcut on your desktop.


<img src="./inst/www/Ri386-image.PNG" width="400" align="center"/>

<img src="./inst/www/Rx64-image.png" width="400" align="center"/>

## R Console ##

In order to run the contact tracing application, you must copy and paste two commands into the R Console.  The R Console looks like the image below. It is here where you should write or paste the commands to install and run the VisitContactTrace application on your personal computer.

<img src="./inst/www/Rconsole-image.PNG" width="600" align="center"/>


## License
**VisitContactTrace** is released under [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), please see the license in this GitHub repository for additional disclaimers on the usage of this application. 

## Acknowledgments

* Nurse image used for the hex sticker <a href="http://cliparts.co/clipart/4411">cliparts.co</a>
