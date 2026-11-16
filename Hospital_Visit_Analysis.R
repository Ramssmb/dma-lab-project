# =====================================================================
# Hospital Patient Visit Pattern Analysis Using Data Mining  (R script)
# Mentor: Dr Jagdeep Kaur
# Students: M Srihari (24103103), M Bhavsingh (24103095)
#
# HOW TO RUN: open in RStudio, then either press Ctrl+A and Ctrl+Enter,
# or click 'Source'. A window will ask for the dataset:
# select Hospital_Patient_Visit_Dataset.xlsx. Install the packages once
# using the install.packages line in Step 1.
# Plots appear in the Plots pane (use the arrows to flip through them).
# =====================================================================

# =====================================================================
# Step 1: Install and load packages
# =====================================================================
# install.packages(c("readxl","dplyr","ggplot2","arules","arulesViz","cluster","factoextra",
#                    "rpart","rpart.plot","caret","corrplot","randomForest","pROC"))  
# run once
library(readxl); library(dplyr); library(ggplot2)
library(arules); library(arulesViz)
library(cluster); library(factoextra)
library(rpart); library(rpart.plot); library(caret)
library(corrplot); library(randomForest); library(pROC)

# =====================================================================
# Step 2: Import the dataset
# =====================================================================
# ---- Upload your dataset (a file window opens) ----
cat("Please upload your dataset: Hospital_Patient_Visit_Dataset.xlsx\n")
data_path <- tryCatch(
  rstudioapi::selectFile(caption = "Upload your dataset", label = "Upload", filter = "Excel files (*.xlsx)"),
  error = function(e) file.choose()
)
if (is.null(data_path) || data_path == "") stop("No file selected. Run again and choose the dataset.")
df <- read_excel(data_path, sheet = "Patient_Visits")
df <- as.data.frame(df)
cat("Rows:", nrow(df), " Columns:", ncol(df), "\n")
head(df)

# =====================================================================
# Step 3: Explore the data
# =====================================================================
str(df)
summary(df)
colSums(is.na(df))
table(df$Visit_Type)
table(df$Department)
table(df$Admitted)

# =====================================================================
# Step 4: Data preprocessing
# =====================================================================
df$Visit_Date <- as.Date(df$Visit_Date)
df$Wait_Time_min[is.na(df$Wait_Time_min)] <- median(df$Wait_Time_min, na.rm = TRUE)
df$Satisfaction_Score[is.na(df$Satisfaction_Score)] <- median(df$Satisfaction_Score, na.rm = TRUE)
df$Hour <- as.numeric(substr(df$Arrival_Time, 1, 2))
df$Age_Group <- cut(df$Age, breaks = c(0, 12, 30, 50, 65, 100),
                    labels = c("Child", "Young Adult", "Adult", "Senior", "Elderly"))
df$Day_of_Week <- factor(df$Day_of_Week,
  levels = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))
df$Month <- factor(df$Month, levels = month.name)
cols <- c("Gender","Season","Time_Slot","Department","Visit_Type","Diagnosis",
          "Insurance_Type","Admitted","Readmitted_30d")
df[cols] <- lapply(df[cols], as.factor)
colSums(is.na(df))
str(df)

# =====================================================================
# Step 5: Visit pattern analysis
# =====================================================================
# Plot 1: Visits by day of week
ggplot(df, aes(Day_of_Week)) + geom_bar(fill = "steelblue") +
  labs(title = "Visits by Day of Week", x = "Day", y = "Number of Visits")
# Plot 2: Visits by month
ggplot(df, aes(Month)) + geom_bar(fill = "darkgreen") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Monthly Visits", x = "Month", y = "Number of Visits")
# Plot 3: Visits by department
dept_order <- names(sort(table(df$Department), decreasing = TRUE))
ggplot(df, aes(factor(Department, levels = dept_order))) + geom_bar(fill = "orange") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Visits by Department", x = "Department", y = "Number of Visits")
# Plot 4: Visit type by time slot
ggplot(df, aes(Time_Slot, fill = Visit_Type)) + geom_bar(position = "dodge") +
  labs(title = "Visit Type by Time Slot", x = "Time Slot", y = "Number of Visits")
# Plot 5: Diagnosis share by season
ggplot(df, aes(Season, fill = Diagnosis)) + geom_bar(position = "fill") +
  labs(title = "Diagnosis Share by Season", y = "Proportion")
# Plot 6: Wait time vs satisfaction
ggplot(df, aes(Wait_Time_min, Satisfaction_Score)) +
  geom_jitter(width = 0, height = 0.1, alpha = 0.5) +
  geom_smooth(method = "lm", se = FALSE, color = "red", formula = y ~ x) +
  labs(title = "Wait Time vs Satisfaction", x = "Wait Time (min)", y = "Satisfaction (1-5)")
visits_per_patient <- df %>% count(Patient_ID, name = "Visits") %>% arrange(desc(Visits))
head(visits_per_patient, 10)
table(visits_per_patient$Visits)

# =====================================================================
# Step 6: Association rules (Apriori)
# =====================================================================
trans_df <- df[, c("Season","Department","Diagnosis","Visit_Type","Time_Slot","Age_Group","Admitted")]
trans_df <- as.data.frame(lapply(trans_df, as.factor))
trans <- as(trans_df, "transactions")
summary(trans)
# Plot 7: Most frequent items
itemFrequencyPlot(trans, topN = 15, main = "Most Frequent Items")
rules <- apriori(trans, parameter = list(supp = 0.03, conf = 0.6, minlen = 2, maxlen = 4))
rules <- rules[!is.redundant(rules)]
length(rules)
inspect(head(sort(rules, by = "lift"), 15))
adm_rules <- subset(rules, rhs %in% "Admitted=Yes")
length(adm_rules)
if (length(adm_rules) > 0) inspect(head(sort(adm_rules, by = "lift"), 10))
# Plot 8: Rules scatter plot
plot(rules, method = "scatter", measure = c("support", "confidence"), shading = "lift")

# =====================================================================
# Step 7: K-Means clustering
# =====================================================================
num_vars <- c("Age","Distance_km","Wait_Time_min","Consultation_Time_min",
              "Length_of_Stay_days","Total_Bill_INR")
scaled <- scale(df[, num_vars])
# Plot 9: Elbow method
fviz_nbclust(scaled, kmeans, method = "wss") + labs(title = "Elbow Method")
# Plot 10: Silhouette method
fviz_nbclust(scaled, kmeans, method = "silhouette") + labs(title = "Silhouette Method")
set.seed(123)
km <- kmeans(scaled, centers = 3, nstart = 25)
df$Cluster <- factor(km$cluster)
table(df$Cluster)
cluster_profile <- df %>%
  group_by(Cluster) %>%
  summarise(across(all_of(num_vars), ~ round(mean(.x), 1)), Patients = n())
print(cluster_profile)
# Plot 11: Cluster plot
fviz_cluster(km, data = scaled, geom = "point", main = "Patient Clusters")

# =====================================================================
# Step 8: Decision tree (predict admission)
# =====================================================================
model_df <- df[, c("Admitted","Age","Gender","Day_of_Week","Season","Time_Slot",
                   "Department","Visit_Type","Insurance_Type","Distance_km",
                   "Wait_Time_min","Consultation_Time_min")]
set.seed(123)
idx   <- createDataPartition(model_df$Admitted, p = 0.7, list = FALSE)
train <- model_df[idx, ]
test  <- model_df[-idx, ]
tree <- rpart(Admitted ~ ., data = train, method = "class",
              control = rpart.control(cp = 0.01, minsplit = 10))
# Plot 12: Decision tree
rpart.plot(tree, main = "Decision Tree: Hospital Admission")
pred <- predict(tree, test, type = "class")
confusionMatrix(pred, test$Admitted, positive = "Yes")
tree$variable.importance

# =====================================================================
# Step 9: Monthly visit trend
# =====================================================================
monthly <- df %>% count(Month, name = "Visits")
monthly_ts <- ts(monthly$Visits, start = c(2025, 1), frequency = 12)
# Plot 13: Monthly trend
plot(monthly_ts, type = "o", col = "blue",
     main = "Monthly Patient Visits (2025)", ylab = "Visits", xlab = "Month")

# =====================================================================
# Step 10: Outlier detection
# =====================================================================
# Plot 14: Bill amount by department
ggplot(df, aes(Department, Total_Bill_INR)) + geom_boxplot(fill = "lightblue") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Total Bill by Department", y = "Bill (INR)")
# Plot 15: Wait time by day of week
ggplot(df, aes(Day_of_Week, Wait_Time_min)) + geom_boxplot(fill = "lightgreen") +
  labs(title = "Wait Time by Day of Week", x = "Day", y = "Wait Time (min)")
boxplot.stats(df$Total_Bill_INR)$out
boxplot.stats(df$Wait_Time_min)$out

# =====================================================================
# Step 11: Correlation analysis
# =====================================================================
num_df <- df[, c("Age","Distance_km","Wait_Time_min","Consultation_Time_min",
                 "Length_of_Stay_days","Total_Bill_INR","Satisfaction_Score")]
cor_mat <- cor(num_df)
round(cor_mat, 2)
# Plot 16: Correlation heatmap
corrplot(cor_mat, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", number.cex = 0.7)

# =====================================================================
# Step 12: Peak hours heatmap and top diagnoses
# =====================================================================
# Plot 17: Which day and hour is busiest
heat <- df %>% count(Day_of_Week, Hour)
ggplot(heat, aes(Hour, Day_of_Week, fill = n)) + geom_tile(color = "white") +
  scale_fill_gradient(low = "white", high = "red") +
  labs(title = "Visits by Day and Hour", x = "Hour of Day", y = "Day", fill = "Visits")
df %>% count(Season, Diagnosis) %>% group_by(Season) %>%
  slice_max(n, n = 3) %>% arrange(Season, desc(n))

# =====================================================================
# Step 13: Statistical tests
# =====================================================================
chisq.test(table(df$Visit_Type, df$Admitted))
chisq.test(table(df$Season, df$Diagnosis))
summary(aov(Wait_Time_min ~ Day_of_Week, data = df))
cor.test(df$Wait_Time_min, df$Satisfaction_Score)

# =====================================================================
# Step 14: Random Forest
# =====================================================================
set.seed(123)
rf <- randomForest(Admitted ~ ., data = train, ntree = 300, importance = TRUE)
print(rf)
pred_rf <- predict(rf, test)
confusionMatrix(pred_rf, test$Admitted, positive = "Yes")
# Plot 18: Variable importance
varImpPlot(rf, main = "Random Forest: Variable Importance")

# =====================================================================
# Step 15: Compare models with ROC curve
# =====================================================================
prob_tree <- predict(tree, test, type = "prob")[, "Yes"]
prob_rf   <- predict(rf,   test, type = "prob")[, "Yes"]
roc_tree <- roc(test$Admitted, prob_tree, levels = c("No", "Yes"))
roc_rf   <- roc(test$Admitted, prob_rf,   levels = c("No", "Yes"))
# Plot 19: ROC curves
plot(roc_tree, col = "blue", main = "ROC Curve: Decision Tree vs Random Forest")
lines(roc_rf, col = "red")
legend("bottomright",
       legend = c(paste("Decision Tree AUC =", round(auc(roc_tree), 2)),
                  paste("Random Forest AUC =", round(auc(roc_rf), 2))),
       col = c("blue", "red"), lwd = 2)

# =====================================================================
# Step 16: Logistic regression (risk factors for admission)
# =====================================================================
logit <- glm(Admitted ~ Age + Visit_Type + Wait_Time_min + Insurance_Type,
             data = df, family = binomial)
summary(logit)
round(exp(coef(logit)), 2)

# =====================================================================
# Step 17: Hierarchical clustering
# =====================================================================
hc <- hclust(dist(scaled), method = "ward.D2")
# Plot 20: Dendrogram
plot(hc, labels = FALSE, hang = -1, main = "Hierarchical Clustering Dendrogram")
rect.hclust(hc, k = 3, border = c("red", "blue", "darkgreen"))
df$HC_Cluster <- cutree(hc, k = 3)
table(df$Cluster, df$HC_Cluster)

# =====================================================================
# Step 18: Key hospital numbers (KPI summary)
# =====================================================================
kpi <- data.frame(
  Measure = c("Total visits", "Unique patients", "Average age (years)",
              "Average wait time (min)", "Average consultation time (min)",
              "Admission rate (%)", "Readmission rate among admitted (%)",
              "Average bill (INR)", "Average satisfaction (1-5)",
              "Busiest day", "Busiest month", "Busiest department"),
  Value = c(nrow(df), n_distinct(df$Patient_ID), round(mean(df$Age), 1),
            round(mean(df$Wait_Time_min), 1), round(mean(df$Consultation_Time_min), 1),
            round(mean(df$Admitted == "Yes") * 100, 1),
            round(mean(df$Readmitted_30d[df$Admitted == "Yes"] == "Yes") * 100, 1),
            round(mean(df$Total_Bill_INR)), round(mean(df$Satisfaction_Score), 2),
            names(which.max(table(df$Day_of_Week))), names(which.max(table(df$Month))),
            names(which.max(table(df$Department)))))
print(kpi, row.names = FALSE)

# =====================================================================
# Step 19: Department and visit type summary
# =====================================================================
dept_summary <- df %>% group_by(Department) %>%
  summarise(Visits = n(), Avg_Age = round(mean(Age), 1), Avg_Wait_min = round(mean(Wait_Time_min), 1),
            Avg_Bill_INR = round(mean(Total_Bill_INR)),
            Admission_Rate_pct = round(mean(Admitted == "Yes") * 100, 1),
            Avg_Satisfaction = round(mean(Satisfaction_Score), 2)) %>% arrange(desc(Visits))
print(as.data.frame(dept_summary))
visit_summary <- df %>% group_by(Visit_Type) %>%
  summarise(Visits = n(), Avg_Wait_min = round(mean(Wait_Time_min), 1),
            Avg_Bill_INR = round(mean(Total_Bill_INR)),
            Admission_Rate_pct = round(mean(Admitted == "Yes") * 100, 1),
            Avg_Satisfaction = round(mean(Satisfaction_Score), 2))
print(as.data.frame(visit_summary))

# =====================================================================
# Step 20: Time and season patterns
# =====================================================================
print(as.data.frame(df %>% count(Day_of_Week, name = "Visits") %>% mutate(Percent = round(Visits / sum(Visits) * 100, 1))))
print(as.data.frame(df %>% count(Month, name = "Visits") %>% mutate(Percent = round(Visits / sum(Visits) * 100, 1))))
print(as.data.frame(df %>% count(Hour, name = "Visits") %>% arrange(desc(Visits)) %>% head(5)))
round(prop.table(table(df$Time_Slot, df$Visit_Type), 1) * 100, 1)
print(as.data.frame(df %>% count(Season, Diagnosis, name = "Cases") %>% group_by(Season) %>%
        slice_max(Cases, n = 3, with_ties = FALSE) %>% arrange(Season, desc(Cases))))
head(sort(table(df$Diagnosis), decreasing = TRUE), 5)

# =====================================================================
# Step 21: Repeat visits and readmission
# =====================================================================
visits_per_patient <- df %>% count(Patient_ID, name = "Visits")
cat("Patients with 1 visit      :", sum(visits_per_patient$Visits == 1), "\n")
cat("Repeat patients (2+ visits):", sum(visits_per_patient$Visits >= 2),
    "(", round(mean(visits_per_patient$Visits >= 2) * 100, 1), "% )\n")
cat("Frequent patients (5+)     :", sum(visits_per_patient$Visits >= 5), "\n")
cat("Average days between visits:", round(mean(df$Days_Since_Last_Visit, na.rm = TRUE), 1), "\n")
top_patients <- df %>% group_by(Patient_ID) %>%
  summarise(Visits = n(), Age = first(Age), Main_Diagnosis = names(which.max(table(Diagnosis))),
            Total_Bill_INR = sum(Total_Bill_INR)) %>% arrange(desc(Visits)) %>% head(10)
print(as.data.frame(top_patients))
adm <- df[df$Admitted == "Yes", ]
print(table(adm$Age_Group, adm$Readmitted_30d))
round(prop.table(table(adm$Age_Group, adm$Readmitted_30d), 1) * 100, 1)

# =====================================================================
# Step 22: Model comparison table
# =====================================================================
logit_tr <- glm(Admitted ~ Age + Visit_Type + Wait_Time_min + Insurance_Type,
                data = train, family = binomial)
prob_logit <- predict(logit_tr, test, type = "response")
pred_logit <- factor(ifelse(prob_logit > 0.3, "Yes", "No"), levels = c("No", "Yes"))
prob_tree <- predict(tree, test, type = "prob")[, "Yes"]
prob_rf   <- predict(rf,   test, type = "prob")[, "Yes"]
get_metrics <- function(pred, actual, prob, name) {
  cm <- confusionMatrix(pred, actual, positive = "Yes")
  data.frame(Model = name,
             Accuracy    = round(as.numeric(cm$overall["Accuracy"]), 3),
             Sensitivity = round(as.numeric(cm$byClass["Sensitivity"]), 3),
             Specificity = round(as.numeric(cm$byClass["Specificity"]), 3),
             Precision   = round(as.numeric(cm$byClass["Pos Pred Value"]), 3),
             AUC         = round(as.numeric(auc(roc(actual, prob, levels = c("No", "Yes"), quiet = TRUE))), 3))
}
model_table <- rbind(
  get_metrics(pred,       test$Admitted, prob_tree,  "Decision Tree"),
  get_metrics(pred_rf,    test$Admitted, prob_rf,    "Random Forest"),
  get_metrics(pred_logit, test$Admitted, prob_logit, "Logistic Regression"))
print(model_table, row.names = FALSE)

# =====================================================================
# Step 23: Top association rules and cluster summary
# =====================================================================
top_rules <- head(sort(rules, by = "lift"), 10)
rules_table <- as(top_rules, "data.frame")
num_cols <- c("support", "confidence", "lift")
rules_table[, num_cols] <- round(rules_table[, num_cols], 3)
print(rules_table, row.names = FALSE)
cluster_cat <- df %>% group_by(Cluster) %>%
  summarise(Patients = n(), Top_Department = names(which.max(table(Department))),
            Top_Visit_Type = names(which.max(table(Visit_Type))),
            Admission_Rate_pct = round(mean(Admitted == "Yes") * 100, 1))
print(as.data.frame(cluster_cat))
print(as.data.frame(cluster_profile))


