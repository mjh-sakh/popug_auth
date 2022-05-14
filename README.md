# README

Simple oath2 service to provide authorization for other services. 

Other services will need specific strategy to work correctly. See template under app/lib.  

It is based on @davydovanton template. Main changes are:
- remove node.js dependencies
- no call backs to publish Account Created business event
- Message producer is RabbitMQ only and changed to create topics instead of fanouts