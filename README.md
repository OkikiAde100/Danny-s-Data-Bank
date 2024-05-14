
# Danny's DataBank
___

![Image]([screenshot.jpg](https://github.com/OkikiAde100/Danny-s-Data-Bank/blob/main/Data%20Bank%20Project/Pictures%20for%20report/case%20study%20pic.png))

<img src="(https://github.com/OkikiAde100/Danny-s-Data-Bank/blob/main/Data%20Bank%20Project/Pictures%20for%20report/case%20study%20pic.png)" style="width:600px;height:500px"/>

# Introduction

The Data Bank challenge is the 4th challenge in the 8 weeks of sql challenge created by Danny Ma. The data bank case study creates a challenge to help a new age digital bank that that isn't only for banking activities but also distributes cloud data storage based on how much money customers have in their bank accounts.

The management team aims to increase their total customer base but needs to determine the right model for data allocation based on account balance to it's customers. Hence, the primary objective of this project is to use data to identify the banks resources, understand customer transactions and track how much data storage their customers will need.

This case study is all about calculating metrics, growth and helping the business analyse their data in a smart way to better forecast and plan for their future developments!

# Data Gathering

The dataset was sourced from the <a href="https://8weeksqlchallenge.com/">8 weeks SQL Challenge website</a>. The data for this project can be found in <a href="https://8weeksqlchallenge.com/case-study-4/">Case study 4 - Data Bank</a> within an embedded DB fiddle where the data was extracted into MySQL database for analyses

# Data Bank Challenge

The case study is separated into 4 sections focusing on either getting data and insight on the banks resources and operations, customer transactions and getting insights through data for cloud storage allocation. The sections include:

1. Customer Nodes Exploration
2. Customer Transaction
3. Data Allocation Challenge
4. Extra Challenge

The Explorstory analyses was carried out using MySQL and answers to each section can be found here

# Marketing Campaign

The management team also requested a presentation slide which could be used for their marketing campaign. This presentation is to also include the 3 models that will be used to allocate cloud data storage in a single page.

The presentation was prepared using Microsoft Power Point and can be found <a href="https://github.com/OkikiAde100/Danny-s-Data-Bank/blob/main/Data%20Bank%20Project/Danny's%20Data%20Bank%20Marketing.pptx">here</a>

# Recommendations

Here are some few recommendations after analyses of the data and answering each challenge:

1. with 500 customers banking with danny spread over 5 continents, danny's data bank has shown considerable growth in just 4 months. However, their has been no new customers since the launch of the bank in January 2021. The number of reoccuring customers continues to reduce with a drop of about 30% in month 4

Quick action is needed, as their is need to understand customers need better. This can be achieved by carrying out surveys on the quality and efficiency of our service and how our data storage allocation model can be better improved. This survey will better enable the management team to choose which option for data allocation will be best for the customers in various regions and other areas we will need to improve on.

2. 45.5% of the total transactions made by customers since the banks launch were deposits, while purchase and withdrawal made up 27.5% and 27.0%.

This is a positive trend as it falls inline with our model of allocating data storage based on a customer's money in their account. As a digital bank, investing in security for our customers during transactions to detect fraudlent transactions and emphasis on the banks top data security system during the marketing campaign will increase the trust of customers to deposit more amount with the bank.

3. The management team are considering various options as a base for which data storage allocation will be made based on  customer balance. The data gathered for this option were for accounts with amount higher than zero.
 - Option 1, in which data is allocated based on the amount of money at the end of the previous month. This option is best suited for customers who are salary earners as data allocation will remain stable based on the amount deposited from their monthly salary. the total data allocation for customers monthly is around 250,000 monthly.
 - Option 2, is based on allocating data storage based on the average amount in a customers account for the past 30 days. This options requires about 230,000 for data allocation monthly. This option give the bank an advantage to determine when data i allocated for each region and distribute data storage over a 30 days period.
 - Option 3, allocates data storage on real time transactions. This amount required for data allocation option varies monthly with the required amount going from about 700,000 in month 1 to over 900,000 in month 2 and 3 and finally dropping to around 400,000 in month 4. This option also has high amounts compared to the other options and would require a lot of transfer of data storage resources on each transaction.
 - The management team also indicated a incentive using the amount of interest a customer collects monthly for rewarding extra data storage. The amount for required for this data allocation is about 1,000 monthly. This ia great initiative that should be added to the bank's marketing campaign.


4. Despite having high amounts of deposit each month, some customers had a negative account balance. Hence, it is important that the bank tracks the accounts with negative balance and the amounts that is owed to the bank within a period.
