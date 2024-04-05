# ContactAnalytics.Umbrella

This application is created for fun and to consider various approaches to solving some challenges.

Let's consider the following application

A customer can create an application. The application can have contacts.

A created contact does not have any predefined attributes.

The customer can create the following types of custome attributes: **bigint, decimal, float, text**

A text type can be used to save an email. It is not required for every contact to have the same range of attributes.

An attribute appears in the contact when the customer saves the value.

A customer can use a web interface or an REST API to update the attribute value.


This application is used to create (manage) a custom attribute and show the current values.

There can be 4 applications

1 The current application that is used by a web application

2 The REST API application that allows to create/update/delete contacts and contact's attributes through REST API. It can be used by developers. There can be some restrictions. Events are processed at the beginning every hour.

3 The Change Stream watching application. This application is responsible for watching db changes and data enrichment and then publishing events to the forth (4) application.

4 The application is responsible for saving attribute changes.


I want to use The Attribute Pattern to implement Custom attributes. I will see what challenges I have when using this pattern

The pattern is described in the following article.

[Building with Patterns: The Attribute Pattern](https://www.mongodb.com/blog/post/building-with-patterns-the-attribute-pattern)


There are links to interesting articals

https://martinfowler.com/bliki/UserDefinedField.html


https://backchannel.org/blog/friendfeed-schemaless-mysql



The following attributes are predefined.

```
{ attr_bigint: [], attr_decimal: [], attr_float: [], attr_text: [] }
```

They are arrays of key-value pairs.

```
{id: , v: , up_at:}
```

**id** is a user defined attribute identifier. It is auto generated and it is unique in a scope of an app

**v** is a value.

**up_at** is updated at


There is a collection where we save user defined attr name and id.

Let's define which data type is better for id use. Is it Integer or String?


```shell
docker run --name base-mongo-6 -d -p 27017-27019:27017-27019 mongo:6
```

```shell
mongo -p 27017
```

Mongo Shell

Removing all documents

```shell
db.contacts.remove({});
```

```shell
db.contacts.count();
```

```shell
db.contacts.dropIndex( "attr_bigint.id_1_attr_bigint.v_1" )
```

```shell
db.runCommand(
   {
     compact: "contacts"
   }
)
```

```shell
db.contacts.createIndex({'attr_bigint.id': 1, 'attr_bigint.v': 1})
```

when there are

100_000 documents
100 attrs

id is string ```(:crypto.strong_rand_bytes(20) |> Base.url_encode64)```
v  is bigint ```1```

```elixir
:rand.uniform(1000000000000000000)

field_g = fn(_) -> 
  %{"id" => (:crypto.strong_rand_bytes(20) |> Base.url_encode64), "v" => 1 }
end

1..100_000
|> Stream.map(fn i -> Mongo.BulkOps.get_insert_one(%{"attr_bigint" => Enum.map(1..100, field_g) }) end)
|> Mongo.UnorderedBulk.write(:mongo, "contacts", 100)
|> Stream.run()
```

```shell
db.runCommand(
   {
     compact: "contacts"
   }
)
```

indexes
```
db.contacts.createIndex({'attr_bigint.id': 1, 'attr_bigint.v': 1})
```

Stats
Mb
```shell
db.contacts.stats(1000000)
```

```
 "nindexes" : 2,
 "indexBuilds" : [ ],
 "totalIndexSize" : 466,
 "totalSize" : 837,
 "indexSizes" : {
  "_id_" : 1,
  "attr_bigint.id_1_attr_bigint.v_1" : 464
 },
 "scaleFactor" : 1000000,
 "ok" : 1

```



when there are
100_000 documents
100 attrs

id is bigint :rand.uniform(1000000000000000000)
v  is bigint 1

```elixir
field_g = fn(_) -> 
  %{"id" => :rand.uniform(1000000000000000000), "v" => 1 }
end

1..100_000
|> Stream.map(fn i -> Mongo.BulkOps.get_insert_one(%{"attr_bigint" => Enum.map(1..100, field_g) }) end)
|> Mongo.UnorderedBulk.write(:mongo, "contacts", 100)
|> Stream.run()
```

```shell
db.runCommand(
   {
     compact: "contacts"
   }
)
```

indexes

```shell
db.contacts.createIndex({'attr_bigint.id': 1, 'attr_bigint.v': 1})
```

Mb
```shell
db.contacts.stats(1000000) 
```

```
 "nindexes" : 2,
 "indexBuilds" : [ ],
 "totalIndexSize" : 186,
 "totalSize" : 336,
 "indexSizes" : {
  "_id_" : 1,
  "attr_bigint.id_1_attr_bigint.v_1" : 185
 },
 "scaleFactor" : 1000000,
 "ok" : 1
```

466 Mb (string)  186 Mb (bigint)


The bigint (int64) type is better for id attr than the string type.


## Select/Upsert/Delete

### Upsert

There is a good article [Atomically Upsert a Document into an Array with MongoDB](https://kevsoft.net/2022/08/12/atomically-upsert-a-document-into-an-array-with-mongodb.html)

1 Updating the existing element of an array

2 Inserting a new element of the array. {"attr_bigint.id": {$ne: xxxxxxxxx}} is used to solve a race condition issue.

We can update one or multiple documents in this way.

```
db.contacts.insert([{"_id" : ObjectId("65ec569f80fdd4895a7c46e3"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: []},
                    {"_id" : ObjectId("65ec569f80fdd4895a7c46e4"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: [{id: 123, v: 987}]}] )

db.contacts.find({})

{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 987 } ] }

```


```
db.contacts.updateMany({_id: {$in: [ObjectId("65ec569f80fdd4895a7c46e3"), ObjectId("65ec569f80fdd4895a7c46e4")]},
                       app_id: ObjectId("65eb555c74b5653202fa40c9"),
                       "attr_bigint.id": 123},

                       {"$set": {"attr_bigint.$.v": 456}})

db.contacts.find({})
```

A document where this element exists was updated

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 456 } ] }
```

Inserting a new value to the document where this element does not exist ({$ne: 123} is used to solve a race condition issue)

```
db.contacts.updateMany({_id: {$in: [ObjectId("65ec569f80fdd4895a7c46e3")]},
                       app_id: ObjectId("65eb555c74b5653202fa40c9"),
                       "attr_bigint.id": {$ne: 123}},

                       {$push: {attr_bigint: {"id": 123, "v": 456}}})

db.contacts.find({})
```

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 456 } ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 456 } ] }

```

```
db.contacts.updateMany({_id: {$in: [ObjectId("65ec569f80fdd4895a7c46e3"), ObjectId("65ec569f80fdd4895a7c46e4")]},
                       app_id: ObjectId("65eb555c74b5653202fa40c9"),
                       "attr_bigint.id": 123},

                       {"$set": {"attr_bigint.$.v": 765}})

db.contacts.find({})
```

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 765 } ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 765 } ] }

```

Why this way was chosen

There are two indices {'attr_bigint.id': 1, 'attr_bigint.v': 1}

There are redundant db queries but it is better than rebuilding indices for the whole array and for the two attributes at the same time.



### Delete

```
db.contacts.insert([{"_id" : ObjectId("65ec569f80fdd4895a7c46e3"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: [{id: 123, v: 987}]},
                    {"_id" : ObjectId("65ec569f80fdd4895a7c46e4"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: [{id: 123, v: 987}, { "id" : 1234, "v" : 890 }]}] )

db.contacts.find({})
```

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 987 } ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 987 }, { "id" : 1234, "v" : 890 } ] }
```


```
db.contacts.updateMany({_id: {$in: [ObjectId("65ec569f80fdd4895a7c46e3"), ObjectId("65ec569f80fdd4895a7c46e4")]},
                       app_id: ObjectId("65eb555c74b5653202fa40c9"),
                       "attr_bigint.id": 123},

                       {$pull: { attr_bigint: { "id": 123 }}})

db.contacts.find({})
```

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 1234, "v" : 890 } ] }
```

### Select

```
db.contacts.insert([{"_id" : ObjectId("65ec569f80fdd4895a7c46e3"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: [{id: 123, v: 2}]},
                    {"_id" : ObjectId("65ec569f80fdd4895a7c46e4"), app_id: ObjectId("65eb555c74b5653202fa40c9"), attr_bigint: [{id: 123, v: 4}, { "id" : 1234, "v" : 890 }]}] )

db.contacts.find({})
```

```
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e3"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 2 } ] }
{ "_id" : ObjectId("65ec569f80fdd4895a7c46e4"), "app_id" : ObjectId("65eb555c74b5653202fa40c9"), "attr_bigint" : [ { "id" : 123, "v" : 4 }, { "id" : 1234, "v" : 890 } ] }
```


```
db.contacts.find({app_id: ObjectId("65eb555c74b5653202fa40c9"),
                  "attr_bigint": { $elemMatch: {"id": 123, 'v': { $gte: 3} } }}).pretty()
```

```
{
 "_id" : ObjectId("65ec569f80fdd4895a7c46e4"),
 "app_id" : ObjectId("65eb555c74b5653202fa40c9"),
 "attr_bigint" : [
  {
   "id" : 123,
   "v" : 4
  },
  {
   "id" : 1234,
   "v" : 890
  }
 ]
}
```


Three collections are required

1 applications

2 custome attrs

3 contacts



You can use a relational DB. It is easier to insert and update but it requires joining you select.
It requires some more indices (contact_id/object_id-object_type).

contacts
id bigint
app_id
created_at
updated_at

custom_attrs
id        bigint
app_id
name      string
data_type string


bigint_attrs
contact_id     bigint
custom_attr_id bigint
value          bigint


string_attrs
contact_id
custom_attr_id bigint
value          string

You can use a polimorphic relation

string_attrs
object_id
object_type    text
custom_attr_id bigint
value          string


# Commands

https://hexdocs.pm/mongodb_driver/Mix.Tasks.Mongo.html


Migration

```
mix mongo.gen.migration add_custom_attrs_app_id_index

mix mongo.migrate

mix mongo.drop
```

test example

```
mix test ./apps/contact_analytics/test/contact_analytics/custom_attrs/docs_test.exs
```


## MongoDB Kafka Connector

[MongoDB Kafka Connector](https://www.mongodb.com/docs/kafka-connector/current/quick-start/#std-label-kafka-quick-start)

MongoDB shell

```
mongosh mongodb://127.0.0.1:35001
```


```
docker exec -it mongo1 /bin/bash
```

```
curl -X POST \
     -H "Content-Type: application/json" \
     --data '
     {"name": "mongo-source",
      "config": {
         "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
         "connection.uri":"mongodb://mongo1:27017/?replicaSet=rs0",
         "database":"contact_analytics",
         "collection":"contacts",
         "pipeline":"[{\"$match\": {\"operationType\": \"insert\"}}]"
         }
     }
     ' \
     http://connect:8083/connectors -w "\n"

curl -X POST \
     -H "Content-Type: application/json" \
     --data '
     {"name": "mongo-source-update",
      "config": {
         "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
         "connection.uri":"mongodb://mongo1:27017/?replicaSet=rs0",
         "database":"contact_analytics",
         "collection":"contacts",
         "pipeline":"[{\"$match\": {\"operationType\": \"update\"}}]"
         }
     }
     ' \
     http://connect:8083/connectors -w "\n"
```

```
docker exec -it mongo1 /bin/bash
```

List of topics

```
kafkacat -b broker:29092  -L
```

Testing topic messages

```
kafkacat -b broker:29092 -t contact_analytics.contacts
```