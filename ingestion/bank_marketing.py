import io
import time

import dlt
import pandas as pd
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry


DATASET_ID = 222
EXPECTED_ROWS = 45_211

API_URL = f"https://archive.ics.uci.edu/api/dataset?id={DATASET_ID}"


def create_session():
    retry = Retry(
        total=3,
        backoff_factor=1,
        status_forcelist=[429, 500, 502, 503, 504],
        allowed_methods=["GET"],
    )

    session = requests.Session()
    adapter = HTTPAdapter(max_retries=retry)

    session.mount("https://", adapter)
    session.mount("http://", adapter)

    return session


def main():
    session = create_session()

    # ---------------------------------------------------------
    # 1. Get dataset metadata
    # ---------------------------------------------------------
    print("Fetching Bank Marketing metadata from UCI...")

    response = session.get(API_URL, timeout=30)
    response.raise_for_status()

    metadata = response.json()["data"]

    dataset_name = metadata["name"]
    data_url = metadata["data_url"]
    expected_rows = metadata["num_instances"]

    print(f"Dataset: {dataset_name}")
    print(f"Expected rows: {expected_rows}")

    if expected_rows != EXPECTED_ROWS:
        raise ValueError(
            f"Unexpected UCI metadata row count: "
            f"expected {EXPECTED_ROWS}, got {expected_rows}"
        )

    # ---------------------------------------------------------
    # 2. Download source
    # ---------------------------------------------------------
    print(f"Downloading: {data_url}")

    response = session.get(data_url, timeout=60)
    response.raise_for_status()

    raw_bytes = response.content

    # Small delay between requests to be polite to the source.
    time.sleep(1)

    # ---------------------------------------------------------
    # 3. Read downloaded data
    # ---------------------------------------------------------
    df = pd.read_csv(
        io.BytesIO(raw_bytes),
        sep=",",
    )

    actual_rows = len(df)

    print(f"Received rows: {actual_rows}")

    # ---------------------------------------------------------
    # 4. Completeness validation
    # ---------------------------------------------------------
    if actual_rows != expected_rows:
        raise ValueError(
            f"Row count mismatch: expected {expected_rows}, "
            f"received {actual_rows}"
        )

    print("Row count validation passed.")

    # ---------------------------------------------------------
    # 5. Load into PostgreSQL using dlt
    # ---------------------------------------------------------
    pipeline = dlt.pipeline(
        pipeline_name="bank_marketing",
        destination="postgres",
        dataset_name="raw",
    )

    load_info = pipeline.run(
        df.to_dict(orient="records"),
        table_name="bank_marketing",
        write_disposition="replace",
    )

    print(load_info)
    print("Bank Marketing ingestion completed successfully.")


if __name__ == "__main__":
    main()