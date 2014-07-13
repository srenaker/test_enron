import pymongo

from pymongo import MongoClient


# connect to database
connection = MongoClient('localhost', 27017)

db = connection.enron2

messages = db.messages
from_addresses = db.from_addresses

all_messages = messages.distinct('From')

for i in all_messages:
    from_addresses.insert({'_id': i})