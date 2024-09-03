# AdventureWorks2013 Production Analysis

- **Author:** Maher Mahmoud Maher 
- **Date:** 29/08/2024

## Table of Contents
- [AdventureWorks2013 Production Analysis](#adventureworks2013-production-analysis)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Executive Summary](#executive-summary)
    - [Key Findings](#key-findings)
  - [Data Description](#data-description)
  - [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
    - [Production Efficiency and Performance Metrics](#production-efficiency-and-performance-metrics)
  - [Results](#results)
  - [Discussion](#discussion)
  - [Conclusion](#conclusion)
  - [Thank you](#thank-you)

## Introduction
This report presents the results of an analysis performed on the AdventureWorks 2013 production data. The purpose of this analysis was to investigate key production KPIs, including Throughput Rate, Production Efficiency Rate, and Scrap Rate. The analysis involved exploratory data analysis and data validation on 25 tables using SQL Server.

## Executive Summary
**Summary of Findings:**  
The analysis revealed 9 key insights related to the production performance of the company. Key issues were identified, and potential improvements were suggested based on these insights.
### Key Findings
1. **Overdue Work Orders:** Potential issues with production bottlenecks and scheduling.
2. **Throughput Rate:** Decreased labor efficiency, suggesting potential inefficiencies.
3. **Cost of Poor Quality (COPQ):** Indicating high performance with minimal waste.
4. **Setup Time Ratio:** High setup times suggest possible workflow design issues.
5. **Production Efficiency Rate:** Efficient performance within acceptable range.
6. **Scrap Rate:** High efficiency with minimal waste.
7. **Manufacturing Cycle Time:** No significant change.
8. **Inventory Accuracy:** Major discrepancy indicating issues with inventory management.
9. **On-Time Delivery Rate:** Potential production bottlenecks and supplier delays.

**Recommendations:**  
A total of 17 strategic recommendations were provided to address the identified issues and improve production efficiency.
1. **Minimize Overdue Work Orders Rate:**
   - Implement lean manufacturing principles.
   - Use advanced scheduling software.
   - Provide time management training.
   - Strengthen quality control.

2. **Maximize Throughput Rate:**
   - Optimize production processes.
   - Address employee fatigue and turnover.
   - Improve workflow design.
   - Invest in scalable production solutions.

3. **Reduce Setup Time Ratio:**
   - Redesign workflow processes.
   - Invest in better tools and equipment.
   - Provide staff training on efficient setup practices.

4. **Address Inventory Accuracy Issues:**
   - Implement an inventory management system.
   - Conduct regular physical audits.
   - Train staff on inventory handling and record-keeping.

5. **Improve On-Time Delivery Rate:**
   - Identify and address production bottlenecks.
   - Collaborate with suppliers for timely material delivery.
   - Streamline procedures and use automation.


## Data Description
**Data Source:**  
The data was obtained from the AdventureWorks2013 database, which includes comprehensive information on production processes.

**Used DATABASE Link:** https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak



**Data Overview:**  
- **Variables:** The dataset includes variables related to production metrics such as :
  - Production Schedule Adherence
  - Throughput Rate 
  - Cost of Poor Quality (COPQ) 
  - Setup Time Ratio 
  - Production Efficiency Rate 
  - Scrap Rate 
  - Manufacturing Cycle Time 
  - Inventory Accuracy 
  - On-Time Delivery Rate 
- **Size:** The analysis covered the 25 tables of production in the SQL Server database.
- **Type:** The data includes numerical and categorical variables pertinent to production metrics.

**Data Wrangling:**  
Data wrangling involved handling missing values, correcting data inconsistencies, and ensuring data accuracy across the 25 tables.
- **Data Types:** Verified correctness of data types.
- **Missing Values and Duplicates:** Checked for missing values and duplicates.
- **Outliers:** Identified 339 potential outliers using Z-score; investigated and confirmed normal variations.

## Exploratory Data Analysis (EDA)
### Production Efficiency and Performance Metrics
1. **Production Schedule Adherence:** Overdue Work Orders Rate decreased by 1% but remains high at 43%.
2. **Throughput Rate:** Production increased from 464,000 to 677,000 units; however, labor efficiency decreased.
3. **Cost of Poor Quality (COPQ):** Remained approximately the same at 0.18%, indicating top-tier performance.
4. **Setup Time Ratio:** Consistent at 33%, above the acceptable range of 10%–20%.
5. **Production Efficiency Rate:** Remained at 89%, within the acceptable range of 85%–95%.
6. **Scrap Rate:** Maintained at 0.25%, indicating high efficiency.
7. **Manufacturing Cycle Time:** Remained at 13 days, showing no change.
8. **Inventory Accuracy:** Extremely low at 1.4%, suggesting substantial issues with inventory tracking.
9. **On-Time Delivery Rate:** Decreased by 2% from 78% to 76%, below the industry standard of 90%–95%.

**Visualizations:**  
![Visualization 1](AdventureWorks_Dashboard.jpg)  
*Figure : AdventureWorks 2013 Production Dashboard*

## Results
**Key Findings:**  
1. **Overdue Work Orders:** Potential issues with production bottlenecks and scheduling.
2. **Throughput Rate:** Decreased labor efficiency, suggesting potential inefficiencies.
3. **COPQ:** Indicating high performance with minimal waste.
4. **Setup Time Ratio:** High setup times suggest possible workflow design issues.
5. **Production Efficiency Rate:** Efficient performance within acceptable range.
6. **Scrap Rate:** High efficiency with minimal waste.
7. **Manufacturing Cycle Time:** No significant change.
8. **Inventory Accuracy:** Major discrepancy indicating issues with inventory management.
9. **On-Time Delivery Rate:** Potential production bottlenecks and supplier delays.

**Interpretation:**  
The findings suggest that while some production lines are performing well, others are experiencing inefficiencies that need to be addressed. 

**Comparison:**  
Compared to industry benchmarks, the company's production efficiency rates are below average in certain areas.

## Discussion
**Insights:**  
The analysis provided insights into production performance and highlighted critical areas where efficiency could be improved.

**Limitations:**  
The analysis was constrained by the quality and completeness of the data provided. Further analysis with additional data could yield more comprehensive insights.

**Future Work:**  
Future work could involve a more detailed examination of specific production processes and additional data sources to refine the recommendations.

## Conclusion
**Summary:**  
The analysis of the AdventureWorks2013 production data revealed several key insights into production performance and identified areas for improvement.

**Final Recommendations:**  
Based on the findings, 17 strategic recommendations were made to enhance production efficiency and reduce scrap rates.

## Thank you 