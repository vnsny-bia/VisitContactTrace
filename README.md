
<img src="./inst/www/VNSNY_Horiz_Blue.png" width="300" align="right"/>


# VisitContactTrace 

This application is designed to conduct contact tracing on healthcare encounter data with a specific focus on providers of community-based healthcare delivery services.  In a community-based healthcare system, patients typically are homebound and are visited at home by healthcare providers.  Thus, while direct contact occurs between patients and visit staff, there is no direct contact between patients. This is in contrast with facility-based healthcare (e.g. hospitals, clinics) settings, where patients travel to a central geographic location at which healthcare services are delivered to several patients at a time, and where direct patient-to-patient, patient-to-staff, and staff-to-staff contact can occur.  The VisitContactTrace application allows the user to load and query their visit data in order to:

* explore how infectious disease might spread within a visit-based service delivery model if appropriate precautions are not in place; 

* conduct visit-based contact tracing of the primary, secondary, and tertiary contacts of an "index" patient or visit staff member whose disease status is known to the user.

This application **does not suggest causality** or confirm disease transmission routes.  Rather, it provides a means to explore how infectious disease may spread expotentially among patients and visit staff if precautions are not put into place in a visit-based service delivery model such as a community-based healthcare setting.

<img src="./inst/www/VNSNYCT-hexsticker.png" width="150" align="right"/>


The VisitContactTrace application was designed and created by the Data Science team at the [Visiting Nurse Service of New York](https://www.vnsny.org/) during the COVID-19 pandemic in order to support the organization's contact tracing efforts.  This application may be of value to other agencies providing community-based healthcare or to organizations that have visit-based service delivery models for the purpose of contact tracing of any infectious disease.

Learn more about VNSNY's COVID-19 response [here](https://www.vnsny.org/coronavirus-covid-19/vnsnys-covid-19-response/). 

# Running the VisitContactTrace Application

VisitContactTrace is an R package that requires R, an open-source software, to be installed. For more information about R, visit the [R Project for Statistical Computing](https://www.r-project.org/). Inexperienced R users can jump to [Help Getting Started with R](#helpR) for additional guidance.  

The VisitContactTrace application allows users to **upload data manually.**  For example, a user may have access to a data extract from a standard report of service encounters from their organization's electronic medical record system. The user can save this data file as an *.xlsx or *.csv file and upload it to the VisitContactTrace application.  More sophisticated R users can adapt the source code to read in datasets created from an ETL tool or incorporate the code into a data workflow.  [More on the data specifications](#dataspec)


## Installing the VisitContactTrace R package

The following code must be run the first time you use VisitContactTrace (unless you switch versions of R, in which case they should be re-run).  Copy and paste the following lines of code (preserving the upper- and lower- case letters) into the R Console and press "enter" on the keyboard to install the development version of **VisitContactTrace** from GitHub:

```r
depend.pack <- c('anytime', 'shiny', 'shinydashboard', 'viridis', 'shinyFiles', 'shinycssloaders', 'shinyWidgets', 'data.table', 'assertthat', 'dplyr', 'purrr', 'rmarkdown', 'visNetwork', 'DT', 'fst', 'stringr', 'shinyalert', 'epicontacts', 'fs', 'readxl', 'shinyjs')
install.packages(depend.pack, dependencies=TRUE, repos="http://lib.stat.cmu.edu/R/CRAN/")
# VNSNY Internal Employees Only (Remove before making public)
install.packages("http://stats.vnsny.org/VisitContactTrace/VisitContactTrace_0.1.0.tar.gz",repo=NULL,type="source")
# Public version install
# install.packages("VisitContactTrace", repos = "https://github.com/vnsny-bia/VisitContactTrace")
```

## Running VisitContactTrace Locally

Type the following commands (preserving the upper- and lower- case letters) into the R Console and press "enter" in order to run the application:

```r
library(VisitContactTrace)
VisitContactTrace()
```
Run those two commands from an R session every time you want to use VisitContactTrace.

# Data 

The VisitContactTrace application supports a common data structure used in community-based healthcare settings for functions such as billing and clinical record documentation. This data structure, known as "encounter data" or "visit data," was the motivation for creating this application. In a community-based healthcare setting, patients are usually homebound or have significant disability, and are not observed to encounter each other. The VisitContactTrace application uses only these visit interactions or "encounters" between visit staff and patients to trace the possible transmission route of an infectious disease in a visit-based service delivery model.  While it is possible for community-based visit staff to interact with each other in the field under certain circumstances, it is an uncommon occurrence, and VisitContactTrace currently does not support contact tracing for those interactions.  The concept of visit-based contact tracing can be used in other visit-based service delivery models outside of community-based healthcare settings.

The image below shows a snippet of an example dataset where a handful of clinicians have delivered visits to a few patients during an observation window of February - May 2020. In this simulated sample dataset, Patient 4 was first visited by [Anna Caroline Maxwell](https://en.wikipedia.org/wiki/Anna_Maxwell) on February 27, 2020, followed by several visits by [Lillian Wald](https://en.wikipedia.org/wiki/Lillian_Wald) every 2-6 days from February 29, 2020 to March 31, 2020.

<img src="./inst/www/visithc.png" width="400" align="center"/>

## Data Specifications <a name="dataspec"></a>

The VisitContactTrace will not produce accurate results if there are any data integrity or completeness issues. Please take the following into consideration when preparing a data file to upload into the application:

* Preprocess the data to ensure that each row in the dataset represents a direct person-to-person visit per day.
  * Do not aggregate data from several days into one row.
  * Only use one row to represent a unique patient/staff/date combination. If a staff member visited the same patient several times during the same day, the dataset should have only one row to represent those same-day visits.
  * Exclude telephonic or telemedicine "visits" or encounters.
* Pay attention to the range of visit dates included in your dataset.
  * For example, if you load a dataset that contains visits from April 2020, then VisitContactTrace will only return results that apply to May 2020 and will not be able to return results about visits from March 2020 or May 2020.


  
The **VisitContactTracing** application recognizes the following data fields:

| Column Name | Format | Required | Description |
| --------------- | --------------- | --------------- |----------------------------------------------------------------------------|
| PATIENT_ID | Character | FALSE | Unique identifier of patient.  If this column is absent, **PATIENT_NAME** is used instead. |
| PATIENT_NAME | Character | TRUE | First and last name of patient. If the **PATIENT_ID** column is absent, this column is used as the unique identifier for patients.* |
| VISIT_DATE | DATE | TRUE | The date that a visit staff member visits a patient. Date should be in MM/DD/YYYY or MM-DD-YYYY format |
| STAFF_ID | Character | FALSE | Unique ID for visit staff member.  If this column is absent, **STAFF_NAME** is used instead. |
| STAFF_NAME | Character | TRUE | First and last name of visit staff member. If the **STAFF_ID** column is absent, this column is used as the unique identifier for visit staff members.*|
| PATIENT_STATUS | Character | FALSE |  Labels used to indicate a status for each **patient**, such as confirmation of an infectious disease or some other status (e.g. "POSITIVE", "NEGATIVE", "SUSPECTED").  This label is case-sensitive (meaning that "Positive", "positive", and "POSITIVE" are all considered different statuses) and must be applied to all applicable visit observations for the **patient**.  See the Output - Plot section to learn how the application uses this column. |
| STAFF_STATUS | Character | FALSE |  Labels used to indicate a status for each **staff member**, such as confirmation of an infectious disease or some other status (e.g. "POSITIVE", "NEGATIVE", "SUSPECTED").  This label is case-sensitive (meaning that "Positive", "positive", and "POSITIVE" are all considered different statuses) and must be applied to all applicable visit observations for the **staff member**.  See the Output - Plot section to learn how the application uses this column. |

\* Many users may work with data systems that store patient/staff name in two columns (first name & last name).  Those users should consider concatenating those columns prior to uploading the data into the application.

The columns in the dataset can be in any particular order. However, PATIENT_NAME, STAFF_NAME, and VISIT_DATE are required columns and must be spelled exactly as specified. The VisitContactTrace application will ignore any columns names that do not exactly match those documented here. It is highly recommended that PATIENT_ID and STAFF_ID are derived from a data source that treats these fields as a unique key - i.e., that these columns uniquely identify a specific patient or staff member. When PATIENT_ID and STAFF_ID are provided, the application relies on the underlying integrity of these fields in order to produce accurate contact tracing. If either of these columns are not available, the application will use the PATIENT_NAME and STAFF_NAME columns to uniquely identify a patient and staff member, respectively. Thus, in the absence of PATIENT_ID and STAFF_ID columns users should be careful to address inconsistencies in spelling, use of upper- and lower- case letters, use of extraneous spaces, and the order of first and last names for the names contained in PATIENT_NAME and STAFF_NAME. For example, "Lillian Wald", "lillian wald", "Wald, Lillian", and "Lillian  Wald" (with 2 spaces between first and last name instead of one) would all be treated as different individuals. Similarly, ["Hazel Johnson-Brown"](https://en.wikipedia.org/wiki/Hazel_Johnson-Brown) and "Hazel Johnson Brown" (not hyphenated) would be treated as different individuals as well. 

### Renaming data columns

The user interface for uploading data will raise an error if the user attempts to submit a data file without the required columns.The user interface allows users the option to rename columns with the correct spelling.  


# Using the Application

## User Interface for Importing Data

The following figure is the welcome screen that appears as soon as the application opens.  Click on "Upload File" and browse to the dataset that you wish to import into the VisitContactTrace application.  

<img src="./inst/www/ct-welcome.PNG" width="400"  align="center"/>

The "Review Data" button provides a preview of the data import and the ability to rename columns to the names defined in [data specifications](#dataspec). If column names and formats are correct, the "Submit Data" button will import the data into the application.  If not, the user will be notified of an error.

The **Try Out Demo Data** button allows users to experiment with a simulated dataset within the application.  

<img src="./inst/www/ct-preview.PNG" width="500"  align="center"/>

## Exit/Reload

The top right-hand corner of the following figure shows how users can choose to exit the application or reload the user interface to upload data.  It is best to exit the application by clicking on "Exit" in this window, because this correctly closes the VisitContactTrace application from the R session. 

## Querying VisitContactTrace 

When using the VisitContactTrace application, the user needs to identify an individual that serves as the "index" person in a contact tracing investigation.  

Querying Parameter Instructions:

* Choose whether you are starting with an index staff member or a patient by clicking the on the “Staff” or “Patient” tile. 
* Choose the Staff ID (or Patient ID) of the index person. 
* Choose the reference date. For example, this could be the date of symptom onset for the index person. 
* Choose the number of days to look back from the reference date (e.g. the incubation period of the disease) and the number of days to look forward from the reference date.  Consult your organization's policies & procedures for specific guidance regarding the use of index dates and tracing periods.

**Click on the “run” button**

## The Algorithm 

The algorithm first identifies the primary visit-based contacts of the index person during the specified window of time.  It proceeds to identify the visit-based contacts two to three orders of separation away from the index person.  These visit-based contacts must have occurred after the primary contact visit dates (and tertiary contacts must occur after the secondary contact visits). 

In the following screenshot, [Florence Nightingale](https://en.wikipedia.org/wiki/Florence_Nightingale) has been selected as the index staff person for a novel infectious disease.  In this hypothetical example, her symptom onset date was May 12, 2020 and is used as the reference date. The contact tracing is set to start 7 days prior to that date (to account for a 7-day incubation period of the novel infectious disease) and will conclude 7 days afterwards (in order to account for visits that she delivered while she was symptomatic as well as to capture a longer timeframe for secondary and tertiary visits to have occurred).  The calculated begin and end dates for the contact tracing is presented back to the user immediately below the parameter input area: "All visits during 2020-05-05 and 2020-05-19 will be shown."  


### Output - Contact Lists

The right-hand panel in the following screenshot displays the primary, secondary, and tertiary contact lists. The user can download these lists into .csv.

#### Definition of Primary, Secondary Tertiary Contacts

<img src="./inst/www/ct-staff-patient-origin.PNG" width="600" align="center"/>

These contact lists are available in the three tabs on the right under "Contact Lists."  Each one is available for download into .csv.

<img src="./inst/www/ct-main.PNG" width="1200" align="center"/>

### Output - Plot

The "Plot" tab displays the "network diagram" of primary, secondary, and tertiary contacts.  If the user included staff/patient statuses, the legend indicates which status each patient or staff is known to have had. 

<img src="./inst/www/ct-plot3.PNG" width="800" align="center"/>

### Output - Visit Details

All orders of contact are provided in a separate format for export.  They user may then wish to filter on contact_type to their discretion.  In this example, the staff id of 1 was the primary contact to patients with ids 1043 and 1047.

<img src="./inst/www/ct-visitdetails.PNG" width="800" align="center"/>

## Other Usefull R Functions/Objects

There is a simulated Home Healthcare Visits dataset loaded with the R package for experimentation and instructional purposes.

```r
head(visitshc, 10)
```

More experienced R users may want to access the contact tracing function directly.  Given a visit based patient-staff encounter file, an indexed staff/patient, reference date and days forward/back, this getContacts function returns the primary, secondary, tertiary contacts as a dataframe.

```r
# Below example is used to get contact tracing lists based on staff id.
            
getContacts(staff_id= '1',
             patient_id = NA,
             reference_date = "2020-03-01",
             look_forward_days = 20,
             look_back_days = 3,
             data= hcvisits,
             plot=FALSE)
```
# Help Getting Started with R <a name="helpR"></a>

## Installation

VisitContactTrace is an R package that requires the installation of the R software.  To learn more, please visit the [R Project for Statistical Computing]( https://www.r-project.org/).  You will be asked to choose a CRAN mirrors, [also available here](https://cran.r-project.org/mirrors.html).  Choose any location as the mirror, it does not matter which one.  Choose the correct operating system. See more OS tips below.

If the R installation is successful a shortcut should have been created for easy access.  Click on that shortcut to open the R application.

## Open the R Graphical User Interface application ###

### Windows environment 

After selecting the mirror and correct OS, click on "base," and click on "Download R.#.#.#" 

In organizations that require administrative rights to install software, it is possible to install R in the user's local storage without administrative rights.  You can find the **Rgui** executable in the tree which it was installed. Below are some examples of how this may look; click on RGui.exe to launch an R session.  If you will be using this application often, consider creating a shortcut on your desktop.


<img src="./inst/www/Ri386-image.PNG" width="600" align="center"/>

<img src="./inst/www/Rx64-image.png" width="600" align="center"/>

## R Console ##

In order to run the contact tracing application, you must copy and paste two commands into the R Console.  The R Console looks like the image below. It is here where you should write or paste the commands to install and run the VisitContactTrace application on your personal computer.

<img src="./inst/www/Rconsole-image.PNG" width="800" align="center"/>


## License
**VisitContactTrace** is released under [GPLv3 license](https://www.gnu.org/licenses/gpl-3.0.en.html), please see the license in this GitHub repository for additional disclaimers on the usage of this application. 

## Acknowledgments

* Nurse image used for the hex sticker <a href="http://cliparts.co/clipart/4411">cliparts.co</a>
