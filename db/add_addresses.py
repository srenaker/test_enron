import pymongo

from pymongo import MongoClient


# connect to database
connection = MongoClient('localhost', 27017)

db = connection.enron2

messages = db.messages
to_addresses = db.to_addresses

all_messages = messages.distinct('To')

for i in all_messages:
    to_addresses.insert({'_id': i})