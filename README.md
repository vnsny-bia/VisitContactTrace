
<img src="./inst/www/VNSNY_Horiz_Blue.png" width="300" align="right"/>


# VisitContactTrace 

This application is designed to conduct contact tracing on healthcare encounter data with a specific focus on providers of community-based healthcare delivery services.  In a community-based healthcare system, patients are typically homebound and are visited at home by healthcare providers, meaning that while direct contact occurs between patients and visit staff, very little to no direct contact would occur between patients. This is in direct contrast with facility-based healthcare (e.g. hospitals, clinics) where patients travel to a central location that serves several patients at a time, and thus direct contact can occur between patients and staff as well as patient-to-patient.  The VisitContactTrace application allows the user to load and query their visit data in order to:

* explore how infectious diseases may spread within their visit-based service delivery model if appropriate precautions are not in place; 

* conduct visit-based contact tracing of the primary, secondary, and tertiary contacts of an "index" patient or visit staff member whose disease status is known to the user.

This application **does not suggest causality** or confirm disease transmission routes.  Rather, it provides a means to explore how infectious diseases may spread expotentially among patients and visit staff if precautions are not put into place in a visit-based service delivery model such as a community-based healthcare setting.

<img src="./inst/www/VNSNYCT-hexsticker.png" width="150" align="right"/>


The VisitContactTrace application was designed and created by the Data Science team at the [Visiting Nurse Service of New York](https://www.vnsny.org/) during the COVID-19 pandemic in order to support the organization's contact tracing efforts.  This application may be of value to other agencies providing community-based healthcare or to organizations that have visit-based service delivery models for the purpose of contact tracing of any infectious disease.

To learn more about VNSNY COVID-19 response please visit [here](https://www.vnsny.org/coronavirus-covid-19/vnsnys-covid-19-response/). 

# Run the VisitContactTrace Application

VisitContactTrace is an R package that requires the installation of the R software. For more information about R, please see the [R Project for Statistical Computing]( https://www.r-project.org/). For unexperienced R users please jump to [Help Getting Started with R](#helpR) for some additional guidance.  The R commands below should be typed/coppied and pasted into the R Console.

The Visit Contact Trace application has been built for users to  **upload data manually.**  This application assumes the end user is extracting data from a standard report from the agency's electronic medical record application.  It should be saved as an *.xlsx or *.csv file and uploaded to the VisitContactTracing application.  More sophisticated users can adapt the source code to read datasets created from an ETL tool automatically.  [Plese see more on the data specifications](#dataspec)


## VisitContactTrace R package installation

Copy and paste this line into the R Console to install the development version of **VisitContactTrace** from GitHub:

```r
install.packages("VisitContactTrace", repos = "https://github.com/vnsny-bia/Visit-Contact-Tracing")
```

## Run Application Locally

Type this command into the R Console and the application should run

```r
VisitContactTrace()
```

# Data 

The Visit Contact Tracing Application was built to support a common data structure often used in community-based healthcare settings for functions such as billing and documentation in the clinical record. This data structure represents the unique environment of community-based care is the motivation for creating this application. Most contact tracing applications assume all individuals have the potential to encounter all other individuals. In a community-based healthcare setting, patients are usually homebound and are never observed to encounter each other nor do the staff. It is possible for staff to encounter each other, but these types of data are rarely embedded in a healthcare administrative record. In this visit-based application of contact tracing, the clinician in the community-based healthcare setting is the focus potential vectors of exposure to other homebound patients (if no precautions are made to protect clinicians and patients from infectious diseases). The authors acknowledge that the application of this type of contact tracing is not limited to community-based healthcare settings.

The image below shows a snippet of an example dataset where _n_ clinicians have delivered _n_ x _p_ visits to _p_ patients during an observation window of February - May 2020. In this simulated example, Patient 4 was first visited by [Anna Caroline Maxwell](https://en.wikipedia.org/wiki/Anna_Maxwell) on February, 27, 2020, then [Lillian Wald](https://en.wikipedia.org/wiki/Lillian_Wald) continued the case visiting every 2-6 days from February, 29, 2020 to March, 31, 2020.

<img src="./inst/www/visithc.png" width="400" height="400" align="center"/>

## Data Specifiations <a name="dataspec"></a>

Please note that the contact tracing will not be accurate if there are any data integertity and completeness issues.  Please take this inconplete list of items to consider:

Please note that the contact tracing will not be accurate if there are any data integrity and completeness issues. Please take this incomplete list of items to consider:

* Preprocessing of data should be carefully considered prior
  * Consider dropping records that don’t represent a face-to-face encounter (e.g. filter out telephonic or telemedicine visits)
* Do not inadvertently exclude any face-to-face records that may be critical to the contact tracing
  * The time period of which the data was extracted should fully encapsulate any querying windows of time during the contact tracing

  
The **VisitContactTracing** application requires a minimum set of fields in a data set meeting the following requirements:

| Column Name | Format | Required | Description |
| --------------- | --------------- | --------------- |----------------------------------------------------------------------------|
| PATIENT_ID | Character | FALSE | Unique identifier of patient.  If absent, **PATIENT_NAME** is used as the key|
| PATIENT_NAME | Character | TRUE | First and last name of patient* |
| VISIT_DATE | DATE | TRUE | The date for which the patient encounters a clincian |
| STAFF_ID | Character | FALSE | Unique ID for clincian.  If absent, **STAFF_NAME** is used as the key |
| STAFF_NAME | Character | TRUE | First and last Name of clincian*|
| PATIENT_STATUS | Character | FALSE | A single unique label maybe used to indicate a **patient** who is confirmed with an infectious disease.  This label must persist over all visit observations for the **patient**.  The application only supports one label at this time and does not consider the time relationship between the status of one individual compared to the timing of statuses of other contacts; it is only provided as label of an individual
| STAFF_STATUS | Character | FALSE | A single unique label maybe used to indicate a **staff** who is confirmed with an infectious disease.  This label must persist over all visit observations for the **staff**.  The application only supports one label at this time and does not consider the time relationship between the status of one individual compared to the timing of statuses of other contacts; it is only provided as label of an individual

\* The authors antcipate that many users may have patient/clinician name in two columns (first & last).  Those users should consider concatenating those fields together prior to this step.

The order of columns does not matter. PATIENT_NAME, STAFF_NAME, and VISIT_DATE are required fields where the name must be spelled the same as specified here. If other fields are not named exactly as documented here, the application will ignore. PATIENT_ID and STAFF_ID are highly recommended from a data source that treats these as a unique key that identifies a patient or staff. When provided, these id’s serve as the mechanism in which the algorithm conducts contact tracing. This application relies on the integrity of these keys. If either of these are not available, the application will assume that PATIENT_NAME and STAFF_NAME are the keys that unique identify a patient and staff, respectively. Additional caution is warranted to address inconsistent spellings of the names contained in PATIENT_NAME and STAFF_NAME.

### Renaming

If the data uploaded does not have the names spelled as documented here. The user interface for uploading data will raise an error to the user when they try to submit.  It also allows the user to rename fields to the correct spelling in the user inteface.  


# Using the Application

## Graphical User Interface for Importing Data

The following figure should be the welcome screen that appears as soon as the application opens.  Click on "upload file" and browse to the dataset that you wish to import into the Visit Contact Tracing Application.  

<img src="./inst/www/ct-welcome.PNG" width="400" height="400" align="center"/>

The "Review Data" button provides a preview of the data import and the ability to rename columns to the names defined in [data specifications](#dataspec). If column names and formats are correct, the "Submit Data" button will import the data into the application.  If not, the user will be notified of an error.

<img src="./inst/www/ct-preview.PNG" width="500" height="600" align="center"/>

## Patient or Staff?

The first imporant decision to make is to decide what type of individual they would like to anchor the contact trace query.  The available options available are 

## Parameter Interface

The parameter interface provided contain the key elements for the user to conduct a visit-based contact trace query


## Other Usefull R Functions/Objects


There is a simulated Home Healthcare Visits dataset loaded with the R package for experimentation and instructional purposes.

```r
# head(visitshc, 10)
```

Given a visit based patient-staff encounter file, this function returns the primary, secondary, teriary contacts (Rushabh can you expand here with the example)  

```r
getContacts(x,y,dt)
```
# Help Getting Started with R <a name="helpR"></a>

## Installation

VisitContactTrace is an R package that requires the installation of the R software.  To learn more, please visit the [R Project for Statistical Computing]( https://www.r-project.org/). 

If the R installation is successful a shortcut should have been created for easy access.  Click on that shortcut to open the R application.

## Open the R Graphical User Interface application ###

### Windows environemnt 

In organizations that require administrative rights to install software, it is possible to install R in the users documents on a Windows OS without administrative rights.  You can find the **Rgui** executable in the tree which it was installed. Below are some examples of how this may look, click on RGui.exe to launch an R session.  If you will be using this application often, you may consider creating a shortcut on your desktop.


<img src="./inst/www/Ri386-image.PNG" width="600" align="center"/>

<img src="./inst/www/Rx64-image.png" width="600" align="center"/>

## R Console ##

In order to run the contact tracing application, you must copy and paste two commands into the R Console.  The R Console looks like the image below. It is here where you should write or paste the commands to install and run the VisitContactTrace application on your personal computer.

<img src="./inst/www/Rconsole-image.PNG" width="800" align="center"/>


## License
**VisitContactTrace** is released under [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), please see the license in this GitHub repository for additional disclaimers on the usage of this application. 

## Acknowledgments

* Nurse image used for the hex sticker <a href="http://cliparts.co/clipart/4411">cliparts.co</a>
