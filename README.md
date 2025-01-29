# Advertising-Analysis
## From Kaggle: https://www.kaggle.com/datasets/ziya07/immersive-ad-design-analysis-data

> "This dataset contains detailed user interaction data from various immersive advertising formats, including 3D, AR, and 2D ads. It captures essential metrics such as clicks, time spent, engagement scores, and user demographics, along with the type of device used (mobile, desktop, tablet). The dataset also includes additional information like conversion rates, bounce rates, and click-through rates (CTR), all of which are valuable for analyzing and optimizing interactive ad performance. Visual complexity and user movement data (e.g., gaze, movement) are also included to assess how different immersive elements influence user engagement.

> The dataset is designed to support the development of models that predict user engagement based on various ad features and help optimize immersive ad designs for enhanced interaction outcomes. It can be used to explore the effectiveness of different ad types and user behaviors, making it a useful resource for digital marketers, advertisers, and machine learning researchers focused on advertising technology and user experience optimization."

| Ad_ID | Ad_Type | Visual_Complexity | Clicks | Time_Spent | Engagement_Score | Age_Group | Gender | Device_Type | Conversion_Rate | Bounce_Rate | CTR | Frame_Data | User_Movement_Data |
|-------|----------|------------------|---------|------------|------------------|-----------|--------|-------------|-----------------|-------------|-----|------------|-------------------|
| 1 | Display Ad | Low | 250 | 45 | 72 | 25-34 | Male | Mobile | 3.5% | 28.2% | 4.1% | Static | Scroll_Down |
| 2 | Search Ad | Medium | 180 | 30 | 65 | 18-24 | Female | Desktop | 2.8% | 35.6% | 3.2% | Dynamic | Click_Through |
| 3 | Social Ad | High | 420 | 60 | 88 | 35-44 | Male | Tablet | 4.2% | 22.4% | 5.0% | Interactive | Multi_Page |
| 4 | Display Ad | Medium | 200 | 35 | 70 | 45-54 | Female | Mobile | 3.0% | 30.1% | 3.8% | Static | Direct_Exit |
| 5 | Search Ad | Low | 150 | 25 | 60 | 55+ | Male | Desktop | 2.5% | 38.7% | 2.9% | Dynamic | Bounce |

# PROJECT GOALS
### This project aims to explore user engagement trends from different advertisement modes.

1. Data Preparation
> *  Cleaning and preprocessing using MySQL
2. EDA Report using SQL and R
3. PowerBI Dashboard
> * Create a dashboard for management to assess the effectiveness of different ad campaigns, will later expand it to be updated in real-time
4. Model Training and Deployment in Python
5. Automated Metrics Application in Python/SQL/PowerBI
> * The goal is to create an automatic process with Python that automatically analyzes new data entered into the MySQL Database
> * From here our data is piped back into the PowerBI dashboard and our pre-trained model will offer more insights
6. Conclusion
