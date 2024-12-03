# Gaming Profile Data Modeling with Amazon DynamoDB
## Overview

This document outlines a use case using DynamoDB to store the player profiles of a gaming system. Users (in this case, players) need to create profiles before they can interact with many modern games, especially online ones. Gaming profiles typically include the following:
* Basic information such as their user name
* Game data such as items and equipment
* Game records such as tasks and activities
* Social information such as friend lists

## Key Entities

1. player
2. item
3. task
4. activity
5. equipment
6. friend

## Design Approach

We employ a single table design with the following key structure:

- Partition Key (PK): Identifies the player.
    - player\<player ID\> - given player

- Sort Key (SK): Identifies data contained in the attributes.
    - #METADATA\<player ID\> - metadata for the given player
    - \<ENTITY TYPE\>#\<ENTITY ID\> - entity attributes for the given entity type and ID. 
    
    - Examples:  

      | PK | SK | Sample Attributes |
      | ----------- | ----------- | --------- |
      | player001 | #METADATA#player001 | Type, CreatedAt, UpdatedAt, Nickname, Email, Gender, Avatar, Currency, PlayerLevel, PlayerHealth, PlayerExperience | 
      | player001 | ACTIVITY#001 | Type, ActivityEndTime, ActivityName, ActivityReward, ActivityStartTime, ActivityType |
      | player001 | EQUIPMENTS#001 | Type, EquipmentName, EquipmentType, EquipmentAttributes |
      | player001 | EQUIPMENTS#001EQUIPMENTS#002 | Type, EquipmentName, EquipmentType, EquipmentAttributes |
      | player001 | FRIENDS#player001 | Type, FriendList |
      | player001 | ITEMS#001 | Type, ItemName, ItemType, ItemCount, ItemAttributes |
      | player001 | TASK#001 | Type, TaskName, TaskDescription, TaskStatus, TaskReward |

## Access Patterns

The document covers 6 access patterns. For each access pattern, we provide:

- Specific PK and SK used

- Relevant DynamoDB operation (GetItem, Query)

- Other conditions/filters
    
    | Access pattern | Operation | Partition key value | Sort key value | Other conditions/filters |
    | ----------- | ----------- | ----------- | ----------- | ----------- |
    | getPlayerFriends | GetItem | PK=\<playerID\> | SK=FRIENDS#\<playerID\> | |
    | getPlayerAllProfile |	Query |	PK=\<playerID\> | |    
    | getPlayerAllItems | Query | PK=\<playerID\> | SK=begins_with "ITEMS#" | |   
    | getPlayerSpecificItem | Query | PK=\<playerID\> | SK=begins_with "ITEMS#" | filter-expression:<br>"ItemType = :itemType"<br><br>expression-attribute-values:<br> '{":itemType": "Weapon" }' |
    | updateCharacterAttributes | UpdateItem | PK=\<playerID\> | SK="#METADATA#\<playerID\>" | update-expression:<br>"SET currency = currency - :amount" <br><br>condition-expression:<br> "currency >= :minAmount" |
    | updateItemCount | UpdateItem | PK=\<playerID\> | SK="ITEMS#\<ItemID\>" | update-expression:<br>"SET ItemCount = ItemCount - :incr"<br><br>expression-attribute-values:<br>'{":incr":{"N":"1"}}' |

## Goals

- Model relationships between users and posts efficiently
- Ensure scalability using Amazon DynamoDB's single table design principles

## Schema Design

A comprehensive schema design is included, demonstrating how different entities and access patterns map to the DynamoDB table structure. [GamePlayerProfilesSchema.json](https://github.com/davetownG/aws-dynamodb-examples/blob/master/schema_design/SchemaExamples/GamingPlayerProfiles/GamePlayerProfilesSchema.json)

## Additional Information

[Gaming profile schema design in DynamoDB](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/data-modeling-schema-gaming-profile.html)
