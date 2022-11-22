# Demo to use Apache Kafka with Apache Flink (SQL)
The docker-compose, Dockerfile and some of the examples were based on: https://github.com/confluentinc/flink-sandbox

## Build flink-sandbox/pydatagen docker images (execute only once or in case any of the docker files are changed)
```
docker build -t flink-sandbox . -f Dockerfile_flink
docker build -t pydatagen . -f Dockerfile_pydatagen
```

## Startup docker containers (1x job manager and 4x task managers)
```
docker-compose up --force-recreate --always-recreate-deps -V --scale taskmanager=5 -d
```
Go to Job Manager dashboard (http://127.0.0.1:8081) and see the number of available task managers (5x)<br>
Any SQL statement will consume a task manager and will remain seized for the duration of the statement execution, for example an <code>INSERT</code> statement where it merges/aggregate data will be considered a long running job and eventually consume the task manager "forever" (or until terminated)<br><br>
Some topics will be created in Kafka:
```
Topic name        | Partitions
------------------+-----------
behavior_summary  | 4
shipments         | 3
user_age          | 5
user_behavior     | 1
user_name_age     | 6
users             | 2
```

## Start Flink SQL Client
```
docker exec -it flink bash
bin/sql-client.sh
```
After creating each SQL table the statement <code>SHOW TABLES;</code> to see the list of tables created<br>
Any other valid SQL statement can be issued, such as <code>SELECT * FROM {table_name};</code> to be able to see the data in Apache Flink.<br><br>
Flink SQL Client looks like as shown below:
```
                                   ▒▓██▓██▒
                               ▓████▒▒█▓▒▓███▓▒
                            ▓███▓░░        ▒▒▒▓██▒  ▒
                          ░██▒   ▒▒▓▓█▓▓▒░      ▒████
                          ██▒         ░▒▓███▒    ▒█▒█▒
                            ░▓█            ███   ▓░▒██
                              ▓█       ▒▒▒▒▒▓██▓░▒░▓▓█
                            █░ █   ▒▒░       ███▓▓█ ▒█▒▒▒
                            ████░   ▒▓█▓      ██▒▒▒ ▓███▒
                         ░▒█▓▓██       ▓█▒    ▓█▒▓██▓ ░█░
                   ▓░▒▓████▒ ██         ▒█    █▓░▒█▒░▒█▒
                  ███▓░██▓  ▓█           █   █▓ ▒▓█▓▓█▒
                ░██▓  ░█░            █  █▒ ▒█████▓▒ ██▓░▒
               ███░ ░ █░          ▓ ░█ █████▒░░    ░█░▓  ▓░
              ██▓█ ▒▒▓▒          ▓███████▓░       ▒█▒ ▒▓ ▓██▓
           ▒██▓ ▓█ █▓█       ░▒█████▓▓▒░         ██▒▒  █ ▒  ▓█▒
           ▓█▓  ▓█ ██▓ ░▓▓▓▓▓▓▓▒              ▒██▓           ░█▒
           ▓█    █ ▓███▓▒░              ░▓▓▓███▓          ░▒░ ▓█
           ██▓    ██▒    ░▒▓▓███▓▓▓▓▓██████▓▒            ▓███  █
          ▓███▒ ███   ░▓▓▒░░   ░▓████▓░                  ░▒▓▒  █▓
          █▓▒▒▓▓██  ░▒▒░░░▒▒▒▒▓██▓░                            █▓
          ██ ▓░▒█   ▓▓▓▓▒░░  ▒█▓       ▒▓▓██▓    ▓▒          ▒▒▓
          ▓█▓ ▓▒█  █▓░  ░▒▓▓██▒            ░▓█▒   ▒▒▒░▒▒▓█████▒
           ██░ ▓█▒█▒  ▒▓▓▒  ▓█                █░      ░░░░   ░█▒
           ▓█   ▒█▓   ░     █░                ▒█              █▓
            █▓   ██         █░                 ▓▓        ▒█▓▓▓▒█░
             █▓ ░▓██░       ▓▒                  ▓█▓▒░░░▒▓█░    ▒█
              ██   ▓█▓░      ▒                    ░▒█▒██▒      ▓▓
               ▓█▒   ▒█▓▒░                         ▒▒ █▒█▓▒▒░░▒██
                ░██▒    ▒▓▓▒                     ▓██▓▒█▒ ░▓▓▓▓▒█▓
                  ░▓██▒                          ▓░  ▒█▓█  ░░▒▒▒
                      ▒▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░▓▓  ▓░▒█░
          
    ______ _ _       _       _____  ____  _         _____ _ _            _  BETA   
   |  ____| (_)     | |     / ____|/ __ \| |       / ____| (_)          | |  
   | |__  | |_ _ __ | | __ | (___ | |  | | |      | |    | |_  ___ _ __ | |_ 
   |  __| | | | '_ \| |/ /  \___ \| |  | | |      | |    | | |/ _ \ '_ \| __|
   | |    | | | | | |   <   ____) | |__| | |____  | |____| | |  __/ | | | |_ 
   |_|    |_|_|_| |_|_|\_\ |_____/ \___\_\______|  \_____|_|_|\___|_| |_|\__|
          
        Welcome! Enter 'HELP;' to list all available commands. 'QUIT;' to exit.

Command history file path: /root/.flink-sql-history

Flink SQL> 
```

## Demo #1 (steps 1 to 3 are to be followed using the Flink SQL client)
The image "pydatagen" will be running and publishing data to the Kafka topic user_behavior
1. Create Flink table/source connector (consume from topic user_behavior)
```
-- SOURCE CONNECTOR
-- Get data from Kafka topic user_behavior (pydatagen producer pushing data directly into Kafka)
CREATE TABLE flink_user_behavior (
  `user_id` STRING,
  `item_id` STRING,
  `category_id` STRING,
  `behavior` STRING,
  `ts` TIMESTAMP(3),
  WATERMARK FOR ts AS ts - INTERVAL '10' SECOND  -- defines watermark on ts column, marks ts as event-time attribute
) WITH (
  'connector' = 'kafka',
  'topic' = 'user_behavior',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094',
  'properties.group.id' = 'flink_user_behavior',
  'key.fields' = 'user_id',
  'key.format' = 'raw',
  --'value.format' = 'json'
  'value.format' = 'avro-confluent',
  'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081'
);
```

2. Create Flink table/sink connector (kafka topic: behavior_summary, 4 partitions)
```
-- SINK CONNECTOR
CREATE TABLE behavior_summary (
    `behavior` STRING,
    `timestamp` TIMESTAMP(3),
    `buy_cnt` BIGINT
) WITH (
  'connector' = 'kafka',
  'topic' = 'behavior_summary',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094',
  --'properties.group.id' = 'behavior_summary',
  'key.fields' = 'behavior',
  'key.format' = 'raw',
  'value.format' = 'avro-confluent',
  'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081'
);
```

3. Create Flink SQL table/job to process events from user_behavior and store it in the table behavior_summary<br>
That job will aggregate the events in 10 seconds windows, that is what Flink calls a "bounded stream". That means the results will be sunk at every 10 seconds<br>
Go to Job Manager dashboard (http://127.0.0.1:8081) and see the number of available task managers decrease from 5 to 4
```
-- Create Flink job
INSERT INTO behavior_summary
SELECT behavior, TUMBLE_START(ts, INTERVAL '10' SECOND), COUNT(*)
FROM flink_user_behavior
GROUP BY behavior, TUMBLE(ts, INTERVAL '10' SECOND);
```

4. See events coming through Kafka (Control center: http://127.0.0.1:9021)<br>
Or view data on Flink SQL client
```
SELECT * FROM behavior_summary;
```

## Demo 2 (steps 1 to 5 are to be followed using the Flink SQL client)
1. Generate dummy order data using Flink’s faker connector (table orders)
```
-- CONNECTOR (dummy data produced direcly on Flink)
-- Generate order events that will contain user IDs within the predefined range.
-- These events are produced within Flink and will not be persisted anywhere.
CREATE TABLE orders (
  `user_id` INT PRIMARY KEY,
  `product_id` INT,
  `revenue` FLOAT
) WITH (
  'connector' = 'faker',
  'fields.user_id.expression' = '#{number.numberBetween ''0'',''21''}',
  'fields.product_id.expression' = '#{number.numberBetween ''0'',''100''}',
  'fields.revenue.expression' = '#{number.numberBetween ''100'',''999''}',
  'rows-per-second' = '100'
);
```

2. Create Flink table/sink connector (kafka topic: shipments, 3 partitions)
```
-- SINK CONNECTOR
-- Output table for our orders-users join in insert.sql.
CREATE TABLE shipments (
  `user_id` INT,
  `name` STRING,
  `product_id` INT,
  `revenue` FLOAT
) WITH (
  'connector' = 'kafka',
  'topic' = 'shipments',
  'key.fields' = 'user_id',
  'key.format' = 'raw',
  'value.format' = 'avro-confluent',
  'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
  --'properties.group.id' = 'shipments',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094'
);
```

3. Create Flink table/sink connector (kafka topic: users, 2 partitions)
```
-- SINK CONNECTOR
-- Kafka-backed table containing user data. We will manually insert a handful of
-- users into this table so that we can join product order events on them later.
CREATE TABLE users (
  `user_id` INT,
  `name` STRING
) WITH (
  'connector' = 'kafka',
  'topic' = 'users',
  'key.fields' = 'user_id',
  'key.format' = 'raw',
  'value.format' = 'avro-confluent',
  'value.avro-confluent.schema-registry.url' = 'http://schema-registry:9081',
  --'properties.group.id' = 'users',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094'
);
```

4. Insert data into Flink table users and see it in Kafka<br>
Go to Job Manager dashboard (http://127.0.0.1:8081) and see the number of available task managers decrease from 4 to 3
```
-- Insert some static user profile data into the users table.
-- We'll join order events on this table to generate shipment events.
INSERT INTO users (user_id, name) VALUES
  (0, 'Severus Snape'),
  (1, 'Draco Malfoy'),
  (2, 'Charity Burbage'),
  (3, 'Lord Voldemort'),
  (4, 'Dobby'),
  (5, 'Sirius Black'),
  (6, 'Bellatrix Lestrange'),
  (7, 'Andromeda Tonks'),
  (8, 'Ron Weasley'),
  (9, 'Harry Potter'),
  (10, 'Newt Scamander'),
  (11, 'Stan Shunpike'),
  (12, 'Hermione Granger'),
  (13, 'Fleur Delacour'),
  (14, 'Gregory Goyle'),
  (15, 'Winky'),
  (16, 'Molly Weasley'),
  (17, 'Sirius Black'),
  (18, 'Cornelius Fudge'),
  (19, 'Penelope Clearwater'),
  (20, 'Jay Kreps');
```

5. Create Flink SQL job to merge events from table orders and users into table shipments<br>
Go to Job Manager dashboard (http://127.0.0.1:8081) and see the number of available task managers decrease from 3 to 2
```
-- This statement will continuously INSERT the results of the join into the shipments table
INSERT INTO shipments 
SELECT
  o.user_id,
  u.name,
  o.product_id,
  o.revenue
FROM orders AS o JOIN users AS u ON o.user_id = u.user_id;
```

6. See events coming through Kafka (Control center: http://127.0.0.1:9021)<br>
Or view data on Flink SQL client
```
SELECT * FROM shipments;
```

## Demo 3 (steps 1 to 4 are to be followed using the Flink SQL client)
1. Create Flink table/sink connector (kafka topic: user_age, 5 partitions)
```
-- SINK CONNECTOR
CREATE TABLE user_age (
  `user_id` INT,
  `age` INT
) WITH (
  'connector' = 'kafka',
  'topic' = 'user_age',
  'key.fields' = 'user_id',
  'key.format' = 'raw',
  'value.format' = 'json',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094'
  --'properties.bootstrap.servers' = 'pkc-41wq6.eu-west-2.aws.confluent.cloud:9092',
  --'properties.security.protocol' = 'SASL_SSL',
  --'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="xxx" password="xxx;',
  --'properties.sasl.mechanism' = 'PLAIN',
  --'properties.client.dns.lookup' = 'use_all_dns_ips',
  --'properties.session.timeout.ms' = '45000',
  --'properties.acks' = 'all'
);
```

2. Create Flink table/sink connector (kafka topic: user_name_age, 6 partitions)
```
-- SINK CONNECTOR
CREATE TABLE user_name_age (
  `user_id` INT,
  `name` STRING,
  `age` INT
) WITH (
  'connector' = 'kafka',
  'topic' = 'user_name_age',
  'key.fields' = 'user_id',
  'key.format' = 'raw',
  'value.format' = 'json',
  'scan.startup.mode' = 'earliest-offset',
  'properties.bootstrap.servers' = 'broker:9094'
  --'properties.bootstrap.servers' = 'pkc-41wq6.eu-west-2.aws.confluent.cloud:9092',
  --'properties.security.protocol' = 'SASL_SSL',
  --'properties.sasl.jaas.config' = 'org.apache.kafka.common.security.plain.PlainLoginModule required username="xxx" password="xxx;',
  --'properties.sasl.mechanism' = 'PLAIN',
  --'properties.client.dns.lookup' = 'use_all_dns_ips',
  --'properties.session.timeout.ms' = '45000',
  --'properties.acks' = 'all'
);
```

3. Create Flink SQL job to merge events from table users (2 partitions in Kafka) and user_age into table user_name_age<br>
Go to Job Manager dashboard (http://127.0.0.1:8081) and see the number of available task managers decrease from 2 to 1
```
-- Flink SQL job
INSERT INTO user_name_age
SELECT
  u.user_id,
  u.name,
  a.age
FROM users AS u JOIN user_age AS a ON u.user_id = a.user_id;
```

4. Insert data into Flink table user_age
```
INSERT INTO user_age (user_id, age) VALUES
  (0, 10),
  (1, 20),
  (2, 21),
  (3, 22),
  (4, 23),
  (5, 24),
  (6, 25),
  (7, 26),
  (8, 27),
  (9, 28),
  (10, 29),
  (11, 30),
  (12, 31),
  (13, 32),
  (14, 33),
  (15, 34),
  (16, 35),
  (17, 36),
  (18, 37),
  (19, 38),
  (20, 39);
```

5. See events coming through Kafka (Control center: http://127.0.0.1:9021)<br>
Or view data on Flink SQL client
```
SELECT * FROM user_name_age;
```

Have a look on Job Manager dashboard () and Confluent Control Center () to see the stream processing in action.<br>
Once completed, exit the Flink SQL Client, the flink shell and stop the docker containers
```
exit;
exit
docker compose down
```