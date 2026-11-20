# 🏥 Hospital Patient Visit Pattern Analysis Using Data Mining

<p align="center">
  <img src="https://img.shields.io/badge/Language-R-blue?style=for-the-badge&logo=r" />
  <img src="https://img.shields.io/badge/Domain-Healthcare%20Analytics-green?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Techniques-Data%20Mining-orange?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Status-Completed-success?style=for-the-badge" />
</p>

<p align="center">
  <b>Turning Hospital Visit Data into Meaningful Insights Through Data Mining and Machine Learning</b>
</p>

---

## 📌 Project Overview

The **Hospital Patient Visit Pattern Analysis** project focuses on analyzing hospital patient visit data using R programming, data mining, statistical analysis, and machine learning techniques.

The project explores patient visiting patterns, hospital department performance, waiting times, seasonal trends, admission patterns, and patient satisfaction.

It also applies machine learning algorithms to identify patient groups and analyze factors associated with hospital admissions.

The main goal is to transform raw hospital data into meaningful insights that can support better hospital planning and decision-making.

## 🎯 Project Objectives

- Analyze patient visits across different days, months, and seasons.
- Identify the busiest hospital departments and peak visiting hours.
- Study the relationship between waiting time and patient satisfaction.
- Discover hidden patterns using association rule mining.
- Group patients using clustering techniques.
- Predict hospital admission patterns using machine learning.
- Analyze patient readmission and repeat visits.
- Generate meaningful visualizations and reports.

## 🛠️ Technologies & Tools

| Technology | Purpose |
|---|---|
| R Programming | Data analysis and implementation |
| RStudio | Development environment |
| Excel | Dataset storage |
| ggplot2 | Data visualization |
| dplyr | Data manipulation |
| arules | Association rule mining |
| cluster | Clustering analysis |
| rpart | Decision tree |
| randomForest | Random Forest model |
| caret | Model evaluation |
| pROC | ROC curve analysis |

## 📊 Project Workflow

```text
       Hospital Dataset
              |
              ▼
       Data Collection
              |
              ▼
       Data Preprocessing
              |
              ▼
       Exploratory Data Analysis
              |
              ▼
        Data Visualization
              |
              ▼
        Data Mining Techniques
              |
      ┌───────┼────────┐
      ▼       ▼        ▼
   Apriori  K-Means  Clustering
      |       |        |
      └───────┼────────┘
              ▼
      Machine Learning
              |
      ┌───────┼────────┐
      ▼       ▼        ▼
 Decision  Random   Logistic
  Tree     Forest  Regression
              |
              ▼
       Model Evaluation
              |
              ▼
       Insights & Reports
```

## 🔍 Key Analysis Performed

### 1. Exploratory Data Analysis (EDA)
- Patient visit distribution.
- Department-wise patient visits.
- Monthly and seasonal visit trends.
- Patient age and demographic analysis.
- Waiting time and satisfaction analysis.

### 2. Association Rule Mining
Used the **Apriori algorithm** to discover relationships between:
- Hospital departments.
- Patient diagnoses.
- Visit types.
- Seasons and time slots.
- Admission patterns.

### 3. Patient Segmentation
Applied **K-Means Clustering** to group patients based on numerical characteristics such as:
- Age.
- Distance travelled.
- Waiting time.
- Consultation duration.
- Length of hospital stay.
- Total bill amount.

### 4. Machine Learning
Implemented the following algorithms:

| Algorithm | Application |
|---|---|
| Decision Tree | Admission prediction |
| Random Forest | Admission prediction |
| Logistic Regression | Admission risk analysis |
| Hierarchical Clustering | Patient grouping |

### 5. Statistical Analysis
- Correlation analysis.
- Chi-square tests.
- ANOVA.
- Correlation significance testing.
- ROC curve comparison.

### 6. Hospital Performance Analysis
- Average waiting time.
- Average patient satisfaction.
- Admission and readmission rates.
- Department-wise performance.
- Peak visiting hours.
- Repeat patient analysis.

## 📈 Visualizations

The project generates multiple visualizations to make hospital data easier to understand.

| Visualization | Purpose |
|---|---|
| 📊 Bar Charts | Patient visits by day, month, and department |
| 📉 Scatter Plot | Waiting time vs satisfaction |
| 🔥 Heatmap | Peak visiting hours and correlation analysis |
| 🌳 Decision Tree | Admission prediction logic |
| 👥 Cluster Plot | Patient segmentation |
| 📦 Box Plot | Waiting time and billing distribution |
| 📈 ROC Curve | Machine learning model comparison |
| 🔗 Association Plot | Relationships between patient attributes |

## 📂 Repository Structure

```text
dma-lab-project/
│
├── Hospital_Patient_Visit_Dataset.xlsx
│
├── Hospital_Visit_Analysis.R
│
├── Hospital Patient Visit Pattern Dashboard.html
│
├── Hospital_Patient_Visit_Pattern_Analysis (1).pptx
│
├── Hospital_Patient_Visit_Pattern_Analysis_Report.pdf
│
├── Hospital_Visit_Analysis_Code_Output_Figures.pdf
│
├── README.md
│
├── .RData
│
└── .Rhistory
```

## ⚙️ Installation & Execution

### Prerequisites

- R programming language
- RStudio
- Microsoft Excel or compatible spreadsheet software

### Step 1: Clone the Repository

```bash
git clone https://github.com/Ramssmb/dma-lab-project.git
```

### Step 2: Open the Project

Open the downloaded folder in RStudio.

### Step 3: Install Required Packages

Run the following command in the R console:

```r
install.packages(c(
  "readxl",
  "dplyr",
  "ggplot2",
  "arules",
  "arulesViz",
  "cluster",
  "factoextra",
  "rpart",
  "rpart.plot",
  "caret",
  "corrplot",
  "randomForest",
  "pROC",
  "rstudioapi"
))
```

### Step 4: Execute the R Script

Open `Hospital_Visit_Analysis.R` in RStudio.

Click **Source** to execute the complete analysis.

When prompted, select:

`Hospital_Patient_Visit_Dataset.xlsx`

### Step 5: View the Results

- View generated plots in the RStudio Plots panel.
- Check statistical outputs in the Console.
- Open the HTML dashboard in a web browser.
- Refer to the PDF report for detailed documentation.

## 📑 Project Deliverables

| File | Description |
|---|---|
| R Script | Complete data analysis implementation |
| Excel Dataset | Hospital patient visit data |
| HTML Dashboard | Interactive analysis dashboard |
| PDF Report | Project documentation and findings |
| PPTX Presentation | Project presentation |
| PDF Figures | Code outputs and visualizations |

## 💡 Expected Outcomes

This project demonstrates how data mining and machine learning can help understand hospital operations.

It provides insights into:
- Patient visit trends and peak hours.
- Department-wise workload.
- Patient satisfaction and waiting times.
- Patient grouping and behavioral patterns.
- Factors associated with hospital admissions.
- Performance comparison of predictive models.

**Note:** Model outputs and analytical findings depend on the supplied dataset. Predictive results are intended for academic analysis and should not be treated as clinical recommendations.

## 🎓 Academic Information

**Project Title:** Hospital Patient Visit Pattern Analysis Using Data Mining

**Mentor:** Dr. Jagdeep Kaur

**Students:**
- M Srihari
- M Bhavsingh

## 🚀 Future Enhancements

- Develop a real-time hospital analytics dashboard.
- Integrate larger and real-world hospital datasets.
- Improve predictive model performance.
- Add interactive filters and advanced visualizations.
- Deploy the dashboard as a web application.

## 👨‍💻 Contributors

Developed as an academic Data Mining and Analytics project.

---

<p align="center">
  <b>Turning Data into Insights. Improving Decisions Through Analytics.</b>
</p>

<p align="center">
  ⭐ If you find this project useful, consider giving the repository a star!
</p>
