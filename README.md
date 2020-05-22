
<img src="./inst/www/VNSNY_Horiz_Blue.png" width="300" align="right"/>


# VisitContactTrace 

This application is designed to conduct contact tracing on healthcare encounter data with a specific focus on providers of community-based healthcare delivery services.  In a community-based healthcare system, patients typically are homebound and are visited at home by healthcare providers.  Thus, while direct contact occurs between patients and visit staff, there is no direct contact between patients. This is in contrast with facility-based healthcare (e.g. hospitals, clinics) settings, where patients travel to a central geographic location at which healthcare services are delivered to several patients at a time, and where direct patient-to-patient, patient-to-staff, and staff-to-staff contact can occur.  The VisitContactTrace application allows the user to load and query their visit data in order to:

* explore how infectious disease might spread within a visit-based service delivery model if appropriate precautions are not in place; 

* conduct visit-based contact tracing of the primary, secondary, and tertiary contacts of an "index" patient or visit staff member whose disease status is known to the user.

This application **does not suggest causality** or confirm disease transmission routes.  Rather, it provides a means to explore how infectious disease may spread expotentially among patients and visit staff if precautions are not put into place in a visit-based service delivery model such as a community-based healthcare setting.

<img src="./inst/www/VNSNYCT-hexsticker.png" width="150" align="right"/>


The VisitContactTrace application was designed and created by the Data Science team at the [Visiting Nurse Service of New York](https://www.vnsny.org/) during the COVID-19 pandemic in order to support the organization's contact tracing efforts.  This application may be of value to other agencies providing community-based healthcare or to organizations that have visit-based service delivery models for the purpose of contact tracing of any infectious disease.

Learn more about VNSNY's COVID-19 response [here](https://www.vnsny.org/coronavirus-covid-19/vnsnys-covid-19-response/). 

# Run the VisitContactTrace Application

VisitContactTrace is an R package that requires the installation of the R software. For more information about R, visit the [R Project for Statistical Computing](https://www.r-project.org/). For unexperienced R users please jump to [Help Getting Started with R](#helpR) for some additional guidance.  The R commands below should be typed/copied and pasted into the R Console.

The Visit Contact Trace application has been built for users to  **upload data manually.**  This application assumes the end user is extracting data from a standard report of service encounters from the organization's electronic medical record application.  The data file should be saved as an *.xlsx or *.csv file and uploaded to the VisitContactTracing application.  More sophisticated users can adapt the source code to read datasets created from an ETL tool or incorporate into a data workflow.  [More on the data specifications](#dataspec)


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

The Visit Contact Tracing Application was built to support a common data structure used in community-based healthcare settings for functions such as billing and documentation in the clinical record. This data structure, which represents the unique environment of community-based care, is the motivation for creating this application. Most contact tracing applications assume all individuals have the potential to encounter all other individuals. In a community-based healthcare setting, patients usually are homebound or have significant disability, and are not observed to encounter each other.  While it is possible under certain circumstances for community-based clinical staff to interact in the field, it is an uncommon occurrence. In this visit-based application of contact tracing, the clinician in the community-based healthcare setting is the modeled vector for exposure to other homebound patients (if no precautions are made to protect clinicians and patients from infectious diseases). The authors acknowledge that potential applications of this type of contact tracing are not limited to community-based healthcare settings.

The image below shows a snippet of an example dataset where _n_ clinicians have delivered _n_ x _p_ visits to _p_ patients during an observation window of February - May 2020. In this simulated example, Patient 4 was first visited by [Anna Caroline Maxwell](https://en.wikipedia.org/wiki/Anna_Maxwell) on February, 27, 2020, then [Lillian Wald](https://en.wikipedia.org/wiki/Lillian_Wald) continued the case visiting every 2-6 days from February, 29, 2020 to March, 31, 2020.

<img src="./inst/www/visithc.png" width="400" align="center"/>

## Data Specifications <a name="dataspec"></a>

Please note that the contact tracing will not be accurate if there are any data integrity or completeness issues. Please take the following (incomplete) considerations:

* Preprocessing of data to ensure proper filtering for the appropriate unit - a direct person-to-person encounter
  * Exclude telephonic or telemedicine "visits" or encounters
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
| PATIENT_STATUS | Character | FALSE | Unique labels maybe used to indicate a status for each **patient** who is confirmed with an infectious disease (or other status).  This label must persist over all visit observations for the **patient**.  The application only supports one label at this time and does not consider the time relationship between the status of one individual compared to the timing of statuses of other contacts; it is only provided as label of an individual
| STAFF_STATUS | Character | FALSE | Unique labels maybe used to indicate a status for each **staff** who is confirmed with an infectious disease (or other status).  This label must persist over all visit observations for the **staff**.  The application only supports one label at this time and does not consider the time relationship between the status of one individual compared to the timing of statuses of other contacts; it is only provided as label of an individual

\* The authors anticipate that many users may have systems that store patient/clinician name in two columns (first & last).  Those users should consider concatenating those fields prior to this step.

The order of columns does not matter. PATIENT_NAME, STAFF_NAME, and VISIT_DATE are required fields where the spelling of the column name must be as specified here. The application will ignore any columns whose names do not exactly match those documented here. It is highly recommended that PATIENT_ID and STAFF_ID are derived from a data source that treats these as a unique key - i.e., that the field uniquely identifies a specific patient or staff member. When provided, these fields serve as the mechanism upon which the algorithm conducts contact tracing. The application relies on the underlying integrity of these keys. If either of these are not available, the application will assume that PATIENT_NAME and STAFF_NAME are the keys that unique identify a patient and staff, respectively. Additional caution is warranted to address inconsistent spelling of the names contained in PATIENT_NAME and STAFF_NAME.

### Renaming

The user interface for uploading data will raise an error to the user if an attempt is made to submit a data file without the required columns.  Users are provided with an option to rename fields to the correct spelling in the user inteface.  


# Using the Application

## Graphical User Interface for Importing Data

The following figure should be the welcome screen that appears as soon as the application opens.  Click on "Upload File" and browse to the dataset that you wish to import into the VisitContactTrace Application.  

<img src="./inst/www/ct-welcome.PNG" width="400"  align="center"/>

The "Review Data" button provides a preview of the data import and the ability to rename columns to the names defined in [data specifications](#dataspec). If column names and formats are correct, the "Submit Data" button will import the data into the application.  If not, the user will be notified of an error.

**Try Out Demo Data** button allows you to experiment with the simulated dataset within the application.  

<img src="./inst/www/ct-preview.PNG" width="500"  align="center"/>

## Exit/Reload

In the following figure, on the top right hand side, options exist to exit the application or reload the graphical user interface to upload data.  

## Querying VisitContactTrace 

Querying Parameter Instructions :

* Choose whether you are starting with an index staff member or a patient by clicking the on the “Staff” or “Patient” tile. 
* Choose the Staff ID (or Patient ID) of the index person. 
* Choose the reference date. For example, this could be the date of symptom onset for the index person. 
* Choose the number of days to look back from the reference date (e.g. the incubation period of the disease) and the number of days to look forward from the reference date.  Consult your organization's policies & procedures for specifc guidance regarding the use of index dates and tracing periods.

**Click on the “run” button**

### Definition of N degrees of Contact From Origin

<img src="./inst/www/ct-staff-patient-origin.PNG" width="800" align="center"/>

<img src="./inst/www/ct-main.PNG" width="1200" align="center"/>

### Output - Contact Lists

On the right hand side of the previous figure, primary, secondary, and tertiary contact listings are made available to the user for download into .csv.

### Output - Plot

The "Plot" tab displays the primary contacts and any secondary or tertiary contacts away from the staff/patient of origin.  If the user included staff/patient statuses, the legend indicates which status each patient or staff is known to have had. 

<img src="./inst/www/ct-plot3.PNG" width="800" align="center"/>

### Output - Visit Details

All orders of contact are provided in a separate format for export.  They user may then wish to filter on contact_type to their discretion.  

<img src="./inst/www/ct-visitdetails.PNG" width="800" align="center"/>

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

### Windows environment 

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
