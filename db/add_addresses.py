import pymongo

from pymongo import MongoClient


# connect to database
connection = MongoClient('localhost', 27017)

db = connection.enron

messages = db.messages
to_addresses = db.to_addresses

all_messages = messages.distinct('headers.To')

for i in all_messages:
    to_addresses.insert({'_id': i})