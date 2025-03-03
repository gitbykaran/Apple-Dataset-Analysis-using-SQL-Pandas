# 📊 Apple Sales & Warranty Analysis

## 📝 Project Overview
This project analyzes **Apple's sales, product, store, and warranty data** using **Advanced SQL queries**. The dataset contains **over 1 million records** across multiple tables, including:
- **Sales** 🛒
- **Products** 📱
- **Categories** 🎯
- **Warranty Claims** 🛠️
- **Stores** 🏬

By leveraging complex SQL queries, we extract **key business insights**, such as store performance, product demand, warranty claim trends, and year-over-year sales growth.

---

## 🔍 Key Insights & Queries
Here are some of the advanced SQL queries used to answer critical business questions:

1. **Store & Sales Performance:**
   - 🏬 Find the number of stores in each country.
   - 📊 Calculate the total units sold by each store.
   - 📅 Identify the best-selling day for each store.
   - 🏆 Determine the store with the highest total units sold in the last year.
   - 📉 Identify the least-selling product in each country for each year.

2. **Time-Based Sales Analysis:**
   - 📆 Identify how many sales occurred in **December 2023**.
   - 📈 Analyze the year-by-year **growth ratio** for each store.
   - 📅 List the months in the last **three years** where **sales exceeded 5,000 units** in the USA.
   - 📊 Calculate the **monthly running total of sales** for each store and compare trends over the past four years.

3. **Warranty & Product Insights:**
   - ❌ Determine how many stores have **never had a warranty claim** filed.
   - 📌 Calculate the **percentage of warranty claims** marked as **"Warranty Void"**.
   - 📅 Find how many warranty claims were filed in **2020**.
   - 🏷️ Identify the product category with the most warranty claims in the last two years.
   - ⏳ Calculate how many **warranty claims were filed within 180 days** of a product sale.
   - 🔍 Determine the **percentage chance of receiving warranty claims** after each purchase per country.
   - 📈 Analyze the **correlation between product price and warranty claims**, segmented by price range.
   - 🔝 Identify the store with the **highest percentage of "Paid Repaired" claims** relative to total claims filed.

4. **Product Pricing & Demand:**
   - 💰 Find the **average price of products** in each category.
   - 📦 Count the **number of unique products** sold in the last year.
   - 🏷️ Determine how many warranty claims were filed for products launched in the **last two years**.

---

## 🚀 Technologies Used
- **SQL** (Complex Queries, Joins, Window Functions, Aggregations)
- **MySQL** (Database Management)
- **Python** (Fast Analysis/Cross Validation)

---

## 📂 Dataset Structure
| Table Name | Description |
|------------|-------------|
| `sales` | Records of all product sales including date, store, quantity, and revenue. |
| `products` | List of all Apple products with their specifications and pricing. |
| `categories` | Classification of products into different categories. |
| `warranty` | Details of all warranty claims, including status and resolution. |
| `stores` | Information on Apple store locations worldwide. |

---


