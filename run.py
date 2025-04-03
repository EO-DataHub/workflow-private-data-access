import datetime as dt
import json
import os
import time

import boto3
import click
import requests

RESOURCE_CATLOG_URL = os.getenv(
    "RESOURCE_CATLOG_URL",
    "https://dev.eodatahub.org.uk/api/catalogue/stac/catalogs/user/catalogs/",
)
BUCKET_NAME = os.getenv("BUCKET_NAME", "workspaces-eodhp-dev")
WORKSPACE_ACCESS_TOKEN = os.getenv("WORKSPACE_ACCESS_TOKEN", "your_api_token_here")


def check_rc_access(workspace: str, resource_catalogue_url: str, api_token: str):
    """
    Check if the workspace is accessible.
    """
    url = f"{resource_catalogue_url}{workspace}"

    try:
        response = requests.get(url, headers={"Authorization": f"Bearer {api_token}"})
        if response.status_code == 200:
            print(
                f"\033[92mWorkspace {workspace} is accessible in the Resource Catalogue.\033[0m"
            )
        else:
            print(
                f"\033[91mWorkspace {workspace} is not accessible in the Resource Catalogue. Status code: {response.status_code}\033[0m"
            )
    except requests.exceptions.RequestException as e:
        print(
            f"\033[91mError accessing workspace {workspace} in the Resource Catalogue: {e}\033[0m"
        )
    return


def check_https_access(workspace: str, url: str, api_token: str):
    """
    Check if the workspace is accessible.
    """
    try:
        response = requests.get(url, headers={"Authorization": f"Bearer {api_token}"})
        if response.status_code == 200:
            print(f"\033[92mWorkspace {workspace} is accessible via HTTPS\033[0m")
        else:
            print(
                f"\033[91mWorkspace {workspace} is not accessible via HTTPS. Status code: {response.status_code}\033[0m"
            )
    except requests.exceptions.RequestException as e:
        print(f"\033[91mError accessing workspace {workspace} via HTTPS: {e}\033[0m")
    return


def check_s3_access(workspace: str, bucket_name: str):
    """ "
    Check if the workspace is accessible in S3.
    """
    s3_client = boto3.client("s3")  # using env variables
    try:
        # Get the processing-results.json file from the bucket at prefix "{workspace}"
        response = s3_client.get_object(
            Bucket=bucket_name, Key=f"{workspace}/processing-results.json"
        )
        # Check if the file exists and is accessible
        if "Body" in response:
            json_file = response.get("Body").read().decode("UTF-8")
            json_file = json.loads(json_file)
            print(f"\033[92mWorkspace {workspace} is accessible in S3.\033[0m")
        else:
            print(
                f"\033[91mWorkspace {workspace} is not accessible in S3. Status code: {response['ResponseMetadata']['HTTPStatusCode']}\033[0m"
            )
    except Exception as e:
        print(f"\033[91mWorkspace {workspace} is not accessible in S3: {e}\033[0m")
    return


def generate_catalog(cat_id: str, item_id: str):
    data = {
        "stac_version": "1.0.0",
        "id": cat_id,
        "type": "Catalog",
        "description": "Root catalog",
        "links": [
            {"type": "application/geo+json", "rel": "item", "href": f"{item_id}.json"},
            {"type": "application/json", "rel": "self", "href": f"{cat_id}.json"},
        ],
    }
    with open(f"./catalog.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)


def generate_item(cat_id: str, item_id: str, date: str):
    data = {
        "stac_version": "1.0.0",
        "id": item_id,
        "type": "Feature",
        "geometry": {
            "type": "Polygon",
            "coordinates": [
                [[-180, -90], [-180, 90], [180, 90], [180, -90], [-180, -90]]
            ],
        },
        "properties": {"created": date, "datetime": date, "updated": date},
        "bbox": [-180, -90, 180, 90],
        "assets": {},
        "links": [
            {"type": "application/json", "rel": "parent", "href": "catalog.json"},
            {"type": "application/geo+json", "rel": "self", "href": f"{item_id}.json"},
            {"type": "application/json", "rel": "root", "href": "catalog.json"},
        ],
    }

    with open(f"./{item_id}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=4)


def generate_stac():
    cat_id = "demo-catalog"
    item_id = "demo-item"
    now = time.time_ns() / 1_000_000_000
    dateNow = dt.datetime.fromtimestamp(now)
    dateNow = dateNow.strftime("%Y-%m-%dT%H:%M:%S.%f") + "Z"
    # Generate STAC Catalog
    generate_catalog(cat_id, item_id)
    # Generate STAC Item
    generate_item(cat_id, item_id, dateNow)


@click.command()
@click.argument("workspace")
@click.option(
    "--resource-catalogue-url",
    default=RESOURCE_CATLOG_URL,
    help="Base url for resource catalogue.",
)
@click.option("--api-token", default=WORKSPACE_ACCESS_TOKEN, help="API token for authentication.")
@click.option("--bucket-name", default=BUCKET_NAME, help="S3 bucket name.")
@click.option(
    "--https-url",
    default="https://{workspace}.dev.eodatahub-workspaces.org.uk/files/workspaces-eodhp-dev/processing-results.json",
    help="HTTPS URL for workspace.",
)
def main(
    workspace: str,
    resource_catalogue_url: str,
    api_token: str,
    bucket_name: str,
    https_url: str,
):
    """
    Main function to check the accessibility of workspace.
    """
    check_rc_access(workspace, resource_catalogue_url, api_token)
    https_url = https_url.replace("{workspace}", workspace)
    check_https_access(workspace, https_url, api_token)
    check_s3_access(workspace, bucket_name)

    # Generate example STAC to ensure workflow is successful
    generate_stac()


if __name__ == "__main__":
    # Call the main function
    main()
