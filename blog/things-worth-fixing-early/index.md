---
title: Things worth fixing early
layout: post
tags: ["system design", "data"]
date: "2023-05-14"
---

You're in the SaaS business, and business is good. You've got a generous financial runway, paying customers, a compelling vision for the future of your product, and the means to execute.

![Business is good - Woody Harrelson as Tallahassee in Zombieland](./business-is-good.gif)

So what next?

If you're pragmatic then you've no doubt made trade-offs to survive and thrive and get where you are today.

But now that you're satisfied that business is prosperous it might be an opportune time to reflect on how you got to where you are today, and how you'll get to where you're going tomorrow.

The ideas I put forward below are based on my time at a major ANZ SaaS tech company.

## Know your customer usage patterns

Consider taking a look at aggregate information about your customers. A few things might surprise you.

For example, you will have a biggest customer, or several such customers. Call it the [80/20 rule (Pareto principle)](https://en.wikipedia.org/wiki/Pareto_principle) or more generally [Power law](https://en.wikipedia.org/wiki/Power_law).

They will have more data than the other 80% of your customers combined. They will be responsible for 80% of requests you serve.

These customers cost more to serve, and might even be known to you if their workloads are sufficiently demanding so as to necessitate incident response (i.e., perhaps you maintain a list of the 'usual suspects').

You should approach this situation with your eyes wide open. Price your product appropriately, and do your best to stymie exploitative use through measures such as introducing an acceptable use policy. Definitely avoid 'unlimited' style promises to subscribers.

Among other things, your acceptable use policy should reserve your right to take action via rate limiting and other technology measures deemed necessary to ensure that all of your customers can enjoy a high level of service.

## Nip legislative risk around consumer privacy and data sovereignty in the bud

Everybody likely knows someone impacted by a data breach. We've had some large ones in Australia.

- [Medibank hackers announce 'case closed' and dump huge data file on dark web](https://www.theguardian.com/australia-news/2022/dec/01/medibank-hackers-announce-case-closed-and-dump-huge-data-file-on-dark-web)
- [Optus data breach](https://www.acma.gov.au/optus-data-breach)
- [Latitude data breach](https://www.latitudefinancial.com.au/latitude-cyber-incident/)

Government appetites for intervention, typically via privacy legislation, are only growing.

The European GDPR legislation was a watershed moment that has caught a great many companies wrongfooted. But it should be considered a beginning rather than an end. Even if you're not within the scope of GDPR specifically, there's nothing stopping other countries introducing comparable legislation. And technically there's no reason that such laws can't be made *extraterritorial*.

If you haven't already, you should give thought to how you might satisfy a subscriber's request to have their data deleted. These requests aren't something you can just deflect, and non-compliance tends to attract severe financial penalties.

Do you have the tools to delete their data? Can you do it within the legislated deadline? Are any backups 'beyond use'? (i.e., backups that are used exclusively for restoration in emergency circumstances, to the exclusion of all other purposes).

Similarly, data sovereignty is worth being mindful of. If you're relatively new then you might be running your SaaS software out of a single location while allowing sign-ups from anywhere.

As you grow, consider how you might architect your software so that data belonging to customers in a given jurisdiction can remain in that jurisdiction. You might not have to build it now, but it's worth keeping in mind. The more successful you are, the more interest you'll likely attract from legislators and regulators.

## Consider how you might horizontally scale your data platform

### Sharding

With happy subscribers continuing their subscription, and new subscribers signing up all of the time, you'll very likely outgrow your initial database.

Two scaling approaches are typically proffered:
- Vertical scaling (use a bigger computer)
- Horizontal scaling (use more computers)

The former is folly long-term because it's cost-prohibitive.

Some NoSQL products make claims about their scalability. I wouldn't presume to write about these products because I haven't used many of them first-hand. Having said that, many of the claims strike me as dubious. That, or the trade-offs made (in my opinion) aren't the right trade-offs.

But let's say you are using a relational database product. SQL Server, MariaDB, Postgres. And let's say that you're working with a multi-tenant database (i.e., one database houses data belonging to 1-to-many subscribers).

The earlier you introduce support for the concept of database sharding, the easier it'll be. The notion, put simply, is that data belonging to Subscribers A and B lives in Database #1, while data belonging to Subscriber C lives in Database #2.

You don't even need to have an actual second shard to do it. You could simply write your code such that it *always* examines which subscriber the request belongs to and determines where data for the current request lives *before attempting to access* that data. Essentially, structuring the code so that it doesn't make assumptions about where a subscriber's data lives.

### Data architecture

There are different schools of thought concerning exactly how data is split up.

In microservice architectures, microservices often 'own' their data. This means that that you have numerous heterogeneous data stores, with each microservice theoretically exercising exclusive access to that data store.

In monolithic architectures, you might have a singular application database. It is this singular database that you would horizontally scale, giving you a homogenous fleet of databases.

I personally lean towards an architecture using a homogenous fleet of databases with the rule that any given subscriber's data lives in *exactly one database shard* for one simple reason:

You can atomically transact across the entirety of the subscriber's data, and apply rules and constraints that must hold true across the breadth of data.

But you also avoid all sorts of problems and challenges:
- Distributed transactions, and recovering from failure during a distributed transaction.
  - Sagas
  - Compensating transactions
- Answering business analysis questions that span multiple microservices.
- Restoring data in a disaster recovery situation, and subsequently having to reconcile restored data with your other heterogenous databases that did not require restoring (i.e., because losing a database and restoring it from backup will now mean it's minutes, or hours, behind the others).

### Licencing

If you're a growing business then licence fees are money out of your pocket.

In the case of Postgres versus Microsoft SQL Server, the former is $0.29 (USD) per hour in a single node configuration while the latter is $1.044 (USD) per hour for Standard Edition.

If you use Enterprise Edition then that suddenly goes up to $2.262 (USD) per hour for that same single node.

So the Microsoft-based solution might cost you anywhere between 3 and 10 times more than the open-source alternative.

Having said that, Microsoft have historically spruiked the notion of Total Cost of Ownership (TCO). Which is their way of saying 'yes, our software costs you more, but the experience is more refined and you'll save a *lot* of time not having to integrate different open-source products to achieve comparable results'.

You need to pick your poision with this one. But it's definitely something you should grapple with earlier rather than later, because data migrations are hard work.

## Do quality the right way

Nothing will upset a customer quite as much as having their time wasted. Buggy software. Slow software. Outright breaking of features that are essential to their daily lives. Remember: Whatever it is that you're selling, they care about it enough to pay you for it.

Companies grapple with quality control issues in different ways, but ultimately many land on risk mitigation via excruciating business processes that slow their time to market and usually still fail to satisfy.

David B. Black describes a [Champion challenger](https://www.blackliszt.com/2021/07/the-revolutionary-championchallenger-method-of-software-qa.html) methodology in his blog.

The core ideas are simple:
- Don't break things that already work
- For maximum productivity, ensure that your approach to testing is one in which new application code requires a minimal amount of additional testing code. David's blog suggests finding a way to drive testing via data.

## Quality of Service

I mentioned the 80/20 rule earlier, and specifically the situation where your biggest customer will be overwhelmingly responsible for your workload. If you've got a multi-tenanted system as described earlier (i.e., multiple subscribers sharing a database) then this might lead to one customer negatively impacting your other customers.

Microsoft have written a good article about this [noisy neighbour problem](https://learn.microsoft.com/en-us/azure/architecture/antipatterns/noisy-neighbor/noisy-neighbor).

The solution? Introduce rate limiting, and curb excess use.

It's worth being transparent about what subscribers can and can't do. AWS provide insight into all of the limits that apply to their various products and, while admittedly complicated, it'd be hard to claim that you didn't know where you stood as a customer.

On that note, Jenni Nadler has an excellent article concerning [error handling and error messages](https://wix-ux.com/when-life-gives-you-lemons-write-better-error-messages-46c5223e1a2f).

And Paul Tarjan has authored an article on [rate limiters and load shedders](https://stripe.com/blog/rate-limiters).
