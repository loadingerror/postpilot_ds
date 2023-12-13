import os
from google.cloud import bigquery
import pandas as pd

print("Successfully ran")

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "credentials_postpilot_datascience.json"
client = bigquery.Client()

# Queries from project_postpilot_datascience

query_join = '''SELECT * FROM project-postpilot-datascience.ecommerce_post.ecommerce_post_join_modeling'''

# # --------------------ITEMS--------------------
rqe_join = client.query(query_join)
print(rqe_join)

table_joined = rqe_join.result().to_dataframe()
print(table_joined.head(5))
table_joined.to_csv(
    "C:\GitHub\postpilot\Files\table_full.csv", sep=",", index=False)


print("SUCCESSFULLY DONE!-----------------")
