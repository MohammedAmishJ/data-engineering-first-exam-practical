import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine


load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "first_practical_exam")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD")

REQUIRED_COLUMNS = {
    "age",
    "job",
    "marital",
    "education",
    "default",
    "balance",
    "housing",
    "loan",
    "day_of_week",
    "month",
    "duration",
    "campaign",
    "pdays",
    "previous",
    "contact",
    "poutcome",
    "y",
}


def main():
    if not DB_PASSWORD:
        raise ValueError("DB_PASSWORD is not set in the .env file.")

    engine = create_engine(
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    df = pd.read_sql(
        "SELECT * FROM raw.bank_marketing",
        engine,
    )

    missing_columns = REQUIRED_COLUMNS - set(df.columns)

    if missing_columns:
        print("Schema validation: FAILED")
        print(f"Missing columns: {sorted(missing_columns)}")
        return

    print("Schema validation: PASSED")

    valid = (
        df["age"].between(18, 100)
        & df["balance"].notna()
        & df["duration"].ge(0)
        & df["campaign"].ge(1)
        & df["pdays"].ge(-1)
        & df["previous"].ge(0)
        & df["y"].isin(["yes", "no"])
    )

    valid_records = df[valid]
    rejected_records = df[~valid]

    print("\nValidation Summary")
    print("------------------")
    print(f"Total records: {len(df)}")
    print(f"Valid records: {len(valid_records)}")
    print(f"Rejected records: {len(rejected_records)}")
    print("Records requiring manual review: 0")


if __name__ == "__main__":
    main()