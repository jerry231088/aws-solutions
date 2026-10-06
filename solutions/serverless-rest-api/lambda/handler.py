import json
import os
import uuid
from datetime import datetime, timezone

import boto3


dynamodb = boto3.resource("dynamodb")

table = dynamodb.Table(
    os.environ["TABLE_NAME"]
)


def response(status_code, body=None):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps(body) if body is not None else ""
    }


def lambda_handler(event, context):

    method = (
        event
        .get("requestContext", {})
        .get("http", {})
        .get("method")
    )

    path_parameters = event.get("pathParameters") or {}

    item_id = path_parameters.get("id")

    if method == "GET" and item_id:
        return get_item(item_id)

    if method == "GET":
        return get_items()

    if method == "POST":
        return create_item(event)

    if method == "PUT" and item_id:
        return update_item(item_id, event)

    if method == "DELETE" and item_id:
        return delete_item(item_id)

    return response(
        404,
        {
            "message": "Route not found"
        }
    )


def create_item(event):

    body = json.loads(
        event.get("body") or "{}"
    )

    item_id = str(uuid.uuid4())

    item = {
        "id": item_id,
        "name": body.get("name"),
        "description": body.get("description"),
        "created_at": datetime.now(
            timezone.utc
        ).isoformat()
    }

    table.put_item(Item=item)

    return response(
        201,
        item
    )


def get_item(item_id):

    result = table.get_item(
        Key={
            "id": item_id
        }
    )

    item = result.get("Item")

    if not item:
        return response(
            404,
            {
                "message": "Item not found"
            }
        )

    return response(
        200,
        item
    )


def get_items():

    result = table.scan()

    return response(
        200,
        {
            "items": result.get(
                "Items",
                []
            )
        }
    )


def update_item(item_id, event):

    body = json.loads(
        event.get("body") or "{}"
    )

    result = table.update_item(
        Key={
            "id": item_id
        },
        UpdateExpression=(
            "SET #name = :name, "
            "description = :description"
        ),
        ExpressionAttributeNames={
            "#name": "name"
        },
        ExpressionAttributeValues={
            ":name": body.get("name"),
            ":description": body.get(
                "description"
            )
        },
        ReturnValues="ALL_NEW"
    )

    return response(
        200,
        result["Attributes"]
    )


def delete_item(item_id):

    table.delete_item(
        Key={
            "id": item_id
        }
    )

    return response(204)
