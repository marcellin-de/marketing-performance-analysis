import logging
import dlt
import polars as pl
from pathlib import Path

# -------------------------------------------------------------------
# Logging configuration
# -------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s"
)

logger = logging.getLogger("marketing_pipeline")

# -------------------------------------------------------------------
# Constants
# -------------------------------------------------------------------
DATA_PATH = Path("/home/marcel/marketing-performance-analysis/data")

# -------------------------------------------------------------------
# DLT Source
# -------------------------------------------------------------------
@dlt.source
def marketing_performance_source():
    """
    Load Maven Fuzzy Factory data from CSV files
    for marketing performance analysis
    """

    def load_csv(file_name: str):
        file_path = DATA_PATH / file_name
        logger.info(f"Loading file: {file_path}")

        if not file_path.exists():
            logger.error(f"File not found: {file_path}")
            raise FileNotFoundError(file_path)

        df = pl.read_csv(file_path)
        logger.info(
            f"Loaded {file_name} | rows={df.height} | cols={df.width}"
        )

        # DLT-friendly format
        yield df.to_dicts()

    # ---------------- RESOURCES ---------------- #

    @dlt.resource(write_disposition="replace")
    def website_sessions():
        yield from load_csv("website_sessions.csv")

    @dlt.resource(write_disposition="replace")
    def orders():
        yield from load_csv("orders.csv")

    @dlt.resource(write_disposition="replace")
    def order_items():
        yield from load_csv("order_items.csv")

    @dlt.resource(write_disposition="replace")
    def order_item_refunds():
        yield from load_csv("order_item_refunds.csv")

    @dlt.resource(write_disposition="replace")
    def website_pages():
        yield from load_csv("website_pageviews.csv")

    @dlt.resource(write_disposition="replace")
    def products():
        yield from load_csv("products.csv")

    return (
        website_sessions,
        orders,
        order_items,
        order_item_refunds,
        website_pages,
        products
    )

# -------------------------------------------------------------------
# Pipeline execution
# -------------------------------------------------------------------
if __name__ == "__main__":
    logger.info("Starting DLT pipeline")

    pipeline = dlt.pipeline(
        pipeline_name="maven_fuzzy_factory",
        destination="snowflake",
        dataset_name="raw"
    )

    load_info = pipeline.run(marketing_performance_source())

    logger.info("Pipeline run finished")
    logger.info(load_info)
