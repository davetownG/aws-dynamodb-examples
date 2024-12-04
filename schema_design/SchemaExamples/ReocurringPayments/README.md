# Recurring payments schema design in DynamoDB

## Overview

This document outlines a use case using DynamoDB to implement a recurring payments system. 
The specifics for our use case include the following:
 - Each account can have multiple subscriptions.
 - The subscription has a NextPaymentDate when the next payment needs to be processed and a NextReminderDate when an email reminder is sent to the customer.
 - There is an item for the subscription that is stored and updated when the payment been processed. (The average item size is around 1KB and the throughput depends on the number of accounts and subscriptions.)
 - The payment processor will also create a receipt as part of the process which is stored in the table and are set to expire after a period of time by using a TTL attribute.

## Key Entities

1. account
2. subscription
3. receipt

## Design Approach

We employ a single table design coupled with two global secondary indexes (GSI). 
The following key structures are used:

  - Base table 
    - Partition key (PK)
      - ACC#\<account ID\> - Given account
    - Sort key (SK)
      - SUB#\<subscription ID\>#SKU#\<SKU\> - Given subscription and SKU
      - REC#\<incremental number\>\<ISO 8601 timestamp\>#SKU#\<SKU\> - Receipt with timestamp and SKU
    - Examples:  

      | PK | SK | Sample Attributes |
      | ----------- | ----------- | ----------- |
      | ACC#123 | SUB#123#SKU#999 | Email, PaymentDate, PaymentAmount, LastPaymentDate, NextPaymentDate, LastReminderDate, NextReminderDate, SKU, PaymentDetails, CreatedDate |
      | ACC#123 | REC#12023-05-28T14:15:39.247Z | Email, SKU, ProcessedDate, ProcessedAmount, TTL |

  - GSI-1 (Sparse index - receipts items are not replicated)
    - Partition key (NextReminderDate)
      - \<YYYY-MM-DD\> - Reminder date
    - Sort key (LastReminderDate)
      - \<ISO 8601 timestamp\>

    - Example:  

      | PK | SK | Sample Attributes |
      | ----------- | ----------- | ----------- |
      | 2023-06-21 | 2023-05-21T14:15:39.247Z | SK, PK, SKU, Email, NextPaymentDate |

  - GSI-2 (Sparse index - receipts items are not replicated)
    - Partition key (NextPaymentDate)
      - \<YYYY-MM-DD\> - Reminder date
    - Sort key (LastPaymentDate)
      - \<timestamp\>

    - Examples:  

      | PK | SK | Sample Attributes |
      | ----------- | ----------- | ----------- |
      | 2023-06-21 | 2023-05-21T14:15:39.247Z | SK, PK, Email, PaymentDay, PaymentAmount, SKU, PaymentDetails |

## Access Patterns

The document covers 7 access patterns. For each access pattern, we provide:
- Usage of Base table or GSI
- Relevant DynamoDB operation (PutItem, GetItem, DeleteItem, Query)
- Partition and Sort key values
- Other conditions or filters

  | Access pattern | Base table/GSI | Operation | Partition key value | Sort key value | Other conditions/Filters |
  | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
  

    createSubscription

    createReceipt

    updateSubscription

    getDueRemindersByDate

    getDuePaymentsByDate

    getSubscriptionsByAccount

    getReceiptsByAccount

  | createSession | Base table | PutItem | PK=\<session_id\> | SK=customer_id | |
  | getSessionBySessionId | Base table | GetItem | PK=\<session_id\> | SK=customer_id | |
  | expireSession | Base table | DeleteItem | PK=\<session_id\> | SK=customer_id | |
  | getChildSessionsBySessionId | Base table | Query | PK=\<session_id\> | SK begins_with “child#”| |
  | getSessionByChildSessionId | GSI | Query | SK=\<child_session_id\> | SK begins_with “child#” | |
  | getLastLoginTimeByCustomerId | GSI | Query | SK=\<customer_id\> | | Limit 1 |
  | getSessionIdByCustomerId | GSI | Query | SK=\<customer_id\> | PK=session_id | |
  | getSessionsByCustomerId | GSI | Query | SK=\<customer_id\> | | |
  
Please note: We add “Limit 1” for getLastLoginTimeByCustomerId since GSIs can have duplicate values. GSIs do not enforce uniqueness on key attribute values like the base table does.

## Goals

- Model relationships between users and posts efficiently
- Ensure scalability using Amazon DynamoDB's single table design principles

## Schema Design

A comprehensive schema design is included, demonstrating how different entities and access patterns map to the DynamoDB table structure. [SessionManagementSchema.json](https://github.com/aws-samples/aws-dynamodb-examples/blob/master/schema_design/SchemaExamples/SessionManagement/SessionManagementSchema.json)
 
